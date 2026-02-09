import 'package:dio/dio.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'user_agent_config.dart';
import 'package:fl_clash/xboard/infrastructure/network/domain_pool.dart';

// 初始化文件级日志器
final _logger = FileLogger('xboard_http_client.dart');

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
  final String? _baseUrl;
  
  XBoardHttpClient({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
  })  : _baseUrl = baseUrl,
        _dio = _createDio(
          baseUrl: baseUrl,
          timeout: timeout,
          headers: headers,
        );
  
  /// 创建 Dio 实例
  static Dio _createDio({
    String? baseUrl,
    Duration? timeout,
    Map<String, dynamic>? headers,
  }) {
    final dio = Dio(BaseOptions(
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
    ));
    
    // 添加日志拦截器（仅在 Debug 模式）
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => _logger.debug('[HTTP] $obj'),
    ));
    
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
        options: Options(
          receiveTimeout: XBoardHttpConfig.downloadTimeout,
        ),
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
        options: Options(
          sendTimeout: XBoardHttpConfig.uploadTimeout,
        ),
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
    return XBoardHttpConfig.shouldRetry(statusCode);
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
    required R Function(T data, int statusCode, Map<String, String> headers) success,
    required R Function(String message, HttpErrorType errorType, int? statusCode, dynamic data) failure,
  }) {
    return switch (this) {
      HttpSuccess(data: final data, statusCode: final code, headers: final headers) =>
        success(data, code, headers),
      HttpFailure(
        message: final msg,
        errorType: final type,
        statusCode: final code,
        data: final data
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

