import 'package:dio/dio.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_pool.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_error_parser.dart';

final _logger = FileLogger('xboard_http_client.dart');

/// 认证失败回调（401/403）
typedef AuthFailureCallback = void Function();

/// 全局认证失败回调（由 SDK Provider 注册）
AuthFailureCallback? _globalAuthFailureCallback;

/// 注册认证失败回调
void registerAuthFailureCallback(AuthFailureCallback callback) {
  _globalAuthFailureCallback = callback;
  _logger.info('已注册认证失败回调');
}

/// 需要脱敏的敏感字段名
const _sensitiveFields = [
  'authorization',
  'token',
  'password',
  'passwd',
  'secret',
  'api_key',
  'apikey',
  'api-key',
  'x-sign',
  'x-ticket',
  'cookie',
  'set-cookie',
];

/// 需要脱敏的邮箱字段
const _emailFields = ['email', 'mail', 'username', 'user'];

/// 敏感日志拦截器
///
/// - Debug 模式：记录完整日志
/// - Release 模式：
///   - 禁用请求体/响应体日志
///   - 请求头脱敏（Authorization、token、邮箱等）
///   - 仅记录请求方法、路径、状态码、耗时
/// - 认证失败检测：401/403 时触发回调
class _SecureLogInterceptor extends Interceptor {
  _SecureLogInterceptor({this.onAuthFailure});

  /// 认证失败回调
  final AuthFailureCallback? onAuthFailure;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      // Debug 模式：完整日志
      _logger.debug('[HTTP] >>>> ${options.method} ${options.uri}');
      _logger.debug('[HTTP] Headers: ${_sanitizeHeaders(options.headers)}');
      if (options.data != null) {
        _logger.debug('[HTTP] Body: ${options.data}');
      }
    } else {
      // Release 模式：仅记录基本信息 + 脱敏请求头
      _logger.debug('[HTTP] ${options.method} ${options.uri.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    if (AuthGuard.isAuthFailure(statusCode)) {
      _notifyAuthFailure(response.requestOptions, statusCode);
    }

    if (kDebugMode) {
      _logger.debug(
        '[HTTP] <<<< ${response.statusCode} ${response.requestOptions.uri}',
      );
      _logger.debug('[HTTP] Response: ${response.data}');
    } else {
      // Release 模式：仅记录状态码
      _logger.debug(
        '[HTTP] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final uri = err.requestOptions.uri;
    final statusCode = err.response?.statusCode;

    // 检测认证失败（401/403）
    if (AuthGuard.isAuthFailure(statusCode)) {
      _notifyAuthFailure(err.requestOptions, statusCode);
    }

    if (kDebugMode) {
      _logger.error('[HTTP] ERROR ${err.type}: $uri');
      _logger.error('[HTTP] ${err.message}');
      if (err.response != null) {
        _logger.error('[HTTP] Response: ${err.response?.data}');
      }
    } else {
      _logger.error(
        '[HTTP] ${err.requestOptions.method} ${uri.path} → ${statusCode ?? err.type}',
      );
    }
    handler.next(err);
  }

  void _notifyAuthFailure(RequestOptions options, int? statusCode) {
    if (options.extra['_authFailureNotified'] == true) return;
    options.extra['_authFailureNotified'] = true;
    _logger.warning(
      '[HTTP] 认证失败: ${options.method} ${options.uri} → $statusCode',
    );
    onAuthFailure?.call();
  }

  /// 脱敏请求头（用于 Debug 模式的可读日志）
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic>? headers) {
    if (headers == null || headers.isEmpty) return {};
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (_sensitiveFields.any((sensitive) => key.contains(sensitive))) {
        sanitized[entry.key] = '***';
      } else if (_emailFields.any((emailField) => key.contains(emailField))) {
        sanitized[entry.key] = _maskEmail('${entry.value}');
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /// 邮箱脱敏：user@example.com → u***@example.com
  static String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final local = parts[0];
    if (local.isEmpty) return '***@${parts[1]}';
    return '${local[0]}***@${parts[1]}';
  }
}

/// XBoard 统一 HTTP 客户端配置
class XBoardHttpConfig {
  // ========== 超时配置 ==========

  /// 快速操作超时（本地缓存、健康检查）
  static const quickTimeout = Duration(seconds: 5);

  /// 标准 API 请求超时
  static const standardTimeout = Duration(seconds: 15);

  /// 下载操作超时（订阅、配置文件）
  static const downloadTimeout = Duration(seconds: 30);

  /// 上传操作超时（文件上传、日志上传）
  static const uploadTimeout = Duration(seconds: 60);

  /// 长轮询超时（WebSocket 备用方案）
  static const longPollTimeout = Duration(seconds: 90);

  // ========== User-Agent 配置 ==========
  // 注意：不同的 UA 是有意设计的，服务端会根据 UA 返回不同格式的数据
  // ⚠️ 重要：所有 UA 必须和原始代码完全一致，特别是加密部分用于 Caddy 认证

  /// User-Agent 配置说明
  ///
  /// ⚠️ 所有 User-Agent 从配置文件读取，不再有默认值
  ///
  /// 使用方式：
  /// ```dart
  /// final ua = await UserAgentConfig.get(UserAgentScenario.subscription);
  /// ```
  ///
  /// 常用场景：
  /// - 订阅下载：UserAgentScenario.subscription
  /// - API/域名竞速：UserAgentScenario.api
  /// - 并发订阅：UserAgentScenario.subscriptionRacing
  /// - 消息附件：UserAgentScenario.attachment

  // ========== 重试配置 ==========

  /// 默认重试次数
  static const int defaultRetries = 3;

  /// 重试延迟（指数退避）
  static Duration retryDelay(int attempt) => Duration(seconds: attempt * 2);

  /// 是否应该重试（根据状态码判断）
  static bool shouldRetry(int? statusCode) {
    if (statusCode == null) return true;
    // 5xx 服务器错误应该重试
    if (statusCode >= 500) return true;
    // 429 Too Many Requests 应该重试
    if (statusCode == 429) return true;
    // 408 Request Timeout 应该重试
    if (statusCode == 408) return true;
    return false;
  }
}

/// XBoard 统一 HTTP 客户端
///
/// 功能特性：
/// - 统一的超时配置
/// - 统一的错误处理
/// - 自动日志记录
/// - 自动重试机制
/// - 请求/响应拦截器
class XBoardHttpClient {
  final Dio _dio;

  XBoardHttpClient({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
  }) : _dio = _createDio(baseUrl: baseUrl, timeout: timeout, headers: headers);

  /// 创建 Dio 实例
  static Dio _createDio({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: timeout ?? XBoardHttpConfig.standardTimeout,
        receiveTimeout: timeout ?? XBoardHttpConfig.standardTimeout,
        sendTimeout: timeout ?? XBoardHttpConfig.standardTimeout,
        headers: {
          'Accept': '*/*',
          // User-Agent 由具体请求设置，从配置文件读取
          // 参考: await UserAgentConfig.get(UserAgentScenario.xxx)
          ...?headers,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // 添加安全日志拦截器（Release 模式脱敏 + 认证失败检测）
    dio.interceptors.add(
      _SecureLogInterceptor(onAuthFailure: _globalAuthFailureCallback),
    );

    // 添加重试拦截器
    dio.interceptors.add(_RetryInterceptor(dio));

    return dio;
  }

  /// GET 请求
  Future<HttpResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST 请求
  Future<HttpResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT 请求
  Future<HttpResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE 请求
  Future<HttpResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 下载文件
  Future<HttpResult<void>> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: Options(receiveTimeout: XBoardHttpConfig.downloadTimeout),
      );
      return const HttpSuccess(null, 200, {});
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 上传文件
  Future<HttpResult<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(sendTimeout: XBoardHttpConfig.uploadTimeout),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 处理响应
  HttpResult<T> _handleResponse<T>(Response<T> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return HttpSuccess(
        response.data as T,
        statusCode,
        _convertHeaders(response.headers),
      );
    } else {
      return HttpFailure(
        'HTTP $statusCode: ${response.statusMessage ?? "Unknown error"}',
        statusCode: statusCode,
        data: response.data,
      );
    }
  }

  /// 处理错误
  HttpResult<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return const HttpFailure(
            'Connection timeout',
            errorType: HttpErrorType.timeout,
          );
        case DioExceptionType.sendTimeout:
          return const HttpFailure(
            'Send timeout',
            errorType: HttpErrorType.timeout,
          );
        case DioExceptionType.receiveTimeout:
          return const HttpFailure(
            'Receive timeout',
            errorType: HttpErrorType.timeout,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          return HttpFailure(
            'HTTP error: $statusCode',
            statusCode: statusCode,
            errorType: HttpErrorType.server,
            data: error.response?.data,
          );
        case DioExceptionType.cancel:
          return const HttpFailure(
            'Request cancelled',
            errorType: HttpErrorType.cancel,
          );
        case DioExceptionType.badCertificate:
          return const HttpFailure(
            'Certificate verification failed',
            errorType: HttpErrorType.certificate,
          );
        case DioExceptionType.connectionError:
          return HttpFailure(
            'Network connection failed: ${ErrorSanitizer.sanitize(error.message ?? '')}',
            errorType: HttpErrorType.network,
          );
        default:
          return HttpFailure(
            'Unknown error: ${ErrorSanitizer.sanitize(error.message ?? '')}',
            errorType: HttpErrorType.unknown,
          );
      }
    }

    return HttpFailure(
      'Request exception: ${ErrorSanitizer.sanitize(error.toString())}',
      errorType: HttpErrorType.unknown,
    );
  }

  /// 转换 Headers
  Map<String, String> _convertHeaders(Headers headers) {
    final result = <String, String>{};
    headers.forEach((name, values) {
      if (values.isNotEmpty) {
        result[name] = values.first;
      }
    });
    return result;
  }

  /// 关闭客户端
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

/// 重试拦截器（带域名切换）
///
/// Phase 1: 在当前域名重试 N 次（指数退避）
/// Phase 2: 切换到 DomainPool 中的下一个候选域名，重置重试计数
/// Phase 3: 所有候选域名耗尽后，重新解析 TXT 记录 + 竞速，用新域名重试
///
/// 仅对基础设施错误（超时、连接失败、5xx）触发切换，
/// 业务错误（401、403、404、422）不触发。
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retries = extra['retries'] ?? XBoardHttpConfig.defaultRetries;
    final attempt = extra['attempt'] ?? 0;

    // Skip domain fallback if explicitly disabled (e.g., domain racing requests)
    final skipFallback = extra['skipDomainFallback'] == true;

    // Check if this is an infrastructure error worth retrying
    if (!_isInfrastructureError(err)) {
      return handler.next(err);
    }

    // ── Phase 1: retry on same domain ──
    if (attempt < retries) {
      final delay = XBoardHttpConfig.retryDelay(attempt + 1);
      _logger.warning(
        '[HTTP] Phase 1: 第${attempt + 1}/$retries次重试 (${delay.inSeconds}s后): '
        '${err.requestOptions.uri}',
      );

      await Future.delayed(delay);
      err.requestOptions.extra['attempt'] = attempt + 1;

      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    // Domain fallback disabled — propagate error
    if (skipFallback) {
      return handler.next(err);
    }

    final pool = DomainPool.instance;
    if (!pool.isInitialized) {
      return handler.next(err);
    }

    // ── Phase 2: switch to next candidate domain ──
    final nextDomain = pool.switchToNext();
    if (nextDomain != null) {
      _logger.info('[HTTP] Phase 2: 切换域名 → $nextDomain');

      _rewriteRequestDomain(err.requestOptions, nextDomain);
      err.requestOptions.extra['attempt'] = 0; // reset retry counter

      try {
        final response = await _dio.fetch(err.requestOptions);
        // Success on new domain — reset failure state
        pool.resetFailureState();
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    // ── Phase 3: re-resolve TXT + re-race ──
    _logger.info('[HTTP] Phase 3: 所有候选域名耗尽，开始重新解析');
    final newDomain = await pool.reResolveAndRace();
    if (newDomain != null) {
      _logger.info('[HTTP] Phase 3: 新域名 → $newDomain');

      _rewriteRequestDomain(err.requestOptions, newDomain);
      err.requestOptions.extra['attempt'] = 0;

      try {
        final response = await _dio.fetch(err.requestOptions);
        pool.resetFailureState();
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
        return handler.next(err);
      }
    }

    // All phases exhausted — propagate original error
    _logger.error('[HTTP] 所有域名切换阶段均失败: ${err.requestOptions.uri}');
    return handler.next(err);
  }

  /// Whether the error is an infrastructure failure that warrants domain switching.
  ///
  /// Business errors (4xx except 408/429) indicate the domain is working fine —
  /// switching domains would not help.
  bool _isInfrastructureError(DioException err) {
    // Timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Connection / network error
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Server-side errors (5xx), 408 timeout, 429 rate limit
    final statusCode = err.response?.statusCode;
    if (!XBoardHttpConfig.shouldRetry(statusCode)) {
      return false;
    }

    final requestPath = _normalizeRequestPath(err.requestOptions);
    final responseData = _asResponseMap(err.response?.data);

    // 使用 V2Board 错误解析器判断是否应该重试
    final errorType = V2BoardErrorParser.parseError(
      statusCode: statusCode,
      responseData: responseData,
    );

    // 鉴权端点里的 422/500 绝大多数是业务错误，切域名不会改善。
    if (_isAuthEndpoint(requestPath) &&
        _isAuthBusinessError(statusCode: statusCode, errorType: errorType)) {
      _logger.info('[HTTP] 鉴权业务错误（禁用重试/切域）: $requestPath -> $errorType');
      return false;
    }

    final shouldRetry = V2BoardErrorParser.shouldRetry(errorType);
    if (!shouldRetry && statusCode == 500) {
      _logger.info('[HTTP] V2Board 业务错误（不重试）: $errorType');
    }

    return shouldRetry;
  }

  Map<String, dynamic>? _asResponseMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  String _normalizeRequestPath(RequestOptions options) {
    final parsed = Uri.tryParse(options.path);
    if (parsed != null && parsed.hasAuthority) {
      return parsed.path;
    }
    return options.uri.path;
  }

  bool _isAuthEndpoint(String path) {
    return path == '/api/v1/passport/auth/login' ||
        path == '/api/v1/passport/auth/register' ||
        path == '/api/v1/passport/auth/forget' ||
        path == '/api/v1/passport/comm/sendEmailVerify';
  }

  bool _isAuthBusinessError({
    required int? statusCode,
    required V2BoardErrorType errorType,
  }) {
    if (statusCode == 422 || statusCode == 403) {
      return true;
    }

    switch (errorType) {
      case V2BoardErrorType.invalidCredentials:
      case V2BoardErrorType.accountSuspended:
      case V2BoardErrorType.passwordLimitExceeded:
      case V2BoardErrorType.registerLimitExceeded:
      case V2BoardErrorType.inviteCodeRequired:
      case V2BoardErrorType.emailCodeRequired:
      case V2BoardErrorType.validationError:
      case V2BoardErrorType.tokenInvalid:
      case V2BoardErrorType.rateLimitExceeded:
        return true;
      case V2BoardErrorType.unknown:
        return false;
    }
  }

  /// Rewrite the request URL to use [newDomain], keeping the path and query intact.
  void _rewriteRequestDomain(RequestOptions options, String newDomain) {
    final oldUri = options.uri;
    final newBaseUri = Uri.parse(newDomain);

    final rewritten = oldUri.replace(
      scheme: newBaseUri.scheme.isNotEmpty ? newBaseUri.scheme : oldUri.scheme,
      host: newBaseUri.host,
      port: newBaseUri.hasPort ? newBaseUri.port : oldUri.port,
    );

    // Dio uses path + baseUrl; update via full path to avoid conflicts
    options.path = rewritten.toString();
    options.baseUrl = '';
  }
}

/// HTTP 结果类型
sealed class HttpResult<T> {
  const HttpResult();

  /// 是否成功
  bool get isSuccess => this is HttpSuccess<T>;

  /// 是否失败
  bool get isFailure => this is HttpFailure<T>;

  /// 获取数据（如果成功）
  T? get dataOrNull => switch (this) {
    HttpSuccess(data: final data) => data,
    _ => null,
  };

  /// 模式匹配
  R when<R>({
    required R Function(T data, int statusCode, Map<String, String> headers)
    success,
    required R Function(
      String message,
      HttpErrorType errorType,
      int? statusCode,
      dynamic data,
    )
    failure,
  }) {
    return switch (this) {
      HttpSuccess(
        data: final data,
        statusCode: final code,
        headers: final headers,
      ) =>
        success(data, code, headers),
      HttpFailure(
        message: final msg,
        errorType: final type,
        statusCode: final code,
        data: final data,
      ) =>
        failure(msg, type, code, data),
    };
  }
}

/// HTTP 成功结果
class HttpSuccess<T> extends HttpResult<T> {
  final T data;
  final int statusCode;
  final Map<String, String> headers;

  const HttpSuccess(this.data, this.statusCode, this.headers);
}

/// HTTP 失败结果
class HttpFailure<T> extends HttpResult<T> {
  final String message;
  final HttpErrorType errorType;
  final int? statusCode;
  final dynamic data;

  const HttpFailure(
    this.message, {
    this.errorType = HttpErrorType.unknown,
    this.statusCode,
    this.data,
  });
}

/// HTTP 错误类型
enum HttpErrorType {
  /// 网络错误
  network,

  /// 超时
  timeout,

  /// 服务器错误
  server,

  /// 证书错误
  certificate,

  /// 请求取消
  cancel,

  /// 未知错误
  unknown,
}
