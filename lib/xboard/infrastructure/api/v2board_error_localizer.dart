import 'dart:ui';

/// V2Board 服务端验证错误本地化
///
/// V2Board (Laravel) 面板返回的验证错误通常是中文，
/// 本工具根据当前系统语言环境将其映射为对应语言。
/// 非中文环境下，将已知的中文错误信息翻译为英文。
class V2BoardErrorLocalizer {
  V2BoardErrorLocalizer._();

  /// 精确匹配：中文 → 英文
  static const _exactMap = <String, String>{
    // ── Auth / Login ──
    '邮箱或密码错误': 'Incorrect email or password',
    '邮箱已存在': 'Email already registered',
    '邮箱不存在': 'Email does not exist',
    '密码错误': 'Incorrect password',
    '邮箱格式不正确': 'Invalid email format',
    '邮箱不合法': 'Invalid email address',
    '两次密码输入不一致': 'Passwords do not match',
    '两次密码不一致': 'Passwords do not match',
    '登录失败': 'Login failed',
    '注册失败': 'Registration failed',

    // ── Account Status ──
    '账户已被禁用': 'Account has been disabled',
    '账户被禁用': 'Account has been disabled',
    '账号已被禁用': 'Account has been disabled',
    '账号被禁用': 'Account has been disabled',
    '用户已被禁用': 'User has been disabled',
    '账户已被冻结': 'Account has been frozen',
    '账户被冻结': 'Account has been frozen',
    '账户已过期': 'Account has expired',
    '账户不存在': 'Account does not exist',

    // ── Email Verification ──
    '验证码错误': 'Invalid verification code',
    '邮箱验证码错误': 'Invalid email verification code',
    '邮箱验证码已过期': 'Verification code has expired',
    '验证码已过期': 'Verification code has expired',
    '验证码无效': 'Invalid verification code',
    '验证码不存在': 'Verification code does not exist',
    '邮箱验证码发送失败': 'Failed to send verification code',
    '邮件发送失败': 'Failed to send email',
    '发送邮件失败': 'Failed to send email',
    '邮箱未验证': 'Email is not verified',

    // ── Invite Code ──
    '邀请码无效': 'Invalid invite code',
    '邀请码不存在': 'Invite code does not exist',
    '邀请码已被使用': 'Invite code has already been used',
    '该邀请码已达到使用上限': 'Invite code has reached its usage limit',
    '邀请码已过期': 'Invite code has expired',
    '邀请码已禁用': 'Invite code is disabled',

    // ── Password ──
    '原密码不正确': 'Current password is incorrect',
    '旧密码错误': 'Old password is incorrect',
    '新密码不能与旧密码相同': 'New password must differ from the old one',
    '密码修改失败': 'Failed to change password',
    '密码重置失败': 'Failed to reset password',

    // ── Token / Session ──
    'token过期': 'Session has expired',
    'token无效': 'Invalid session token',
    'token不存在': 'Session token not found',
    '认证失败': 'Authentication failed',
    '未登录': 'Not logged in',
    '登录已过期': 'Session has expired, please login again',
    '请先登录': 'Please login first',

    // ── Subscription ──
    '订阅已过期': 'Subscription has expired',
    '订阅未激活': 'Subscription is not activated',
    '无有效订阅': 'No active subscription',
    '没有有效订阅': 'No active subscription',
    '订阅已取消': 'Subscription has been cancelled',

    // ── Order ──
    '订单不存在': 'Order does not exist',
    '订单已取消': 'Order has been cancelled',
    '订单已完成': 'Order has been completed',
    '订单已过期': 'Order has expired',
    '订单状态异常': 'Abnormal order status',
    '创建订单失败': 'Failed to create order',

    // ── Payment ──
    '支付失败': 'Payment failed',
    '支付方式不可用': 'Payment method is unavailable',
    '无可用的支付方式': 'No available payment methods',
    '余额不足': 'Insufficient balance',

    // ── Coupon ──
    '优惠券无效': 'Invalid coupon',
    '优惠券已过期': 'Coupon has expired',
    '优惠券已被使用': 'Coupon has already been used',
    '优惠券码不存在': 'Coupon code does not exist',
    '优惠券不适用': 'Coupon is not applicable',
    '优惠券使用次数已满': 'Coupon usage limit reached',

    // ── Plan ──
    '套餐不存在': 'Plan does not exist',
    '套餐已下架': 'Plan is no longer available',
    '套餐不可购买': 'Plan is not available for purchase',

    // ── Ticket ──
    '工单不存在': 'Ticket does not exist',
    '工单已关闭': 'Ticket is closed',

    // ── Transfer / Commission ──
    '转账金额错误': 'Invalid transfer amount',
    '转账失败': 'Transfer failed',
    '余额转账失败': 'Balance transfer failed',
    '佣金提取失败': 'Commission withdrawal failed',

    // ── General ──
    '请求过于频繁': 'Too many requests, please try again later',
    '操作过于频繁': 'Too many requests, please try again later',
    '请稍后再试': 'Please try again later',
    '请求失败': 'Request failed',
    '未知错误': 'Unknown error',
    '遇到了些问题': 'An error occurred',
    '系统错误': 'System error',
    '导入失败': 'Import failed',
    'The given data was invalid.': 'The given data was invalid.',
  };

  /// 正则匹配：中文模式 → 英文模板（$1, $2 为捕获组）
  static final _patternMap = <RegExp, String>{
    RegExp(r'密码必须大于\s*(\d+)\s*个字符'):
        'Password must be at least \$1 characters',
    RegExp(r'密码不能少于\s*(\d+)\s*个字符'):
        'Password must be at least \$1 characters',
    RegExp(r'密码长度必须在\s*(\d+)\s*-\s*(\d+)\s*之间'):
        'Password must be between \$1 and \$2 characters',
    RegExp(r'(.+)不能为空'): '\$1 is required',
    RegExp(r'(.+)格式不正确'): 'Invalid \$1 format',
    RegExp(r'(.+)已存在'): '\$1 already exists',
    RegExp(r'(.+)不存在'): '\$1 does not exist',
    RegExp(r'(.+)必须大于\s*(\d+)\s*个字符'):
        '\$1 must be at least \$2 characters',
  };

  /// 字段名映射（用于正则替换中的字段名翻译）
  static const _fieldNameMap = <String, String>{
    '密码': 'Password',
    '邮箱': 'Email',
    '用户名': 'Username',
    '验证码': 'Verification code',
    '邀请码': 'Invite code',
    '优惠券': 'Coupon',
    '工单主题': 'Ticket subject',
    '工单内容': 'Ticket message',
  };

  /// 判断当前环境是否为中文
  static bool get _isChinese {
    final locale = PlatformDispatcher.instance.locale;
    return locale.languageCode == 'zh';
  }

  /// 本地化单条错误信息
  ///
  /// 中文环境直接返回原文，其他语言尝试翻译。
  static String localize(String message) {
    if (_isChinese) return message;

    final trimmed = message.trim();

    // 1. 精确匹配
    final exact = _exactMap[trimmed];
    if (exact != null) return exact;

    // 2. 正则匹配
    for (final entry in _patternMap.entries) {
      final match = entry.key.firstMatch(trimmed);
      if (match != null) {
        var result = entry.value;
        for (var i = 1; i <= match.groupCount; i++) {
          var group = match.group(i) ?? '';
          // 翻译捕获到的字段名
          group = _fieldNameMap[group] ?? group;
          result = result.replaceAll('\$$i', group);
        }
        return result;
      }
    }

    // 3. 无匹配，返回原文
    return message;
  }

  /// 本地化多条错误信息（用 [separator] 连接）
  static String localizeAll(List<String> messages, {String separator = '; '}) {
    return messages.map(localize).join(separator);
  }
}
