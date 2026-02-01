/// V2Board v1.7.2 API Service
///
/// 替代 flutter_xboard_sdk，直接使用 Dio HTTP 调用 V2Board API
/// Auth header: `Authorization: {token}` (无 Bearer 前缀)
import 'package:fl_clash/xboard/infrastructure/http/xboard_http_client.dart';
import 'package:fl_clash/xboard/core/core.dart';
import 'package:dio/dio.dart';

import 'v2board_response.dart';
import 'v2board_token_storage.dart';

final _logger = FileLogger('v2board_api_service.dart');

class V2BoardApiService {
  final XBoardHttpClient _http;
  final String baseUrl;
  String? _authToken;

  V2BoardApiService({
    required this.baseUrl,
    required XBoardHttpClient httpClient,
    String? authToken,
  })  : _http = httpClient,
        _authToken = authToken;

  // ========== Token 管理 ==========

  String? get authToken => _authToken;

  set authToken(String? token) {
    _authToken = token;
  }

  Future<void> loadStoredToken() async {
    _authToken = await V2BoardTokenStorage.getToken();
  }

  Future<void> saveAndSetToken(String token) async {
    _authToken = token;
    await V2BoardTokenStorage.saveToken(token);
  }

  Future<void> clearToken() async {
    _authToken = null;
    await V2BoardTokenStorage.clearAuth();
  }

  bool get hasAuthToken => _authToken != null && _authToken!.isNotEmpty;

  /// 构建带认证的请求 Options
  Options _authOptions({Map<String, dynamic>? extra}) {
    return Options(
      headers: _authToken != null
          ? {'Authorization': _authToken!}
          : null,
      extra: extra,
    );
  }

  /// 统一的 POST 请求（带 auth）
  Future<Map<String, dynamic>> _authPost(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _http.post<dynamic>(
      '$baseUrl$path',
      data: data,
      queryParameters: queryParameters,
      options: _authOptions(),
    );
    return _unwrapResult(result, path);
  }

  /// 统一的 GET 请求（带 auth）
  Future<Map<String, dynamic>> _authGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _http.get<dynamic>(
      '$baseUrl$path',
      queryParameters: queryParameters,
      options: _authOptions(),
    );
    return _unwrapResult(result, path);
  }

  /// 统一的 POST 请求（无 auth，用于 passport/guest）
  Future<Map<String, dynamic>> _publicPost(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final result = await _http.post<dynamic>(
      '$baseUrl$path',
      data: data,
    );
    return _unwrapResult(result, path);
  }

  /// 统一的 GET 请求（无 auth，用于 guest）
  Future<Map<String, dynamic>> _publicGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await _http.get<dynamic>(
      '$baseUrl$path',
      queryParameters: queryParameters,
    );
    return _unwrapResult(result, path);
  }

  /// 解包 HttpResult → Map
  Map<String, dynamic> _unwrapResult(HttpResult<dynamic> result, String path) {
    return result.when(
      success: (data, statusCode, headers) {
        if (data is Map<String, dynamic>) {
          // 检查 V2Board 错误响应
          if (data.containsKey('message') && !data.containsKey('data')) {
            throw V2BoardApiException(
              data['message'] as String? ?? '请求失败',
              statusCode: statusCode,
              rawData: data,
            );
          }
          return data;
        }
        // data 可能是 null（某些成功的空响应）
        return <String, dynamic>{'data': data};
      },
      failure: (message, errorType, statusCode, data) {
        // 尝试从响应体提取 V2Board 错误信息
        String errorMsg = message;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          errorMsg = data['message'] as String? ?? message;
        }
        throw V2BoardApiException(
          errorMsg,
          statusCode: statusCode,
          rawData: data,
        );
      },
    );
  }

  // ================================================================
  // Passport（认证）
  // ================================================================

  /// 登录
  Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.info('[API] login: $email');
    final json = await _publicPost('/api/v1/passport/auth/login', data: {
      'email': email,
      'password': password,
    });
    // V2Board 返回 {"data": {"token": "xxx", ...}}
    return json;
  }

  /// 注册
  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String? inviteCode,
    String? emailCode,
  }) async {
    _logger.info('[API] register: $email');
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (inviteCode != null && inviteCode.isNotEmpty) {
      body['invite_code'] = inviteCode;
    }
    if (emailCode != null && emailCode.isNotEmpty) {
      body['email_code'] = emailCode;
    }
    return await _publicPost('/api/v1/passport/auth/register', data: body);
  }

  /// 忘记密码
  Future<Map<String, dynamic>> forget(
    String email,
    String emailCode,
    String password,
  ) async {
    _logger.info('[API] forget password: $email');
    return await _publicPost('/api/v1/passport/auth/forget', data: {
      'email': email,
      'email_code': emailCode,
      'password': password,
    });
  }

  /// 发送邮箱验证码
  Future<Map<String, dynamic>> sendEmailVerify(String email) async {
    _logger.info('[API] sendEmailVerify: $email');
    return await _publicPost('/api/v1/passport/comm/sendEmailVerify', data: {
      'email': email,
    });
  }

  /// 获取 Passport 通用配置
  Future<Map<String, dynamic>> getPassportConfig() async {
    return await _publicGet('/api/v1/passport/comm/config');
  }

  /// 检查 token 有效性
  Future<Map<String, dynamic>> checkAuth() async {
    return await _authGet('/api/v1/passport/auth/check');
  }

  // ================================================================
  // User（用户）
  // ================================================================

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    _logger.info('[API] getUserInfo');
    return await _authGet('/api/v1/user/info');
  }

  /// 获取订阅信息
  Future<Map<String, dynamic>> getSubscribe() async {
    _logger.info('[API] getSubscribe');
    return await _authGet('/api/v1/user/getSubscribe');
  }

  /// 重置订阅链接
  Future<Map<String, dynamic>> resetSecurity() async {
    _logger.info('[API] resetSecurity');
    return await _authGet('/api/v1/user/resetSecurity');
  }

  /// 获取统计信息
  Future<Map<String, dynamic>> getStat() async {
    return await _authGet('/api/v1/user/getStat');
  }

  /// 修改密码
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    return await _authPost('/api/v1/user/changePassword', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  /// 更新用户信息
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> params) async {
    return await _authPost('/api/v1/user/update', data: params);
  }

  /// 划转佣金到余额
  Future<Map<String, dynamic>> transfer(int transferAmount) async {
    _logger.info('[API] transfer: $transferAmount');
    return await _authPost('/api/v1/user/transfer', data: {
      'transfer_amount': transferAmount,
    });
  }

  /// 登出
  Future<Map<String, dynamic>> logout() async {
    _logger.info('[API] logout');
    return await _authGet('/api/v1/user/logout');
  }

  // ================================================================
  // Plans（套餐）
  // ================================================================

  /// 获取套餐列表
  Future<Map<String, dynamic>> fetchPlans() async {
    _logger.info('[API] fetchPlans');
    return await _authGet('/api/v1/user/plan/fetch');
  }

  /// 获取单个套餐
  Future<Map<String, dynamic>> fetchPlan(int id) async {
    return await _authGet('/api/v1/user/plan/fetch', queryParameters: {
      'id': id,
    });
  }

  // ================================================================
  // Orders（订单）
  // ================================================================

  /// 获取订单列表
  Future<Map<String, dynamic>> fetchOrders() async {
    _logger.info('[API] fetchOrders');
    return await _authGet('/api/v1/user/order/fetch');
  }

  /// 获取订单详情
  Future<Map<String, dynamic>> fetchOrderDetail(String tradeNo) async {
    return await _authGet('/api/v1/user/order/detail', queryParameters: {
      'trade_no': tradeNo,
    });
  }

  /// 检查订单状态
  Future<Map<String, dynamic>> checkOrder(String tradeNo) async {
    return await _authGet('/api/v1/user/order/check', queryParameters: {
      'trade_no': tradeNo,
    });
  }

  /// 获取支付方式列表
  Future<Map<String, dynamic>> getPaymentMethod() async {
    _logger.info('[API] getPaymentMethod');
    return await _authGet('/api/v1/user/order/getPaymentMethod');
  }

  /// 创建订单
  ///
  /// [planId] 套餐 ID
  /// [period] V2Board 周期参数，如 "month_price", "quarter_price" 等
  /// [couponCode] 优惠券代码（可选）
  Future<Map<String, dynamic>> saveOrder(
    int planId,
    String period, {
    String? couponCode,
  }) async {
    _logger.info('[API] saveOrder: planId=$planId, period=$period, couponCode=$couponCode');
    final data = {
      'plan_id': planId,
      'period': period,
    };

    // 添加优惠券代码（如果提供）
    if (couponCode != null && couponCode.isNotEmpty) {
      data['coupon_code'] = couponCode;
    }

    return await _authPost('/api/v1/user/order/save', data: data);
  }

  /// 提交支付（结账）
  ///
  /// [tradeNo] 订单号
  /// [method] 支付方式 ID
  Future<Map<String, dynamic>> checkoutOrder(
    String tradeNo,
    int method,
  ) async {
    _logger.info('[API] checkoutOrder: tradeNo=$tradeNo, method=$method');
    return await _authPost('/api/v1/user/order/checkout', data: {
      'trade_no': tradeNo,
      'method': method,
    });
  }

  /// 取消订单
  Future<Map<String, dynamic>> cancelOrder(String tradeNo) async {
    _logger.info('[API] cancelOrder: tradeNo=$tradeNo');
    return await _authPost('/api/v1/user/order/cancel', data: {
      'trade_no': tradeNo,
    });
  }

  // ================================================================
  // Tickets（工单）
  // ================================================================

  /// 获取工单列表
  Future<Map<String, dynamic>> fetchTickets() async {
    return await _authGet('/api/v1/user/ticket/fetch');
  }

  /// 获取工单详情
  Future<Map<String, dynamic>> fetchTicketDetail(int id) async {
    return await _authGet('/api/v1/user/ticket/fetch', queryParameters: {
      'id': id,
    });
  }

  /// 创建工单
  Future<Map<String, dynamic>> saveTicket(
    String subject,
    int level,
    String message,
  ) async {
    return await _authPost('/api/v1/user/ticket/save', data: {
      'subject': subject,
      'level': level,
      'message': message,
    });
  }

  /// 回复工单
  Future<Map<String, dynamic>> replyTicket(int id, String message) async {
    return await _authPost('/api/v1/user/ticket/reply', data: {
      'id': id,
      'message': message,
    });
  }

  /// 关闭工单
  Future<Map<String, dynamic>> closeTicket(int id) async {
    return await _authPost('/api/v1/user/ticket/close', data: {
      'id': id,
    });
  }

  /// 提现（通过工单）
  Future<Map<String, dynamic>> withdrawTicket(String method, String account) async {
    _logger.info('[API] withdrawTicket: method=$method');
    return await _authPost('/api/v1/user/ticket/withdraw', data: {
      'withdraw_method': method,
      'withdraw_account': account,
    });
  }

  // ================================================================
  // Notices（公告）
  // ================================================================

  /// 获取公告列表
  Future<Map<String, dynamic>> fetchNotices() async {
    _logger.info('[API] fetchNotices');
    return await _authGet('/api/v1/user/notice/fetch');
  }

  // ================================================================
  // Guest（访客）
  // ================================================================

  /// 获取通用配置（无需登录）
  Future<Map<String, dynamic>> getGuestConfig() async {
    return await _publicGet('/api/v1/guest/comm/config');
  }

  /// 获取套餐列表（无需登录）
  Future<Map<String, dynamic>> getGuestPlans() async {
    return await _publicGet('/api/v1/guest/plan/fetch');
  }

  // ================================================================
  // Invite（邀请）
  // ================================================================

  /// 获取邀请码列表和统计信息
  /// Returns: {"codes": [...], "stat": [reg_users, settled, pending, rate, available]}
  Future<Map<String, dynamic>> getInviteCodes() async {
    _logger.info('[API] getInviteCodes');
    return await _authGet('/api/v1/user/invite/fetch');
  }

  /// 创建新的邀请码
  Future<Map<String, dynamic>> createInviteCode() async {
    _logger.info('[API] createInviteCode');
    return await _authGet('/api/v1/user/invite/save');
  }

  /// 获取邀请详情（佣金统计）
  Future<Map<String, dynamic>> getInviteDetails(String code) async {
    _logger.info('[API] getInviteDetails: code=$code');
    return await _authGet('/api/v1/user/invite/details', queryParameters: {
      'code': code,
    });
  }

  /// 获取佣金配置（提现方式）
  Future<Map<String, dynamic>> getCommissionConfig() async {
    _logger.info('[API] getCommissionConfig');
    return await _authGet('/api/v1/user/comm/config');
  }

  /// 转账佣金到余额
  Future<Map<String, dynamic>> transferCommission(double amount) async {
    _logger.info('[API] transferCommission: amount=$amount');
    return await _authPost('/api/v1/user/transfer', data: {
      'transfer_amount': amount,
    });
  }

  // ================================================================
  // Subscription（客户端订阅）
  // ================================================================

  /// 构建订阅 URL
  String buildSubscribeUrl(String token) {
    return '$baseUrl/api/v1/client/subscribe?token=$token';
  }

  // ================================================================
  // Traffic（流量日志）
  // ================================================================

  /// 获取流量使用记录
  ///
  /// [offset] 偏移量
  /// [limit] 每页数量
  Future<Map<String, dynamic>> getTrafficLogs({
    int offset = 0,
    int limit = 30,
  }) async {
    _logger.info('[API] getTrafficLogs: offset=$offset, limit=$limit');
    return await _authGet('/api/v1/user/getStat/getTrafficLog', queryParameters: {
      'offset': offset,
      'limit': limit,
    });
  }
}
