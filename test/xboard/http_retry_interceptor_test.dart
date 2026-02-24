library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/xboard/infrastructure/http/xboard_http_client.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_RetryInterceptor 集成测试', () {
    late HttpServer primaryServer;
    late HttpServer fallbackServer;
    late StreamSubscription<HttpRequest> primarySub;
    late StreamSubscription<HttpRequest> fallbackSub;
    late XBoardHttpClient client;

    late String primaryBaseUrl;
    late String fallbackBaseUrl;

    var primaryRequestCount = 0;
    var fallbackRequestCount = 0;
    var domainSwitchCount = 0;

    Future<void> writeJson(
      HttpRequest request,
      int statusCode,
      Map<String, dynamic> body,
    ) async {
      request.response.statusCode = statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      await request.response.close();
    }

    setUp(() async {
      primaryRequestCount = 0;
      fallbackRequestCount = 0;
      domainSwitchCount = 0;

      primaryServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      fallbackServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      primarySub = primaryServer.listen((request) async {
        primaryRequestCount++;
        if (request.uri.path == '/api/v1/passport/auth/login') {
          await writeJson(request, 500, {
            'message': 'Incorrect email or password',
          });
          return;
        }
        if (request.uri.path == '/api/v1/passport/auth/register') {
          await writeJson(request, 500, {
            'message': 'Register frequently, please try again after 60 minute',
          });
          return;
        }
        await writeJson(request, 500, {'message': 'internal server error'});
      });

      fallbackSub = fallbackServer.listen((request) async {
        fallbackRequestCount++;
        await writeJson(request, 200, {'data': true});
      });

      primaryBaseUrl =
          'http://${primaryServer.address.host}:${primaryServer.port}';
      fallbackBaseUrl =
          'http://${fallbackServer.address.host}:${fallbackServer.port}';

      DomainPool.instance.initialize(primaryBaseUrl, [
        primaryBaseUrl,
        fallbackBaseUrl,
      ], onSwitch: (_) => domainSwitchCount++);

      client = XBoardHttpClient(
        baseUrl: primaryBaseUrl,
        timeout: const Duration(seconds: 3),
      );
    });

    tearDown(() async {
      client.close(force: true);
      await primarySub.cancel();
      await fallbackSub.cancel();
      await primaryServer.close(force: true);
      await fallbackServer.close(force: true);
    });

    test('登录 500（错误邮箱/密码）不应触发重试和域名切换', () async {
      final result = await client.post<dynamic>(
        '$primaryBaseUrl/api/v1/passport/auth/login',
        data: const {
          'email': 'wrong@example.com',
          'password': 'wrong-password',
        },
      );

      expect(result, isA<HttpFailure<dynamic>>());
      final failure = result as HttpFailure<dynamic>;
      expect(failure.statusCode, 500);
      expect(primaryRequestCount, 1);
      expect(fallbackRequestCount, 0);
      expect(domainSwitchCount, 0);
    });

    test('注册 500（注册频繁）不应触发重试和域名切换', () async {
      final result = await client.post<dynamic>(
        '$primaryBaseUrl/api/v1/passport/auth/register',
        data: const {'email': 'new@example.com', 'password': '12345678'},
      );

      expect(result, isA<HttpFailure<dynamic>>());
      final failure = result as HttpFailure<dynamic>;
      expect(failure.statusCode, 500);
      expect(primaryRequestCount, 1);
      expect(fallbackRequestCount, 0);
      expect(domainSwitchCount, 0);
    });
  });
}
