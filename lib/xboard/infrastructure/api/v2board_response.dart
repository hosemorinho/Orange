/// V2Board API 通用响应包装
///
/// V2Board v1.7.2 API 统一返回格式：
/// 成功: {"data": ...}
/// 失败: {"message": "错误信息"}

class V2BoardResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  const V2BoardResponse({
    this.data,
    this.message,
    this.success = true,
  });

  /// 从 API 原始响应中解析
  ///
  /// [json] 原始 JSON Map
  /// [fromData] 可选的 data 字段转换函数
  factory V2BoardResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic data)? fromData,
  }) {
    final message = json['message'] as String?;

    // V2Board 错误响应只有 message 字段
    if (json.containsKey('data')) {
      final rawData = json['data'];
      return V2BoardResponse(
        data: fromData != null ? fromData(rawData) : rawData as T?,
        message: message,
        success: true,
      );
    }

    // 没有 data 字段，视为错误
    return V2BoardResponse(
      message: message ?? '未知错误',
      success: message == null, // 如果连 message 都没有，可能是成功的空响应
    );
  }

  /// 获取数据，失败时抛出异常
  T get dataOrThrow {
    if (data != null) return data as T;
    throw V2BoardApiException(message ?? '响应数据为空');
  }
}

/// V2Board API 异常
class V2BoardApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic rawData;

  const V2BoardApiException(
    this.message, {
    this.statusCode,
    this.rawData,
  });

  @override
  String toString() => message;
}
