// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(rate) => "当前综合佣金返利比例：${rate}%";

  static String m1(count) => "${count} 天前";

  static String m2(label) => "确定删除选中的${label}吗？";

  static String m3(label) => "确定删除当前${label}吗？";

  static String m4(label) => "${label}详情";

  static String m5(label) => "${label}不能为空";

  static String m6(label) => "${label}当前已存在";

  static String m7(email) => "完整邮箱: ${email}";

  static String m8(count) => "${count} 小时前";

  static String m9(error) => "登出失败：${error}";

  static String m10(amount) => "最大可划转: ¥${amount}";

  static String m11(count) => "${count} 分钟前";

  static String m12(count) => "${count} 个月前";

  static String m13(label) => "暂无${label}";

  static String m14(label) => "${label}必须为数字";

  static String m15(statusCode) => "获取消息失败: ${statusCode}";

  static String m16(error) => "选择图片失败: ${error}";

  static String m17(method) => "不支持的HTTP方法: ${method}";

  static String m18(error) => "上传失败: ${error}";

  static String m19(amount) => "订单金额: ${amount}";

  static String m20(orderNo) => "订单: ${orderNo}";

  static String m21(page) => "第 ${page} 页";

  static String m22(label) => "${label} 必须在 1024 到 49151 之间";

  static String m23(e) => "注册失败: ${e}";

  static String m24(count) => "已选择 ${count} 项";

  static String m25(e) => "发送验证码失败: ${e}";

  static String m26(date) => "套餐已于 ${date} 过期，请续费后继续使用";

  static String m27(days) => "套餐将在 ${days} 天后过期，建议及时续费";

  static String m28(days) => "订阅将在 ${days} 天后过期";

  static String m29(count) => "共 ${count} 条记录";

  static String m30(amount) => "划转金额不能超过 ¥${amount}";

  static String m31(error) => "划转失败：${error}";

  static String m32(amount) => "划转成功！已划转 ¥${amount} 到钱包";

  static String m33(version) => "当前版本: ${version}";

  static String m34(version) => "强制更新: ${version}";

  static String m35(version) => "发现新版本: ${version}";

  static String m36(statusCode) => "服务器返回错误状态码 ${statusCode}";

  static String m37(label) => "${label}必须为URL";

  static String m38(email) => "验证码已发送到 ${email}，请查收并输入验证码和新密码";

  static String m39(error) => "提现失败：${error}";

  static String m40(amount) => "可提现金额: ${amount}";

  static String m41(count) => "已添加 ${count} 项规则";

  static String m42(error) => "检查支付状态失败: ${error}";

  static String m43(error) => "复制失败: ${error}";

  static String m44(limit) => "${limit} 设备";

  static String m45(traffic) => "下载: ${traffic}";

  static String m46(error) => "打开支付链接失败: ${error}";

  static String m47(error) => "打开支付页面失败: ${error}";

  static String m48(error) => "操作失败: ${error}";

  static String m49(message) => "支付失败: ${message}";

  static String m50(planId) => "套餐 #${planId}";

  static String m51(url) => "代理(${url})";

  static String m52(days) => "${days} 天";

  static String m53(attempt) => "第 ${attempt} 次尝试失败，等待重试...";

  static String m54(time) => "运行时间: ${time}";

  static String m55(traffic) => "上传: ${traffic}";

  static String m56(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "accessControl": MessageLookupByLibrary.simpleMessage("访问控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "只允许选中应用进入VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage("配置应用访问代理"),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "选中应用将会被排除在VPN之外",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("访问控制设置"),
    "account": MessageLookupByLibrary.simpleMessage("账号"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "action_mode": MessageLookupByLibrary.simpleMessage("切换模式"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "action_start": MessageLookupByLibrary.simpleMessage("启动/停止"),
    "action_tun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "action_view": MessageLookupByLibrary.simpleMessage("显示/隐藏"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addProfile": MessageLookupByLibrary.simpleMessage("添加配置"),
    "addRule": MessageLookupByLibrary.simpleMessage("添加规则"),
    "addedOriginRules": MessageLookupByLibrary.simpleMessage("附加到原始规则"),
    "addedRules": MessageLookupByLibrary.simpleMessage("附加规则"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV服务器地址"),
    "addressTip": MessageLookupByLibrary.simpleMessage("请输入有效的WebDAV地址"),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage("管理员自启动"),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage("使用管理员模式开机自启动"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("进阶配置"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage("提供多样化配置"),
    "ago": MessageLookupByLibrary.simpleMessage("前"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allApps": MessageLookupByLibrary.simpleMessage("所有应用"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("允许应用绕过VPN"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage("开启后部分应用可绕过VPN"),
    "allowLan": MessageLookupByLibrary.simpleMessage("局域网代理"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("允许通过局域网访问代理"),
    "alreadyHaveAccount": MessageLookupByLibrary.simpleMessage("已有账号？"),
    "app": MessageLookupByLibrary.simpleMessage("应用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("应用访问控制"),
    "appDesc": MessageLookupByLibrary.simpleMessage("处理应用相关设置"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("追加系统DNS"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage("强制为配置附加系统DNS"),
    "application": MessageLookupByLibrary.simpleMessage("应用程序"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("修改应用程序相关设置"),
    "applicationSettings": MessageLookupByLibrary.simpleMessage("应用设置"),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage("应用启动时自动检查更新"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("自动关闭连接"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "切换节点后自动关闭连接",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自启动"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage("跟随系统自启动"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自动运行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("应用打开时自动运行"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("自动设置系统DNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔（分钟）"),
    "availableCommission": MessageLookupByLibrary.simpleMessage("可用佣金"),
    "backToLogin": MessageLookupByLibrary.simpleMessage("返回登录"),
    "backup": MessageLookupByLibrary.simpleMessage("备份"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage("备份与恢复"),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "通过WebDAV或者文件同步数据",
    ),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("备份与恢复"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "通过WebDAV或者文件同步数据",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("备份成功"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("基本配置"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage("全局修改基本配置"),
    "bind": MessageLookupByLibrary.simpleMessage("绑定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名单模式"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("排除域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage("仅在系统代理启用时生效"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage("缓存已损坏，是否清空？"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage("取消过滤系统应用"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("取消全选"),
    "cannotGetWebUrl": MessageLookupByLibrary.simpleMessage("无法获取网页地址，请联系客服"),
    "cannotOpenBrowser": MessageLookupByLibrary.simpleMessage(
      "无法打开浏览器，请手动访问网页版",
    ),
    "cannotSelectSpecialProxy": MessageLookupByLibrary.simpleMessage(
      "无法选择 DIRECT 或 REJECT 特殊节点",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("检测失败"),
    "checkNetwork": MessageLookupByLibrary.simpleMessage("请检查网络连接后重试"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("当前应用已经是最新版了"),
    "checking": MessageLookupByLibrary.simpleMessage("检测中..."),
    "clearData": MessageLookupByLibrary.simpleMessage("清除数据"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("导出剪贴板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("剪贴板导入"),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "color": MessageLookupByLibrary.simpleMessage("颜色"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("配色方案"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "commissionHistory": MessageLookupByLibrary.simpleMessage("佣金历史"),
    "commissionRate": MessageLookupByLibrary.simpleMessage("佣金比例"),
    "commissionSettled": MessageLookupByLibrary.simpleMessage(
      "佣金将在好友订阅成功后结算到账户",
    ),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "开启将失去部分应用能力，获得全量的Clash的支持",
    ),
    "complete": MessageLookupByLibrary.simpleMessage("完成"),
    "completeWithdrawal": MessageLookupByLibrary.simpleMessage(
      "网页版提供更完整的提现功能和支付方式选择",
    ),
    "configurationError": MessageLookupByLibrary.simpleMessage("应用配置异常，请联系客服"),
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage("确定要清除所有数据？"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage("确定要强制崩溃核心？"),
    "confirmLogout": MessageLookupByLibrary.simpleMessage("确认登出"),
    "confirmNewPassword": MessageLookupByLibrary.simpleMessage("确认新密码"),
    "confirmTransfer": MessageLookupByLibrary.simpleMessage("确认划转"),
    "confirmWithdraw": MessageLookupByLibrary.simpleMessage("确认提现"),
    "connected": MessageLookupByLibrary.simpleMessage("已连接"),
    "connecting": MessageLookupByLibrary.simpleMessage("连接中..."),
    "connection": MessageLookupByLibrary.simpleMessage("连接"),
    "connections": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("查看当前连接数据"),
    "connectivity": MessageLookupByLibrary.simpleMessage("连通性："),
    "contactMe": MessageLookupByLibrary.simpleMessage("联系我"),
    "contactSupport": MessageLookupByLibrary.simpleMessage("联系客服"),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("内容主题"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage("控制全局附加规则"),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("复制环境变量"),
    "copyInviteLink": MessageLookupByLibrary.simpleMessage("复制邀请链接"),
    "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "core": MessageLookupByLibrary.simpleMessage("内核"),
    "coreConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "检测到核心配置更改",
    ),
    "coreInfo": MessageLookupByLibrary.simpleMessage("内核信息"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心状态"),
    "country": MessageLookupByLibrary.simpleMessage("区域"),
    "crashTest": MessageLookupByLibrary.simpleMessage("崩溃测试"),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "createAccount": MessageLookupByLibrary.simpleMessage("创建账号"),
    "creationTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "credentialsSaved": MessageLookupByLibrary.simpleMessage("凭据已保存"),
    "currentCommissionRate": m0,
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "days": MessageLookupByLibrary.simpleMessage("天"),
    "daysAgo": m1,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("默认域名服务器"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析DNS服务器"),
    "defaultSort": MessageLookupByLibrary.simpleMessage("按默认排序"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delaySort": MessageLookupByLibrary.simpleMessage("按延迟排序"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延迟测试"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteMultipTip": m2,
    "deleteTip": m3,
    "desc": MessageLookupByLibrary.simpleMessage(
      "基于ClashMeta的多平台代理客户端，简单易用，开源无广告。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目标地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目标地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目标IP ASN"),
    "details": m4,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依赖第三方api，仅供参考"),
    "developerMode": MessageLookupByLibrary.simpleMessage("开发者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("开发者模式已启用。"),
    "direct": MessageLookupByLibrary.simpleMessage("直连"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本软件仅供学习交流、科研等非商业性质的用途，严禁将本软件用于商业目的。如有任何商业行为，均与本软件无关。",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "discovery": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("更新DNS相关设置"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage("是否要通过"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "domainStatusAvailable": MessageLookupByLibrary.simpleMessage("服务可用"),
    "domainStatusChecking": MessageLookupByLibrary.simpleMessage("检查中..."),
    "domainStatusUnavailable": MessageLookupByLibrary.simpleMessage("服务不可用"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("编辑全局规则"),
    "editRule": MessageLookupByLibrary.simpleMessage("编辑规则"),
    "emailAddress": MessageLookupByLibrary.simpleMessage("邮箱地址"),
    "emailPrefixHint": MessageLookupByLibrary.simpleMessage("邮箱前缀"),
    "emailVerificationCode": MessageLookupByLibrary.simpleMessage("邮箱验证码"),
    "emptyTip": m5,
    "en": MessageLookupByLibrary.simpleMessage("英语"),
    "enableOverride": MessageLookupByLibrary.simpleMessage("启用覆写"),
    "enterEmailForReset": MessageLookupByLibrary.simpleMessage(
      "请输入您的邮箱地址，我们会发送验证码到您的邮箱",
    ),
    "enterTransferAmount": MessageLookupByLibrary.simpleMessage("请输入划转金额"),
    "enterTransferAmountError": MessageLookupByLibrary.simpleMessage("请输入划转金额"),
    "enterWithdrawAccount": MessageLookupByLibrary.simpleMessage("请输入提现账号"),
    "entries": MessageLookupByLibrary.simpleMessage("个条目"),
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage("应用在后台时,从最近任务中隐藏应用"),
    "existsTip": m6,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "expand": MessageLookupByLibrary.simpleMessage("标准"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("表现力"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "开启后将可以通过9090端口控制Clash内核",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部获取"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "externalResources": MessageLookupByLibrary.simpleMessage("外部资源"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip过滤"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip范围"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("一般情况下使用境外DNS"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback过滤"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("高保真"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage("文件有修改，是否保存修改"),
    "fillInfoToRegister": MessageLookupByLibrary.simpleMessage("请填写以下信息完成注册"),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage("过滤系统应用"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找进程"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage("开启后会有一定性能损耗"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字体"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要强制重启核心吗？"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("忘记密码"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("四列"),
    "friendInviteReward": MessageLookupByLibrary.simpleMessage(
      "好友邀请的人成功消费，您也能赚取佣金",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("果缤纷"),
    "fullEmailPreview": m7,
    "general": MessageLookupByLibrary.simpleMessage("常规"),
    "generalDesc": MessageLookupByLibrary.simpleMessage("修改通用设置"),
    "generatingInviteCode": MessageLookupByLibrary.simpleMessage("正在生成邀请码..."),
    "geoData": MessageLookupByLibrary.simpleMessage("地理数据"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低内存模式"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage("开启将使用Geo低内存加载器"),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Geoip代码"),
    "getOriginRules": MessageLookupByLibrary.simpleMessage("获取原始规则"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下载"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("前往配置脚本"),
    "goToWeb": MessageLookupByLibrary.simpleMessage("前往网页"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("是否缓存修改"),
    "host": MessageLookupByLibrary.simpleMessage("主机"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("追加Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("快捷键冲突"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("快捷键管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage("使用键盘控制应用程序"),
    "hours": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursAgo": m8,
    "iUnderstand": MessageLookupByLibrary.simpleMessage("我知道了"),
    "icon": MessageLookupByLibrary.simpleMessage("图片"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage("图片配置"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "import": MessageLookupByLibrary.simpleMessage("导入"),
    "importFile": MessageLookupByLibrary.simpleMessage("通过文件导入"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("从URL导入"),
    "importUrl": MessageLookupByLibrary.simpleMessage("通过URL导入"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("长期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage("请输入正确的快捷键"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("智能选择"),
    "internet": MessageLookupByLibrary.simpleMessage("互联网"),
    "interval": MessageLookupByLibrary.simpleMessage("间隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("内网 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("无效备份文件"),
    "invalidEmailFormat": MessageLookupByLibrary.simpleMessage("邮箱格式不正确"),
    "invalidTransferAmount": MessageLookupByLibrary.simpleMessage("请输入有效的划转金额"),
    "invite": MessageLookupByLibrary.simpleMessage("邀请"),
    "inviteCode": MessageLookupByLibrary.simpleMessage("邀请码"),
    "inviteCodeGenFailed": MessageLookupByLibrary.simpleMessage("邀请码生成失败"),
    "inviteCodeIncorrect": MessageLookupByLibrary.simpleMessage(
      "邀请码可能不正确，请检查后重新输入",
    ),
    "inviteCodeOptional": MessageLookupByLibrary.simpleMessage("邀请码（可选）"),
    "inviteCodeRequired": MessageLookupByLibrary.simpleMessage("需要邀请码"),
    "inviteCodeRequiredMessage": MessageLookupByLibrary.simpleMessage(
      "注册需要邀请码，请联系已注册用户获取邀请码后再进行注册。",
    ),
    "inviteLinkCopied": MessageLookupByLibrary.simpleMessage("邀请链接已复制，可分享给好友"),
    "inviteRegisterReward": MessageLookupByLibrary.simpleMessage(
      "邀请好友注册并成功订阅，即可获得佣金奖励",
    ),
    "inviteRules": MessageLookupByLibrary.simpleMessage("邀请规则"),
    "inviteStats": MessageLookupByLibrary.simpleMessage("邀请统计"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/掩码"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("开启后将可以接收IPv6流量"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("允许IPv6入站"),
    "ja": MessageLookupByLibrary.simpleMessage("日语"),
    "just": MessageLookupByLibrary.simpleMessage("刚刚"),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活动间隔"),
    "key": MessageLookupByLibrary.simpleMessage("键"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("监听"),
    "loadMore": MessageLookupByLibrary.simpleMessage("加载更多"),
    "loadTest": MessageLookupByLibrary.simpleMessage("加载测试"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("备份数据到本地"),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage("通过文件恢复数据"),
    "log": MessageLookupByLibrary.simpleMessage("日志"),
    "logLevel": MessageLookupByLibrary.simpleMessage("日志等级"),
    "logcat": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("禁用将会隐藏日志入口"),
    "loggedOutSuccess": MessageLookupByLibrary.simpleMessage("已成功登出"),
    "loginNow": MessageLookupByLibrary.simpleMessage("立即登录"),
    "logout": MessageLookupByLibrary.simpleMessage("登出"),
    "logoutConfirmMsg": MessageLookupByLibrary.simpleMessage(
      "确定要登出当前账户吗？登出后需要重新登录。",
    ),
    "logoutFailed": m9,
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("日志捕获记录"),
    "logsTest": MessageLookupByLibrary.simpleMessage("日志测试"),
    "loopback": MessageLookupByLibrary.simpleMessage("回环解锁工具"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("用于UWP回环解锁"),
    "loose": MessageLookupByLibrary.simpleMessage("宽松"),
    "maxTransferable": m10,
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "messageTest": MessageLookupByLibrary.simpleMessage("消息测试"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("这是一条消息。"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage("修改系统默认退出事件"),
    "minutes": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesAgo": m11,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("单色"),
    "months": MessageLookupByLibrary.simpleMessage("月"),
    "monthsAgo": m12,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "myInviteQr": MessageLookupByLibrary.simpleMessage("我的邀请二维码"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "nameSort": MessageLookupByLibrary.simpleMessage("按名称排序"),
    "nameserver": MessageLookupByLibrary.simpleMessage("域名服务器"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析域名"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("域名服务器策略"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage("指定对应域名服务器策略"),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("修改网络相关设置"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("网络检测"),
    "networkException": MessageLookupByLibrary.simpleMessage("网络异常，请检查连接后重试"),
    "networkRequestException": MessageLookupByLibrary.simpleMessage(
      "网络请求异常，请稍后再试。",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("中性"),
    "newMessageFromSupport": MessageLookupByLibrary.simpleMessage("客服新消息"),
    "newPassword": MessageLookupByLibrary.simpleMessage("新密码"),
    "noAccount": MessageLookupByLibrary.simpleMessage("还没有账号？"),
    "noCommissionRecord": MessageLookupByLibrary.simpleMessage("暂无佣金记录"),
    "noData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("暂无快捷键"),
    "noIcon": MessageLookupByLibrary.simpleMessage("无图标"),
    "noInfo": MessageLookupByLibrary.simpleMessage("暂无信息"),
    "noInvitationData": MessageLookupByLibrary.simpleMessage("暂无邀请数据"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("不再提示"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("暂无更多信息"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("无网络"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("无网络应用"),
    "noProxy": MessageLookupByLibrary.simpleMessage("暂无代理"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage("请创建配置文件或者添加有效配置文件"),
    "noResolve": MessageLookupByLibrary.simpleMessage("不解析IP"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("当前代理组无法选中"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("没有配置文件,请先添加配置文件"),
    "nullTip": m13,
    "numberTip": m14,
    "oneColumn": MessageLookupByLibrary.simpleMessage("一列"),
    "onlineSupport": MessageLookupByLibrary.simpleMessage("在线客服"),
    "onlineSupportAddMore": MessageLookupByLibrary.simpleMessage("添加更多"),
    "onlineSupportApiConfigNotFound": MessageLookupByLibrary.simpleMessage(
      "在线客服API配置未找到，请检查配置",
    ),
    "onlineSupportCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "onlineSupportClearHistory": MessageLookupByLibrary.simpleMessage("清除历史记录"),
    "onlineSupportClearHistoryConfirm": MessageLookupByLibrary.simpleMessage(
      "确定要清除所有聊天历史记录吗？此操作不可恢复。",
    ),
    "onlineSupportClickToSelect": MessageLookupByLibrary.simpleMessage(
      "点击选择图片",
    ),
    "onlineSupportConfirm": MessageLookupByLibrary.simpleMessage("确定"),
    "onlineSupportConnected": MessageLookupByLibrary.simpleMessage("成功连接客服系统"),
    "onlineSupportConnecting": MessageLookupByLibrary.simpleMessage("连接中..."),
    "onlineSupportConnectionError": MessageLookupByLibrary.simpleMessage(
      "连接错误",
    ),
    "onlineSupportDisconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "onlineSupportGetMessagesFailed": m15,
    "onlineSupportInputHint": MessageLookupByLibrary.simpleMessage(
      "请输入您的问题...",
    ),
    "onlineSupportNoMessages": MessageLookupByLibrary.simpleMessage(
      "暂无消息，发送消息开始咨询",
    ),
    "onlineSupportSelectImages": MessageLookupByLibrary.simpleMessage("选择图片"),
    "onlineSupportSelectImagesFailed": m16,
    "onlineSupportSend": MessageLookupByLibrary.simpleMessage("发送"),
    "onlineSupportSendImage": MessageLookupByLibrary.simpleMessage("发送图片"),
    "onlineSupportSendMessageFailed": MessageLookupByLibrary.simpleMessage(
      "发送消息失败: 无法获取认证token",
    ),
    "onlineSupportSupportedFormats": MessageLookupByLibrary.simpleMessage(
      "支持 JPG, PNG, GIF, WebP, BMP\n最大 10MB",
    ),
    "onlineSupportTitle": MessageLookupByLibrary.simpleMessage("在线客服"),
    "onlineSupportTokenNotFound": MessageLookupByLibrary.simpleMessage(
      "未找到认证token",
    ),
    "onlineSupportUnsupportedHttpMethod": m17,
    "onlineSupportUploadFailed": m18,
    "onlineSupportWebSocketConfigNotFound":
        MessageLookupByLibrary.simpleMessage("在线客服WebSocket配置未找到，请检查配置"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("仅图标"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage("仅第三方应用"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("仅统计代理"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "开启后，将只统计代理流量",
    ),
    "openWebFailed": MessageLookupByLibrary.simpleMessage("打开网页失败，请手动访问网页版"),
    "options": MessageLookupByLibrary.simpleMessage("选项"),
    "orderAmount": m19,
    "orderNumber": m20,
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("其他贡献者"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "override": MessageLookupByLibrary.simpleMessage("覆写"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage("覆写代理相关配置"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("覆写DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage("开启后将覆盖配置中的DNS选项"),
    "overrideInvalidTip": MessageLookupByLibrary.simpleMessage("在脚本模式下不生效"),
    "overrideMode": MessageLookupByLibrary.simpleMessage("覆写模式"),
    "overrideOriginRules": MessageLookupByLibrary.simpleMessage("覆盖原始规则"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("覆写脚本"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "自定义模式，支持完全自定义修改代理组以及规则",
    ),
    "pageNumber": m21,
    "palette": MessageLookupByLibrary.simpleMessage("调色板"),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "passwordMin8Chars": MessageLookupByLibrary.simpleMessage("密码至少需要8位字符"),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage("密码长度至少6位"),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage("两次输入的密码不一致"),
    "passwordResetFailed": MessageLookupByLibrary.simpleMessage("密码重置失败"),
    "passwordResetSuccessful": MessageLookupByLibrary.simpleMessage(
      "密码重置成功！请使用新密码登录",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage("两次输入的密码不一致"),
    "paste": MessageLookupByLibrary.simpleMessage("粘贴"),
    "pendingCommission": MessageLookupByLibrary.simpleMessage("待确认佣金"),
    "plans": MessageLookupByLibrary.simpleMessage("套餐"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("请绑定WebDAV"),
    "pleaseConfirmNewPassword": MessageLookupByLibrary.simpleMessage(
      "请再次输入新密码",
    ),
    "pleaseConfirmPassword": MessageLookupByLibrary.simpleMessage("请确认密码"),
    "pleaseEnterAtLeast8CharsPassword": MessageLookupByLibrary.simpleMessage(
      "请输入至少8位密码",
    ),
    "pleaseEnterEmail": MessageLookupByLibrary.simpleMessage("请输入邮箱地址"),
    "pleaseEnterEmailAddress": MessageLookupByLibrary.simpleMessage("请先输入邮箱地址"),
    "pleaseEnterEmailPrefix": MessageLookupByLibrary.simpleMessage("请输入邮箱前缀"),
    "pleaseEnterEmailVerificationCode": MessageLookupByLibrary.simpleMessage(
      "请输入邮箱验证码",
    ),
    "pleaseEnterInviteCode": MessageLookupByLibrary.simpleMessage("请输入邀请码"),
    "pleaseEnterNewPassword": MessageLookupByLibrary.simpleMessage("请输入新密码"),
    "pleaseEnterPassword": MessageLookupByLibrary.simpleMessage("请输入密码"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage("请输入脚本名称"),
    "pleaseEnterValidEmail": MessageLookupByLibrary.simpleMessage("请输入有效的邮箱地址"),
    "pleaseEnterValidEmailAddress": MessageLookupByLibrary.simpleMessage(
      "请输入有效的邮箱地址",
    ),
    "pleaseEnterValidVerificationCode": MessageLookupByLibrary.simpleMessage(
      "请输入有效的验证码",
    ),
    "pleaseEnterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "请输入邮箱验证码",
    ),
    "pleaseEnterYourEmailAddress": MessageLookupByLibrary.simpleMessage(
      "请输入您的邮箱地址",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "请输入管理员密码",
    ),
    "pleaseReEnterPassword": MessageLookupByLibrary.simpleMessage("请再次输入密码"),
    "pleaseSelectEmailSuffix": MessageLookupByLibrary.simpleMessage("请选择邮箱后缀"),
    "pleaseSelectSuffix": MessageLookupByLibrary.simpleMessage("请选择后缀"),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage("请上传文件"),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "请上传有效的二维码",
    ),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("请输入不同的端口"),
    "portTip": m22,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("优先使用DOH的http/3"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("请按下按键"),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "process": MessageLookupByLibrary.simpleMessage("进程"),
    "profile": MessageLookupByLibrary.simpleMessage("配置"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入有效间隔时间格式"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入自动更新间隔时间"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已经修改,是否关闭自动更新 ",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置名称",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage("配置文件解析错误"),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入有效配置URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置排序"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "providers": MessageLookupByLibrary.simpleMessage("提供者"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("代理设置"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("代理链"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("代理组"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("代理域名服务器"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析代理节点的域名"),
    "proxyPort": MessageLookupByLibrary.simpleMessage("代理端口"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage("设置Clash监听端口"),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理提供者"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("修剪缓存"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("纯黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("二维码"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("扫描二维码获取配置文件"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("彩虹"),
    "recovery": MessageLookupByLibrary.simpleMessage("恢复"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage("仅恢复配置文件"),
    "recoveryStrategy": MessageLookupByLibrary.simpleMessage("恢复策略"),
    "recoveryStrategy_compatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "recoveryStrategy_override": MessageLookupByLibrary.simpleMessage("覆盖"),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir端口"),
    "redo": MessageLookupByLibrary.simpleMessage("重做"),
    "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "regExp": MessageLookupByLibrary.simpleMessage("正则"),
    "registerAccount": MessageLookupByLibrary.simpleMessage("注册账号"),
    "registerSuccessSaveCredentials": MessageLookupByLibrary.simpleMessage(
      "注册成功 - 保存凭据:",
    ),
    "registrationFailed": m23,
    "reload": MessageLookupByLibrary.simpleMessage("重载"),
    "rememberPassword": MessageLookupByLibrary.simpleMessage("记起密码了？"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage("备份数据到WebDAV"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("远程目标"),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage("通过WebDAV恢复数据"),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "request": MessageLookupByLibrary.simpleMessage("请求"),
    "requests": MessageLookupByLibrary.simpleMessage("请求"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("查看最近请求记录"),
    "resendVerificationCode": MessageLookupByLibrary.simpleMessage("重新发送验证码"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "当前页面存在更改，确定重置吗？",
    ),
    "resetPassword": MessageLookupByLibrary.simpleMessage("重置密码"),
    "resetTip": MessageLookupByLibrary.simpleMessage("确定要重置吗?"),
    "resources": MessageLookupByLibrary.simpleMessage("资源"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部资源相关信息"),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵守规则"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS连接跟随rules,需配置proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("重启"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要重启核心吗？"),
    "restore": MessageLookupByLibrary.simpleMessage("恢复"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "restoreException": MessageLookupByLibrary.simpleMessage("恢复异常"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage("通过文件恢复数据"),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "通过WebDAV恢复数据",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("仅恢复配置文件"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("恢复策略"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage("覆盖"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage("配置监听路由地址"),
    "routeMode": MessageLookupByLibrary.simpleMessage("路由模式"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage("绕过私有路由地址"),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("使用配置"),
    "ru": MessageLookupByLibrary.simpleMessage("俄语"),
    "rule": MessageLookupByLibrary.simpleMessage("规则"),
    "ruleName": MessageLookupByLibrary.simpleMessage("规则名称"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("规则提供者"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("规则目标"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "saveQr": MessageLookupByLibrary.simpleMessage("保存二维码"),
    "saveQrCodeFeature": MessageLookupByLibrary.simpleMessage(
      "保存二维码功能开发中，敬请期待",
    ),
    "saveTip": MessageLookupByLibrary.simpleMessage("确定要保存吗？"),
    "script": MessageLookupByLibrary.simpleMessage("脚本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "脚本模式，使用外部扩展脚本，提供一键覆写配置的能力",
    ),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selectTheme": MessageLookupByLibrary.simpleMessage("选择主题"),
    "selectWithdrawMethod": MessageLookupByLibrary.simpleMessage("请选择提现方式"),
    "selected": MessageLookupByLibrary.simpleMessage("已选择"),
    "selectedCountTitle": m24,
    "sendCodeFailed": MessageLookupByLibrary.simpleMessage("发送验证码失败"),
    "sendVerificationCode": MessageLookupByLibrary.simpleMessage("发送验证码"),
    "sendVerificationCodeFailed": m25,
    "setNewPassword": MessageLookupByLibrary.simpleMessage("设置新密码"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "shrink": MessageLookupByLibrary.simpleMessage("紧凑"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("静默启动"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("后台启动"),
    "size": MessageLookupByLibrary.simpleMessage("尺寸"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks端口"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("来源"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("源IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊代理"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊规则"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("网速统计"),
    "stackMode": MessageLookupByLibrary.simpleMessage("栈模式"),
    "standard": MessageLookupByLibrary.simpleMessage("标准"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "标准模式，覆写基本配置，提供简单追加规则能力",
    ),
    "start": MessageLookupByLibrary.simpleMessage("启动"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在启动VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("状态"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("关闭后将使用系统DNS"),
    "stop": MessageLookupByLibrary.simpleMessage("暂停"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("风格"),
    "subRule": MessageLookupByLibrary.simpleMessage("子规则"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("订阅已过期"),
    "subscriptionExpiredDetail": m26,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage("订阅今日过期"),
    "subscriptionExpiresTodayDetail": MessageLookupByLibrary.simpleMessage(
      "套餐将在今日过期，请立即续费以免影响使用",
    ),
    "subscriptionExpiringInDays": MessageLookupByLibrary.simpleMessage(
      "订阅即将过期",
    ),
    "subscriptionExpiringInDaysDetail": m27,
    "subscriptionNoSubscription": MessageLookupByLibrary.simpleMessage("无订阅套餐"),
    "subscriptionNoSubscriptionDetail": MessageLookupByLibrary.simpleMessage(
      "当前账户暂无可用的订阅套餐，请购买套餐后使用",
    ),
    "subscriptionNotLoggedIn": MessageLookupByLibrary.simpleMessage("未登录"),
    "subscriptionNotLoggedInDetail": MessageLookupByLibrary.simpleMessage(
      "请先登录账户",
    ),
    "subscriptionParseFailed": MessageLookupByLibrary.simpleMessage("订阅配置解析失败"),
    "subscriptionParseFailedDetail": MessageLookupByLibrary.simpleMessage(
      "无法获取订阅配置，请检查网络连接或点击刷新重试",
    ),
    "subscriptionTrafficExhausted": MessageLookupByLibrary.simpleMessage(
      "流量已用完",
    ),
    "subscriptionTrafficExhaustedDetail": MessageLookupByLibrary.simpleMessage(
      "套餐流量已用完，请购买更多流量或升级套餐",
    ),
    "subscriptionValid": MessageLookupByLibrary.simpleMessage("订阅有效"),
    "subscriptionValidDetail": m28,
    "switchTheme": MessageLookupByLibrary.simpleMessage("切换主题"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "systemApp": MessageLookupByLibrary.simpleMessage("系统应用"),
    "systemFont": MessageLookupByLibrary.simpleMessage("系统字体"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("设置系统代理"),
    "tab": MessageLookupByLibrary.simpleMessage("标签页"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("选项卡动画"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage("仅在移动视图中有效"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP并发"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage("开启后允许TCP并发"),
    "testUrl": MessageLookupByLibrary.simpleMessage("测速链接"),
    "textScale": MessageLookupByLibrary.simpleMessage("文本缩放"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色彩"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("设置深色模式，调整色彩"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("三列"),
    "tight": MessageLookupByLibrary.simpleMessage("紧凑"),
    "time": MessageLookupByLibrary.simpleMessage("时间"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("调性点缀"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "totalCommission": MessageLookupByLibrary.simpleMessage("累计佣金"),
    "totalInvites": MessageLookupByLibrary.simpleMessage("总邀请数"),
    "totalRecords": m29,
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量统计"),
    "transfer": MessageLookupByLibrary.simpleMessage("划转"),
    "transferAmount": MessageLookupByLibrary.simpleMessage("划转金额"),
    "transferAmountExceeded": m30,
    "transferFailed": m31,
    "transferNote": MessageLookupByLibrary.simpleMessage("划转到钱包的余额可以抵扣app内消费"),
    "transferSuccess": MessageLookupByLibrary.simpleMessage("划转成功！"),
    "transferSuccessMsg": m32,
    "transferToWallet": MessageLookupByLibrary.simpleMessage("划转到钱包"),
    "transferring": MessageLookupByLibrary.simpleMessage("正在划转..."),
    "tun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("仅在管理员模式生效"),
    "turnOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "turnOn": MessageLookupByLibrary.simpleMessage("开启"),
    "twoColumns": MessageLookupByLibrary.simpleMessage("两列"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "无法更新当前配置文件",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("统一延迟"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage("去除握手等额外延迟"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("未知网络错误"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateCheckAllServersUnavailable": MessageLookupByLibrary.simpleMessage(
      "所有配置的更新服务器都不可用",
    ),
    "updateCheckCurrentVersion": m33,
    "updateCheckForceUpdate": m34,
    "updateCheckMustUpdate": MessageLookupByLibrary.simpleMessage("必须更新"),
    "updateCheckNewVersionFound": m35,
    "updateCheckNoServerUrlsConfigured": MessageLookupByLibrary.simpleMessage(
      "未配置任何更新服务器URL，请检查配置",
    ),
    "updateCheckReleaseNotes": MessageLookupByLibrary.simpleMessage("更新内容："),
    "updateCheckServerError": m36,
    "updateCheckServerTemporarilyUnavailable":
        MessageLookupByLibrary.simpleMessage("服务器暂时不可用，请稍后重试"),
    "updateCheckServerUrlNotConfigured": MessageLookupByLibrary.simpleMessage(
      "未配置更新服务器URL，请检查配置",
    ),
    "updateCheckUpdateLater": MessageLookupByLibrary.simpleMessage("稍后更新"),
    "updateCheckUpdateNow": MessageLookupByLibrary.simpleMessage("立即更新"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("通过URL获取配置文件"),
    "urlTip": m37,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统Hosts"),
    "userCenter": MessageLookupByLibrary.simpleMessage("个人中心"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "verificationCode": MessageLookupByLibrary.simpleMessage("验证码"),
    "verificationCode6Digits": MessageLookupByLibrary.simpleMessage(
      "验证码应为6位数字",
    ),
    "verificationCodeSent": MessageLookupByLibrary.simpleMessage(
      "验证码已发送到您的邮箱，请查收",
    ),
    "verificationCodeSentCheckEmail": MessageLookupByLibrary.simpleMessage(
      "验证码已发送，请查收邮箱",
    ),
    "verificationCodeSentTo": m38,
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("活力"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "viewHistory": MessageLookupByLibrary.simpleMessage("查看历史记录"),
    "visitWebVersion": MessageLookupByLibrary.simpleMessage("请前往网页版提交提现申请"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "检测到VPN相关配置改动",
    ),
    "vpnDesc": MessageLookupByLibrary.simpleMessage("修改VPN相关设置"),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "通过VpnService自动路由系统所有流量",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "为VpnService附加HTTP代理",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("重启VPN后改变生效"),
    "walletBalance": MessageLookupByLibrary.simpleMessage("钱包余额"),
    "walletDetails": MessageLookupByLibrary.simpleMessage("钱包详情"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV配置"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名单模式"),
    "withdraw": MessageLookupByLibrary.simpleMessage("提现"),
    "withdrawAccount": MessageLookupByLibrary.simpleMessage("提现账号"),
    "withdrawClosed": MessageLookupByLibrary.simpleMessage("提现功能暂未开放"),
    "withdrawCommission": MessageLookupByLibrary.simpleMessage("提现佣金"),
    "withdrawFailed": m39,
    "withdrawMethod": MessageLookupByLibrary.simpleMessage("提现方式"),
    "withdrawSubmitted": MessageLookupByLibrary.simpleMessage("提现申请已提交"),
    "withdrawableAmount": m40,
    "withdrawalAvailable": MessageLookupByLibrary.simpleMessage("可用佣金可申请提现"),
    "withdrawing": MessageLookupByLibrary.simpleMessage("正在提交..."),
    "xboard": MessageLookupByLibrary.simpleMessage("首页"),
    "xboard24HourCustomerService": MessageLookupByLibrary.simpleMessage(
      "24小时客服支持",
    ),
    "xboardAccountBalance": MessageLookupByLibrary.simpleMessage("账户余额"),
    "xboardAccountInfo": MessageLookupByLibrary.simpleMessage("账户信息"),
    "xboardAccountSettings": MessageLookupByLibrary.simpleMessage("账户设置"),
    "xboardActive": MessageLookupByLibrary.simpleMessage("生效中"),
    "xboardAddLinkToConfig": MessageLookupByLibrary.simpleMessage(
      "在配置文件中添加此订阅链接",
    ),
    "xboardAddingProfile": MessageLookupByLibrary.simpleMessage("正在添加配置文件"),
    "xboardAddingToConfigList": MessageLookupByLibrary.simpleMessage("添加到配置列表"),
    "xboardAfterPurchasingPlan": MessageLookupByLibrary.simpleMessage(
      "购买套餐后您将享受：",
    ),
    "xboardAllDownloadTasksFailed": MessageLookupByLibrary.simpleMessage(
      "所有下载任务都失败了",
    ),
    "xboardAllOrders": MessageLookupByLibrary.simpleMessage("全部"),
    "xboardAllowLan": MessageLookupByLibrary.simpleMessage("共享到局域网"),
    "xboardApiUrlNotConfigured": MessageLookupByLibrary.simpleMessage(
      "API地址未配置",
    ),
    "xboardAppearance": MessageLookupByLibrary.simpleMessage("外观"),
    "xboardAutoCheckEvery5Seconds": MessageLookupByLibrary.simpleMessage(
      "系统每5秒自动检查一次，支付完成后会自动跳转",
    ),
    "xboardAutoCheckPaymentDesc": MessageLookupByLibrary.simpleMessage(
      "系统每5秒自动检查一次，支付完成后会自动跳转",
    ),
    "xboardAutoDetectPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "自动检测支付状态",
    ),
    "xboardAutoOpeningPayment": MessageLookupByLibrary.simpleMessage(
      "正在自动打开支付页面，完成支付后请返回应用",
    ),
    "xboardAutoOpeningPaymentPage": MessageLookupByLibrary.simpleMessage(
      "正在自动打开支付页面，完成支付后请返回应用",
    ),
    "xboardAutoTesting": MessageLookupByLibrary.simpleMessage("自动测试中"),
    "xboardAvailableCommission": MessageLookupByLibrary.simpleMessage("可用佣金"),
    "xboardBack": MessageLookupByLibrary.simpleMessage("返回"),
    "xboardBalanceAmount": MessageLookupByLibrary.simpleMessage("余额支付"),
    "xboardBalancePaymentFailed": MessageLookupByLibrary.simpleMessage(
      "余额支付未成功",
    ),
    "xboardBasePrice": MessageLookupByLibrary.simpleMessage("原价"),
    "xboardBrowsePlans": MessageLookupByLibrary.simpleMessage("浏览可用套餐"),
    "xboardBrowsePlansButton": MessageLookupByLibrary.simpleMessage("浏览套餐"),
    "xboardBrowserNotOpenedNote": MessageLookupByLibrary.simpleMessage(
      "提示：如果浏览器未自动打开，可以点击\"重新打开\"或复制链接手动打开",
    ),
    "xboardBrowserNotOpenedTip": MessageLookupByLibrary.simpleMessage(
      "如果浏览器未自动打开，可以点击\\\"重新打开\\\"或复制链接手动打开",
    ),
    "xboardBuyMoreTrafficOrUpgrade": MessageLookupByLibrary.simpleMessage(
      "请购买更多流量或升级套餐",
    ),
    "xboardBuyNow": MessageLookupByLibrary.simpleMessage("立即购买"),
    "xboardBuyoutPlan": MessageLookupByLibrary.simpleMessage("买断制"),
    "xboardBypassDomain": MessageLookupByLibrary.simpleMessage("排除域名/IP"),
    "xboardBypassDomainCount": m41,
    "xboardBypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "添加不走代理的域名和IP段",
    ),
    "xboardCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "xboardCancelFailed": MessageLookupByLibrary.simpleMessage("取消失败"),
    "xboardCancelImport": MessageLookupByLibrary.simpleMessage("取消导入"),
    "xboardCancelOrder": MessageLookupByLibrary.simpleMessage("取消订单"),
    "xboardCancelOrderConfirm": MessageLookupByLibrary.simpleMessage(
      "确定要取消这个订单吗？",
    ),
    "xboardCancelPayment": MessageLookupByLibrary.simpleMessage("取消支付"),
    "xboardCancelledOrders": MessageLookupByLibrary.simpleMessage("已取消"),
    "xboardCannotLaunchBrowser": MessageLookupByLibrary.simpleMessage(
      "无法启动外部浏览器",
    ),
    "xboardCannotOpenPaymentLink": MessageLookupByLibrary.simpleMessage(
      "无法打开支付链接",
    ),
    "xboardCannotOpenPaymentUrl": MessageLookupByLibrary.simpleMessage(
      "无法打开支付链接",
    ),
    "xboardChangePassword": MessageLookupByLibrary.simpleMessage("修改密码"),
    "xboardChanging": MessageLookupByLibrary.simpleMessage("修改中..."),
    "xboardCheckPaymentFailed": MessageLookupByLibrary.simpleMessage(
      "检查支付状态失败",
    ),
    "xboardCheckPaymentStatusError": m42,
    "xboardCheckStatus": MessageLookupByLibrary.simpleMessage("检查状态"),
    "xboardChecking": MessageLookupByLibrary.simpleMessage("检查中..."),
    "xboardCleaningOldConfig": MessageLookupByLibrary.simpleMessage("清理旧配置"),
    "xboardCleaningPendingOrders": MessageLookupByLibrary.simpleMessage(
      "正在清理之前的待支付订单...",
    ),
    "xboardClearError": MessageLookupByLibrary.simpleMessage("清除错误"),
    "xboardClearOldOrders": MessageLookupByLibrary.simpleMessage("清理旧订单"),
    "xboardClickToCopy": MessageLookupByLibrary.simpleMessage("点击复制"),
    "xboardClickToSetupNodes": MessageLookupByLibrary.simpleMessage("点击设置节点"),
    "xboardClose": MessageLookupByLibrary.simpleMessage("关闭"),
    "xboardCloseTicket": MessageLookupByLibrary.simpleMessage("关闭工单"),
    "xboardCloseTicketConfirm": MessageLookupByLibrary.simpleMessage(
      "确定要关闭此工单吗？关闭后将无法继续回复。",
    ),
    "xboardClosed": MessageLookupByLibrary.simpleMessage("已关闭"),
    "xboardCodeCopied": MessageLookupByLibrary.simpleMessage("邀请码已复制到剪贴板"),
    "xboardComingSoon": MessageLookupByLibrary.simpleMessage("即将推出"),
    "xboardCommissionBalance": MessageLookupByLibrary.simpleMessage("佣金余额"),
    "xboardCommissionRate": MessageLookupByLibrary.simpleMessage("佣金比例"),
    "xboardCommissionStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "已发放",
    ),
    "xboardCommissionStatusNone": MessageLookupByLibrary.simpleMessage("无佣金"),
    "xboardCommissionStatusPending": MessageLookupByLibrary.simpleMessage(
      "待确认",
    ),
    "xboardCommissionStatusProcessing": MessageLookupByLibrary.simpleMessage(
      "发放中",
    ),
    "xboardCompletePaymentInBrowser": MessageLookupByLibrary.simpleMessage(
      "2. 请在浏览器中完成支付操作",
    ),
    "xboardCompletedOrders": MessageLookupByLibrary.simpleMessage("已完成"),
    "xboardConfigDownloadError": MessageLookupByLibrary.simpleMessage("下载配置失败"),
    "xboardConfigDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "配置文件下载失败，请检查订阅链接",
    ),
    "xboardConfigDownloadFailedBadRequest":
        MessageLookupByLibrary.simpleMessage("配置文件下载失败：HTTP请求头格式错误，请稍后重试"),
    "xboardConfigDownloadFailedCheckLink": MessageLookupByLibrary.simpleMessage(
      "配置文件下载失败，请检查订阅链接是否正确",
    ),
    "xboardConfigDownloadFailedInvalidRequest":
        MessageLookupByLibrary.simpleMessage("配置文件下载失败：请求格式错误，请稍后重试"),
    "xboardConfigFormatError": MessageLookupByLibrary.simpleMessage(
      "配置文件格式错误，请联系服务提供商",
    ),
    "xboardConfigFormatInvalid": MessageLookupByLibrary.simpleMessage(
      "配置文件格式错误",
    ),
    "xboardConfigImportFailed": MessageLookupByLibrary.simpleMessage("配置导入失败"),
    "xboardConfigImportSuccess": MessageLookupByLibrary.simpleMessage("配置导入成功"),
    "xboardConfigImportedSuccessDetail": MessageLookupByLibrary.simpleMessage(
      "配置已成功导入并添加到配置列表",
    ),
    "xboardConfigSaveFailed": MessageLookupByLibrary.simpleMessage(
      "保存配置失败，请检查存储空间",
    ),
    "xboardConfigSaveFailedCheckStorage": MessageLookupByLibrary.simpleMessage(
      "保存配置失败，请检查存储空间",
    ),
    "xboardConfigValidationFailed": MessageLookupByLibrary.simpleMessage(
      "配置文件格式验证失败，请联系服务提供商检查配置格式",
    ),
    "xboardConfigurationError": MessageLookupByLibrary.simpleMessage("配置错误"),
    "xboardConfirm": MessageLookupByLibrary.simpleMessage("确认"),
    "xboardConfirmAction": MessageLookupByLibrary.simpleMessage("确定"),
    "xboardConfirmAndPay": MessageLookupByLibrary.simpleMessage("确认并支付"),
    "xboardConfirmOrder": MessageLookupByLibrary.simpleMessage("确认订单"),
    "xboardConfirmPassword": MessageLookupByLibrary.simpleMessage("确认密码"),
    "xboardConfirmPurchase": MessageLookupByLibrary.simpleMessage("确认购买"),
    "xboardCongratulationsSubscriptionActivated":
        MessageLookupByLibrary.simpleMessage("恭喜！您的套餐已成功购买并生效"),
    "xboardConnectGlobalQualityNodes": MessageLookupByLibrary.simpleMessage(
      "连接全球优质节点",
    ),
    "xboardConnected": MessageLookupByLibrary.simpleMessage("已连接"),
    "xboardConnectionTimeout": MessageLookupByLibrary.simpleMessage(
      "连接超时，请检查网络连接",
    ),
    "xboardContinuePurchase": MessageLookupByLibrary.simpleMessage("继续购买"),
    "xboardContinueToPayment": MessageLookupByLibrary.simpleMessage("继续支付"),
    "xboardCopied": MessageLookupByLibrary.simpleMessage("已复制"),
    "xboardCopyCode": MessageLookupByLibrary.simpleMessage("复制码"),
    "xboardCopyFailed": MessageLookupByLibrary.simpleMessage("复制失败"),
    "xboardCopyFailedError": m43,
    "xboardCopyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "xboardCopyPaymentLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "xboardCopySubscriptionLinkAbove": MessageLookupByLibrary.simpleMessage(
      "复制上方的订阅链接",
    ),
    "xboardCouponDiscount": MessageLookupByLibrary.simpleMessage("优惠码折扣"),
    "xboardCouponExpired": MessageLookupByLibrary.simpleMessage("优惠券已过期"),
    "xboardCouponNotYetActive": MessageLookupByLibrary.simpleMessage("优惠券尚未生效"),
    "xboardCouponOptional": MessageLookupByLibrary.simpleMessage("优惠券（可选）"),
    "xboardCreateInviteCode": MessageLookupByLibrary.simpleMessage("创建邀请码"),
    "xboardCreateTicket": MessageLookupByLibrary.simpleMessage("新建工单"),
    "xboardCreateYourFirstTicket": MessageLookupByLibrary.simpleMessage(
      "创建您的第一个工单",
    ),
    "xboardCreatedAt": MessageLookupByLibrary.simpleMessage("创建时间"),
    "xboardCreating": MessageLookupByLibrary.simpleMessage("创建中..."),
    "xboardCreatingOrder": MessageLookupByLibrary.simpleMessage("正在创建订单"),
    "xboardCreatingOrderPleaseWait": MessageLookupByLibrary.simpleMessage(
      "我们正在为您创建新订单，请稍候",
    ),
    "xboardCurrentNode": MessageLookupByLibrary.simpleMessage("当前节点"),
    "xboardCurrentVersion": MessageLookupByLibrary.simpleMessage("当前版本"),
    "xboardCustomCommissionRate": MessageLookupByLibrary.simpleMessage("专属比例"),
    "xboardDailyTraffic": MessageLookupByLibrary.simpleMessage("每日流量"),
    "xboardDays": MessageLookupByLibrary.simpleMessage("天"),
    "xboardDaysAgo": MessageLookupByLibrary.simpleMessage("天前"),
    "xboardDeductibleDuringPayment": MessageLookupByLibrary.simpleMessage(
      "支付时可抵扣",
    ),
    "xboardDetail": MessageLookupByLibrary.simpleMessage("详情"),
    "xboardDeviceLimitCount": m44,
    "xboardDevices": MessageLookupByLibrary.simpleMessage("台设备"),
    "xboardDirectConnectionLabel": MessageLookupByLibrary.simpleMessage("直连"),
    "xboardDisconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "xboardDiscount": MessageLookupByLibrary.simpleMessage("优惠"),
    "xboardDiscountAmount": MessageLookupByLibrary.simpleMessage("折扣金额"),
    "xboardDiscounted": MessageLookupByLibrary.simpleMessage("已优惠"),
    "xboardDomainNotReady": MessageLookupByLibrary.simpleMessage("域名状态未就绪"),
    "xboardDomainUnavailable": MessageLookupByLibrary.simpleMessage("域名不可用"),
    "xboardDownloadTimeout": MessageLookupByLibrary.simpleMessage("下载超时"),
    "xboardDownloadTimeoutError": MessageLookupByLibrary.simpleMessage("下载超时"),
    "xboardDownloadTrafficLabel": m45,
    "xboardDownloadingConfig": MessageLookupByLibrary.simpleMessage("下载配置文件"),
    "xboardDownloadingProfile": MessageLookupByLibrary.simpleMessage(
      "正在下载配置文件",
    ),
    "xboardEarnCommission": MessageLookupByLibrary.simpleMessage("邀请返佣奖励"),
    "xboardEmail": MessageLookupByLibrary.simpleMessage("邮箱"),
    "xboardEnableTun": MessageLookupByLibrary.simpleMessage("开启 TUN"),
    "xboardEnjoyFastNetworkExperience": MessageLookupByLibrary.simpleMessage(
      "享受极速网络体验",
    ),
    "xboardEnterCouponCode": MessageLookupByLibrary.simpleMessage("请输入优惠券代码"),
    "xboardEnterMessage": MessageLookupByLibrary.simpleMessage("请输入消息"),
    "xboardEnterSubject": MessageLookupByLibrary.simpleMessage("请输入主题"),
    "xboardError": MessageLookupByLibrary.simpleMessage("错误"),
    "xboardExcellent": MessageLookupByLibrary.simpleMessage("优秀"),
    "xboardExpirationTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "xboardExpired": MessageLookupByLibrary.simpleMessage("已过期"),
    "xboardExpiringSoon": MessageLookupByLibrary.simpleMessage("即将到期"),
    "xboardExpiryTime": MessageLookupByLibrary.simpleMessage("过期时间"),
    "xboardFailedToCheckPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "检查支付状态失败",
    ),
    "xboardFailedToGetSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "获取订阅信息失败",
    ),
    "xboardFailedToOpenPaymentLink": MessageLookupByLibrary.simpleMessage(
      "打开支付链接失败",
    ),
    "xboardFailedToOpenPaymentPage": MessageLookupByLibrary.simpleMessage(
      "打开支付页面失败",
    ),
    "xboardFair": MessageLookupByLibrary.simpleMessage("一般"),
    "xboardFallbackModeUsed": MessageLookupByLibrary.simpleMessage(
      "已使用降级方案初始化",
    ),
    "xboardFirstStartTip": MessageLookupByLibrary.simpleMessage(
      "首次启动可能需要一些时间\n请耐心等待...",
    ),
    "xboardFirstStartupNote": MessageLookupByLibrary.simpleMessage(
      "首次启动可能需要一些时间\n请耐心等待...",
    ),
    "xboardFixedFee": MessageLookupByLibrary.simpleMessage("固定"),
    "xboardForceUpdate": MessageLookupByLibrary.simpleMessage("强制更新"),
    "xboardForgotPassword": MessageLookupByLibrary.simpleMessage("忘记密码"),
    "xboardGetSupport": MessageLookupByLibrary.simpleMessage("获取技术支持"),
    "xboardGettingIP": MessageLookupByLibrary.simpleMessage("获取中..."),
    "xboardGlobalNodes": MessageLookupByLibrary.simpleMessage("全球节点"),
    "xboardGoBack": MessageLookupByLibrary.simpleMessage("返回"),
    "xboardGoToPay": MessageLookupByLibrary.simpleMessage("去支付"),
    "xboardGood": MessageLookupByLibrary.simpleMessage("良好"),
    "xboardGroup": MessageLookupByLibrary.simpleMessage("所属组"),
    "xboardHalfYearPayment": MessageLookupByLibrary.simpleMessage("半年付"),
    "xboardHalfYearlyPayment": MessageLookupByLibrary.simpleMessage("半年付"),
    "xboardHandleLater": MessageLookupByLibrary.simpleMessage("稍后再说"),
    "xboardHandlingFee": MessageLookupByLibrary.simpleMessage("手续费"),
    "xboardHighPriority": MessageLookupByLibrary.simpleMessage("高"),
    "xboardHighSpeedNetwork": MessageLookupByLibrary.simpleMessage("高速网络"),
    "xboardHome": MessageLookupByLibrary.simpleMessage("首页"),
    "xboardHoursAgo": MessageLookupByLibrary.simpleMessage("小时前"),
    "xboardHttpRequestError": MessageLookupByLibrary.simpleMessage("HTTP请求失败"),
    "xboardHttpRequestFailed": MessageLookupByLibrary.simpleMessage("HTTP请求失败"),
    "xboardImportCancelled": MessageLookupByLibrary.simpleMessage("导入已取消"),
    "xboardImportErrorDownload": MessageLookupByLibrary.simpleMessage(
      "配置文件下载失败，请检查订阅链接",
    ),
    "xboardImportErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "网络连接失败，请检查网络设置",
    ),
    "xboardImportErrorStorage": MessageLookupByLibrary.simpleMessage(
      "保存配置失败，请检查存储空间",
    ),
    "xboardImportErrorUnknown": MessageLookupByLibrary.simpleMessage(
      "未知错误，请重试",
    ),
    "xboardImportErrorValidation": MessageLookupByLibrary.simpleMessage(
      "配置文件格式错误，请联系服务提供商",
    ),
    "xboardImportFailed": MessageLookupByLibrary.simpleMessage("配置导入失败"),
    "xboardImportFailedAppConfigError": MessageLookupByLibrary.simpleMessage(
      "导入失败：应用配置错误，请稍后重试或重启应用",
    ),
    "xboardImportFailedRetryOrSupport": MessageLookupByLibrary.simpleMessage(
      "导入失败，请稍后重试或联系技术支持",
    ),
    "xboardImportInProgress": MessageLookupByLibrary.simpleMessage("正在导入中，请稍候"),
    "xboardImportStatusAdding": MessageLookupByLibrary.simpleMessage("添加到配置列表"),
    "xboardImportStatusCleaning": MessageLookupByLibrary.simpleMessage("清理旧配置"),
    "xboardImportStatusDownloading": MessageLookupByLibrary.simpleMessage(
      "下载配置文件",
    ),
    "xboardImportStatusFailed": MessageLookupByLibrary.simpleMessage("导入失败"),
    "xboardImportStatusIdle": MessageLookupByLibrary.simpleMessage("准备导入"),
    "xboardImportStatusSuccess": MessageLookupByLibrary.simpleMessage("导入成功"),
    "xboardImportStatusValidating": MessageLookupByLibrary.simpleMessage(
      "验证配置格式",
    ),
    "xboardImportSuccess": MessageLookupByLibrary.simpleMessage("配置导入成功"),
    "xboardImportingConfiguration": MessageLookupByLibrary.simpleMessage(
      "正在导入配置",
    ),
    "xboardImportingSubscription": MessageLookupByLibrary.simpleMessage(
      "正在加载订阅配置...",
    ),
    "xboardInactive": MessageLookupByLibrary.simpleMessage("未激活"),
    "xboardInitializationComplete": MessageLookupByLibrary.simpleMessage(
      "初始化完成",
    ),
    "xboardInitializationFailed": MessageLookupByLibrary.simpleMessage("初始化失败"),
    "xboardInitializationTimeout": MessageLookupByLibrary.simpleMessage(
      "初始化超时",
    ),
    "xboardInitializing": MessageLookupByLibrary.simpleMessage("正在初始化"),
    "xboardInsufficientBalance": MessageLookupByLibrary.simpleMessage("余额不足"),
    "xboardInvalidCredentials": MessageLookupByLibrary.simpleMessage(
      "用户名或密码错误",
    ),
    "xboardInvalidOrExpiredCoupon": MessageLookupByLibrary.simpleMessage(
      "优惠券代码无效或已过期",
    ),
    "xboardInvalidResponseFormat": MessageLookupByLibrary.simpleMessage(
      "服务器返回数据格式错误",
    ),
    "xboardInvite": MessageLookupByLibrary.simpleMessage("邀请"),
    "xboardInviteCode": MessageLookupByLibrary.simpleMessage("邀请码"),
    "xboardInviteCodeCreated": MessageLookupByLibrary.simpleMessage("邀请码创建成功"),
    "xboardInviteCodes": MessageLookupByLibrary.simpleMessage("邀请码"),
    "xboardInviteFriends": MessageLookupByLibrary.simpleMessage("邀请好友"),
    "xboardInviteSubtitle": MessageLookupByLibrary.simpleMessage(
      "分享你的邀请码，从推荐中赚取佣金",
    ),
    "xboardInviteTitle": MessageLookupByLibrary.simpleMessage("邀请好友赚佣金"),
    "xboardJustNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "xboardKeepSubscriptionLinkSafe": MessageLookupByLibrary.simpleMessage(
      "请妥善保管您的订阅链接，不要分享给他人",
    ),
    "xboardLanSharing": MessageLookupByLibrary.simpleMessage("局域网代理共享"),
    "xboardLanSharingDesc": MessageLookupByLibrary.simpleMessage(
      "允许局域网设备通过本机代理上网",
    ),
    "xboardLatencyAutoTesting": MessageLookupByLibrary.simpleMessage("自动测试中"),
    "xboardLatencyExcellent": MessageLookupByLibrary.simpleMessage("优秀"),
    "xboardLatencyExcellentDesc": MessageLookupByLibrary.simpleMessage(
      "网络质量优秀，适合所有应用",
    ),
    "xboardLatencyFair": MessageLookupByLibrary.simpleMessage("一般"),
    "xboardLatencyFairDesc": MessageLookupByLibrary.simpleMessage(
      "网络质量一般，可用于基本应用",
    ),
    "xboardLatencyGood": MessageLookupByLibrary.simpleMessage("良好"),
    "xboardLatencyGoodDesc": MessageLookupByLibrary.simpleMessage(
      "网络质量良好，适合大多数应用",
    ),
    "xboardLatencyPoor": MessageLookupByLibrary.simpleMessage("较差"),
    "xboardLatencyPoorDesc": MessageLookupByLibrary.simpleMessage(
      "网络质量较差，可能影响体验",
    ),
    "xboardLatencyTesting": MessageLookupByLibrary.simpleMessage("测试中"),
    "xboardLatencyTimeout": MessageLookupByLibrary.simpleMessage("超时"),
    "xboardLatencyTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "连接超时，请检查网络",
    ),
    "xboardLatencyVeryPoor": MessageLookupByLibrary.simpleMessage("很差"),
    "xboardLatencyVeryPoorDesc": MessageLookupByLibrary.simpleMessage(
      "网络质量很差，建议更换节点",
    ),
    "xboardLater": MessageLookupByLibrary.simpleMessage("稍后处理"),
    "xboardLinkCopied": MessageLookupByLibrary.simpleMessage("邀请链接已复制到剪贴板"),
    "xboardLoadError": MessageLookupByLibrary.simpleMessage("加载数据失败"),
    "xboardLoadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "xboardLoadingFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "xboardLoadingPaymentPage": MessageLookupByLibrary.simpleMessage(
      "正在加载支付页面",
    ),
    "xboardLocalIP": MessageLookupByLibrary.simpleMessage("本机IP"),
    "xboardLoggedIn": MessageLookupByLibrary.simpleMessage("已登录"),
    "xboardLogin": MessageLookupByLibrary.simpleMessage("登录"),
    "xboardLoginExpired": MessageLookupByLibrary.simpleMessage("登录已过期，请重新登录"),
    "xboardLoginFailed": MessageLookupByLibrary.simpleMessage("登录失败"),
    "xboardLoginSuccess": MessageLookupByLibrary.simpleMessage("登录成功"),
    "xboardLoginToViewSubscription": MessageLookupByLibrary.simpleMessage(
      "请登录后查看套餐使用情况",
    ),
    "xboardLogout": MessageLookupByLibrary.simpleMessage("登出"),
    "xboardLogoutConfirmContent": MessageLookupByLibrary.simpleMessage(
      "您确定要登出吗？登出后需要重新输入账号密码。",
    ),
    "xboardLogoutConfirmTitle": MessageLookupByLibrary.simpleMessage("确认登出"),
    "xboardLogoutFailed": MessageLookupByLibrary.simpleMessage("登出失败"),
    "xboardLogoutSuccess": MessageLookupByLibrary.simpleMessage("已成功登出"),
    "xboardLowPriority": MessageLookupByLibrary.simpleMessage("低"),
    "xboardLowestPrice": MessageLookupByLibrary.simpleMessage("最低价格"),
    "xboardMaxInviteCodesReached": MessageLookupByLibrary.simpleMessage(
      "最多允许 5 个邀请码",
    ),
    "xboardMediumPriority": MessageLookupByLibrary.simpleMessage("中"),
    "xboardMemberSince": MessageLookupByLibrary.simpleMessage("注册于"),
    "xboardMinutesAgo": MessageLookupByLibrary.simpleMessage("分钟前"),
    "xboardMissingRequiredField": MessageLookupByLibrary.simpleMessage(
      "缺少必要字段",
    ),
    "xboardMonthlyPayment": MessageLookupByLibrary.simpleMessage("月付"),
    "xboardMonthlyPrice": MessageLookupByLibrary.simpleMessage("月付价格"),
    "xboardMonthlyRenewal": MessageLookupByLibrary.simpleMessage("每月续费"),
    "xboardMonthsAgo": MessageLookupByLibrary.simpleMessage("月前"),
    "xboardMultipleRetriesFailed": MessageLookupByLibrary.simpleMessage(
      "多次重试后仍然失败",
    ),
    "xboardMustUpdate": MessageLookupByLibrary.simpleMessage("必须更新"),
    "xboardMyOrders": MessageLookupByLibrary.simpleMessage("我的订单"),
    "xboardNetworkConnectionError": MessageLookupByLibrary.simpleMessage(
      "网络连接失败",
    ),
    "xboardNetworkConnectionFailed": MessageLookupByLibrary.simpleMessage(
      "网络连接失败，请检查网络设置",
    ),
    "xboardNetworkConnectionFailedCheckSettings":
        MessageLookupByLibrary.simpleMessage("网络连接失败，请检查网络设置后重试"),
    "xboardNetworkSettings": MessageLookupByLibrary.simpleMessage("网络设置"),
    "xboardNeverExpire": MessageLookupByLibrary.simpleMessage("永不过期"),
    "xboardNewPassword": MessageLookupByLibrary.simpleMessage("新密码"),
    "xboardNewVersionFound": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "xboardNext": MessageLookupByLibrary.simpleMessage("下一条"),
    "xboardNoAvailableNodes": MessageLookupByLibrary.simpleMessage("无可用节点"),
    "xboardNoAvailablePlan": MessageLookupByLibrary.simpleMessage("无可用套餐"),
    "xboardNoAvailablePlans": MessageLookupByLibrary.simpleMessage("暂无可用套餐"),
    "xboardNoAvailableSubscription": MessageLookupByLibrary.simpleMessage(
      "无可用套餐",
    ),
    "xboardNoInternetConnection": MessageLookupByLibrary.simpleMessage(
      "无网络连接，请检查网络设置",
    ),
    "xboardNoInviteCodes": MessageLookupByLibrary.simpleMessage("暂无邀请码"),
    "xboardNoInviteCodesDesc": MessageLookupByLibrary.simpleMessage(
      "创建你的第一个邀请码以开始赚取佣金",
    ),
    "xboardNoOrders": MessageLookupByLibrary.simpleMessage("暂无订单"),
    "xboardNoOrdersDesc": MessageLookupByLibrary.simpleMessage("您的订单记录将在这里显示"),
    "xboardNoPaymentMethodsAvailable": MessageLookupByLibrary.simpleMessage(
      "暂无可用的支付方式，请检查网络或稍后重试",
    ),
    "xboardNoServerData": MessageLookupByLibrary.simpleMessage("暂无服务器数据"),
    "xboardNoSubscriptionInfo": MessageLookupByLibrary.simpleMessage("暂无订阅信息"),
    "xboardNoSubscriptionPlans": MessageLookupByLibrary.simpleMessage("暂无套餐信息"),
    "xboardNoTickets": MessageLookupByLibrary.simpleMessage("暂无工单"),
    "xboardNoTicketsDesc": MessageLookupByLibrary.simpleMessage(
      "创建您的第一个工单以获取支持",
    ),
    "xboardNoTitle": MessageLookupByLibrary.simpleMessage("无标题"),
    "xboardNodeName": MessageLookupByLibrary.simpleMessage("节点名称"),
    "xboardNodesUpdated": MessageLookupByLibrary.simpleMessage("节点更新成功"),
    "xboardNone": MessageLookupByLibrary.simpleMessage("无"),
    "xboardNotLoggedIn": MessageLookupByLibrary.simpleMessage("未登录"),
    "xboardNoticeDialogGotIt": MessageLookupByLibrary.simpleMessage("知道了"),
    "xboardNotificationUpdateError": MessageLookupByLibrary.simpleMessage(
      "更新通知设置失败",
    ),
    "xboardNotificationUpdateSuccess": MessageLookupByLibrary.simpleMessage(
      "通知设置已更新",
    ),
    "xboardNotifications": MessageLookupByLibrary.simpleMessage("通知设置"),
    "xboardOffline": MessageLookupByLibrary.simpleMessage("离线"),
    "xboardOldPassword": MessageLookupByLibrary.simpleMessage("当前密码"),
    "xboardOneTimePayment": MessageLookupByLibrary.simpleMessage("一次性"),
    "xboardOnetimePayment": MessageLookupByLibrary.simpleMessage("一次性"),
    "xboardOnline": MessageLookupByLibrary.simpleMessage("在线"),
    "xboardOnlineSupport": MessageLookupByLibrary.simpleMessage("在线客服"),
    "xboardOpen": MessageLookupByLibrary.simpleMessage("打开"),
    "xboardOpenPaymentFailed": MessageLookupByLibrary.simpleMessage("打开支付页面失败"),
    "xboardOpenPaymentLinkError": m46,
    "xboardOpenPaymentLinkFailed": MessageLookupByLibrary.simpleMessage(
      "打开支付链接失败",
    ),
    "xboardOpenPaymentPageError": m47,
    "xboardOperationFailed": MessageLookupByLibrary.simpleMessage("操作失败"),
    "xboardOperationFailedError": m48,
    "xboardOperationStep1": MessageLookupByLibrary.simpleMessage(
      "1. 系统已自动为您打开支付页面",
    ),
    "xboardOperationStep2": MessageLookupByLibrary.simpleMessage(
      "2. 请在浏览器中完成支付操作",
    ),
    "xboardOperationStep3": MessageLookupByLibrary.simpleMessage(
      "3. 支付完成后返回应用，系统将自动检测",
    ),
    "xboardOperationStep4": MessageLookupByLibrary.simpleMessage(
      "4. 如需重新打开，可点击下方\"重新打开\"按钮",
    ),
    "xboardOperationTips": MessageLookupByLibrary.simpleMessage("操作提示"),
    "xboardOrderCancelled": MessageLookupByLibrary.simpleMessage("订单已取消"),
    "xboardOrderCreationFailed": MessageLookupByLibrary.simpleMessage("创建订单失败"),
    "xboardOrderDetails": MessageLookupByLibrary.simpleMessage("订单详情"),
    "xboardOrderHistory": MessageLookupByLibrary.simpleMessage("订单历史"),
    "xboardOrderHistoryDesc": MessageLookupByLibrary.simpleMessage(
      "查看和管理您的订单记录",
    ),
    "xboardOrderInfo": MessageLookupByLibrary.simpleMessage("订单信息"),
    "xboardOrderInfoNotFound": MessageLookupByLibrary.simpleMessage("未找到订单信息"),
    "xboardOrderNotFound": MessageLookupByLibrary.simpleMessage("订单不存在"),
    "xboardOrderNumber": MessageLookupByLibrary.simpleMessage("订单号"),
    "xboardOrderStatusCanceled": MessageLookupByLibrary.simpleMessage("已取消"),
    "xboardOrderStatusCompleted": MessageLookupByLibrary.simpleMessage("已完成"),
    "xboardOrderStatusDiscounted": MessageLookupByLibrary.simpleMessage("已折抵"),
    "xboardOrderStatusPending": MessageLookupByLibrary.simpleMessage("待支付"),
    "xboardOrderStatusProcessing": MessageLookupByLibrary.simpleMessage("开通中"),
    "xboardOrderSummary": MessageLookupByLibrary.simpleMessage("订单汇总"),
    "xboardPassword": MessageLookupByLibrary.simpleMessage("密码"),
    "xboardPasswordChangeError": MessageLookupByLibrary.simpleMessage("密码修改失败"),
    "xboardPasswordChangedSuccess": MessageLookupByLibrary.simpleMessage(
      "密码修改成功",
    ),
    "xboardPasswordMinLength": MessageLookupByLibrary.simpleMessage(
      "密码至少需要8个字符",
    ),
    "xboardPay": MessageLookupByLibrary.simpleMessage("支付"),
    "xboardPaymentCancelled": MessageLookupByLibrary.simpleMessage("支付已取消"),
    "xboardPaymentComplete": MessageLookupByLibrary.simpleMessage("支付完成"),
    "xboardPaymentCompleted": MessageLookupByLibrary.simpleMessage("支付完成！"),
    "xboardPaymentDetails": MessageLookupByLibrary.simpleMessage("支付详情"),
    "xboardPaymentFailed": MessageLookupByLibrary.simpleMessage("支付失败"),
    "xboardPaymentFailedBalanceError": MessageLookupByLibrary.simpleMessage(
      "支付失败: 余额支付未成功",
    ),
    "xboardPaymentFailedEmptyResult": MessageLookupByLibrary.simpleMessage(
      "支付失败: 支付请求返回空结果",
    ),
    "xboardPaymentFailedInvalidData": MessageLookupByLibrary.simpleMessage(
      "支付失败: 未获取到有效的支付数据",
    ),
    "xboardPaymentFailedMessage": m49,
    "xboardPaymentGateway": MessageLookupByLibrary.simpleMessage("支付网关"),
    "xboardPaymentInfo": MessageLookupByLibrary.simpleMessage("支付信息"),
    "xboardPaymentInstructions1": MessageLookupByLibrary.simpleMessage(
      "1. 系统已自动为您打开支付页面",
    ),
    "xboardPaymentInstructions2": MessageLookupByLibrary.simpleMessage(
      "2. 请在浏览器中完成支付操作",
    ),
    "xboardPaymentInstructions3": MessageLookupByLibrary.simpleMessage(
      "3. 支付完成后返回应用，系统将自动检测",
    ),
    "xboardPaymentLink": MessageLookupByLibrary.simpleMessage("支付链接"),
    "xboardPaymentLinkCopied": MessageLookupByLibrary.simpleMessage(
      "支付链接已复制到剪贴板",
    ),
    "xboardPaymentLinkCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "支付链接已复制到剪贴板",
    ),
    "xboardPaymentMethod": MessageLookupByLibrary.simpleMessage("支付方式"),
    "xboardPaymentMethodVerified": MessageLookupByLibrary.simpleMessage(
      "支付方式验证通过",
    ),
    "xboardPaymentMethodVerifiedPreparing":
        MessageLookupByLibrary.simpleMessage("支付方式已验证，准备跳转到支付页面"),
    "xboardPaymentPageAutoOpened": MessageLookupByLibrary.simpleMessage(
      "1. 系统已自动为您打开支付页面",
    ),
    "xboardPaymentPageOpenedCompleteAndReturn":
        MessageLookupByLibrary.simpleMessage("支付页面已打开，请完成支付并返回应用"),
    "xboardPaymentPageOpenedCopyDesc": MessageLookupByLibrary.simpleMessage(
      "支付页面已打开，支付链接已复制到剪贴板。如果没有自动跳转，请手动粘贴到浏览器打开。",
    ),
    "xboardPaymentPageOpenedInBrowser": MessageLookupByLibrary.simpleMessage(
      "已在浏览器中打开支付页面，完成支付后请返回应用",
    ),
    "xboardPaymentPageOpenedInBrowserNote":
        MessageLookupByLibrary.simpleMessage("已在浏览器中打开支付页面，完成支付后请返回应用"),
    "xboardPaymentSuccess": MessageLookupByLibrary.simpleMessage("支付成功"),
    "xboardPaymentSuccessful": MessageLookupByLibrary.simpleMessage("🎉 支付成功！"),
    "xboardPaymentSummary": MessageLookupByLibrary.simpleMessage("支付详情"),
    "xboardPending": MessageLookupByLibrary.simpleMessage("待处理"),
    "xboardPendingCommission": MessageLookupByLibrary.simpleMessage("待确认佣金"),
    "xboardPendingOrders": MessageLookupByLibrary.simpleMessage("待支付"),
    "xboardPercentFee": MessageLookupByLibrary.simpleMessage("比例"),
    "xboardPeriod": MessageLookupByLibrary.simpleMessage("周期"),
    "xboardPlanConflictMessage": MessageLookupByLibrary.simpleMessage(
      "您正在购买不同的订阅套餐。系统将对您当前套餐的剩余价值进行回收，并按多退少补原则进行结算。",
    ),
    "xboardPlanConflictTitle": MessageLookupByLibrary.simpleMessage("订阅套餐变更提示"),
    "xboardPlanInfo": MessageLookupByLibrary.simpleMessage("套餐信息"),
    "xboardPlanNotFound": MessageLookupByLibrary.simpleMessage("套餐不存在"),
    "xboardPlanPeriodHalfYearly": MessageLookupByLibrary.simpleMessage("半年付"),
    "xboardPlanPeriodMonthly": MessageLookupByLibrary.simpleMessage("月付"),
    "xboardPlanPeriodOnetime": MessageLookupByLibrary.simpleMessage("一次性"),
    "xboardPlanPeriodQuarterly": MessageLookupByLibrary.simpleMessage("季付"),
    "xboardPlanPeriodReset": MessageLookupByLibrary.simpleMessage("重置流量"),
    "xboardPlanPeriodThreeYear": MessageLookupByLibrary.simpleMessage("三年付"),
    "xboardPlanPeriodTwoYear": MessageLookupByLibrary.simpleMessage("两年付"),
    "xboardPlanPeriodYearly": MessageLookupByLibrary.simpleMessage("年付"),
    "xboardPlanSummary": MessageLookupByLibrary.simpleMessage("套餐概览"),
    "xboardPlanWithId": m50,
    "xboardPlans": MessageLookupByLibrary.simpleMessage("套餐"),
    "xboardPleaseLogin": MessageLookupByLibrary.simpleMessage("请先登录"),
    "xboardPleaseLoginFirst": MessageLookupByLibrary.simpleMessage("请先登录"),
    "xboardPleaseSelectPaymentPeriod": MessageLookupByLibrary.simpleMessage(
      "请选择购买周期",
    ),
    "xboardPleaseTryLaterOrContactSupport":
        MessageLookupByLibrary.simpleMessage("请稍后再试或联系客服"),
    "xboardPoor": MessageLookupByLibrary.simpleMessage("较差"),
    "xboardPreferences": MessageLookupByLibrary.simpleMessage("偏好设置"),
    "xboardPreparingImport": MessageLookupByLibrary.simpleMessage("准备导入配置"),
    "xboardPreparingImportStatus": MessageLookupByLibrary.simpleMessage("准备导入"),
    "xboardPreparingPaymentPage": MessageLookupByLibrary.simpleMessage(
      "正在准备支付页面，即将跳转",
    ),
    "xboardPrevious": MessageLookupByLibrary.simpleMessage("上一条"),
    "xboardPriority": MessageLookupByLibrary.simpleMessage("优先级"),
    "xboardPriorityLabel": MessageLookupByLibrary.simpleMessage("优先级"),
    "xboardProcessing": MessageLookupByLibrary.simpleMessage("处理中..."),
    "xboardProcessingFee": MessageLookupByLibrary.simpleMessage("手续费"),
    "xboardProcessingOrders": MessageLookupByLibrary.simpleMessage("开通中"),
    "xboardProfessionalSupport": MessageLookupByLibrary.simpleMessage("专业客服"),
    "xboardProfile": MessageLookupByLibrary.simpleMessage("配置文件"),
    "xboardProfileImportCancelTooltip": MessageLookupByLibrary.simpleMessage(
      "取消导入",
    ),
    "xboardProfileImportClearError": MessageLookupByLibrary.simpleMessage(
      "清除错误",
    ),
    "xboardProfileImportCloseTooltip": MessageLookupByLibrary.simpleMessage(
      "关闭",
    ),
    "xboardProfileImportConfirm": MessageLookupByLibrary.simpleMessage("确定"),
    "xboardProfileImportFailedTitle": MessageLookupByLibrary.simpleMessage(
      "配置导入失败",
    ),
    "xboardProfileImportInProgress": MessageLookupByLibrary.simpleMessage(
      "正在导入配置",
    ),
    "xboardProfileImportPreparing": MessageLookupByLibrary.simpleMessage(
      "准备导入配置",
    ),
    "xboardProfileImportRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "xboardProfileImportSuccessDetail": MessageLookupByLibrary.simpleMessage(
      "配置已成功导入并添加到配置列表",
    ),
    "xboardProfileImportSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "配置导入成功",
    ),
    "xboardProtectNetworkPrivacy": MessageLookupByLibrary.simpleMessage(
      "保护您的网络隐私",
    ),
    "xboardProxy": MessageLookupByLibrary.simpleMessage("代理"),
    "xboardProxyCommands": MessageLookupByLibrary.simpleMessage("设置代理命令"),
    "xboardProxyConnectionLabel": m51,
    "xboardProxyInfo": MessageLookupByLibrary.simpleMessage("代理信息"),
    "xboardProxyMode": MessageLookupByLibrary.simpleMessage("代理模式"),
    "xboardProxyModeDirectDescription": MessageLookupByLibrary.simpleMessage(
      "所有流量都直接连接，不使用代理",
    ),
    "xboardProxyModeGlobalDescription": MessageLookupByLibrary.simpleMessage(
      "所有流量都通过代理服务器",
    ),
    "xboardProxyModeRuleDescription": MessageLookupByLibrary.simpleMessage(
      "根据规则自动选择直连或代理",
    ),
    "xboardProxyPort": MessageLookupByLibrary.simpleMessage("代理端口"),
    "xboardPurchasePlan": MessageLookupByLibrary.simpleMessage("购买套餐"),
    "xboardPurchasePlanPrompt": MessageLookupByLibrary.simpleMessage("请先购买套餐"),
    "xboardPurchaseSubscription": MessageLookupByLibrary.simpleMessage("购买套餐"),
    "xboardPurchaseSubscriptionToUse": MessageLookupByLibrary.simpleMessage(
      "请购买套餐后使用",
    ),
    "xboardPurchaseTraffic": MessageLookupByLibrary.simpleMessage("购买流量"),
    "xboardQuarterlyPayment": MessageLookupByLibrary.simpleMessage("季付"),
    "xboardQuickActions": MessageLookupByLibrary.simpleMessage("快捷操作"),
    "xboardRecommended": MessageLookupByLibrary.simpleMessage("推荐"),
    "xboardRefresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "xboardRefreshStatus": MessageLookupByLibrary.simpleMessage("刷新状态"),
    "xboardRefreshSubscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "刷新订阅信息",
    ),
    "xboardRefreshSubscriptionSuccess": MessageLookupByLibrary.simpleMessage(
      "订阅刷新成功",
    ),
    "xboardRefundAmount": MessageLookupByLibrary.simpleMessage("退款金额"),
    "xboardRegister": MessageLookupByLibrary.simpleMessage("注册"),
    "xboardRegisterFailed": MessageLookupByLibrary.simpleMessage("注册失败"),
    "xboardRegisterSuccess": MessageLookupByLibrary.simpleMessage(
      "注册成功！正在跳转到登录页面...",
    ),
    "xboardRegisteredUsers": MessageLookupByLibrary.simpleMessage("注册用户"),
    "xboardReload": MessageLookupByLibrary.simpleMessage("重新获取"),
    "xboardRelogin": MessageLookupByLibrary.simpleMessage("重新登录"),
    "xboardRemaining": MessageLookupByLibrary.simpleMessage("剩余"),
    "xboardRemainingDaysCount": m52,
    "xboardRemainingDaysLabel": MessageLookupByLibrary.simpleMessage("剩余天数"),
    "xboardRememberPassword": MessageLookupByLibrary.simpleMessage("记住密码"),
    "xboardRemindExpire": MessageLookupByLibrary.simpleMessage("套餐到期提醒"),
    "xboardRemindTraffic": MessageLookupByLibrary.simpleMessage("流量不足提醒"),
    "xboardRenewPlan": MessageLookupByLibrary.simpleMessage("续费套餐"),
    "xboardRenewToContinue": MessageLookupByLibrary.simpleMessage("请续费后继续使用"),
    "xboardReopen": MessageLookupByLibrary.simpleMessage("重新打开"),
    "xboardReopenPayment": MessageLookupByLibrary.simpleMessage("重新打开"),
    "xboardReopenPaymentNote": MessageLookupByLibrary.simpleMessage(
      "如需重新打开，可点击下方\"重新打开\"按钮",
    ),
    "xboardReopenPaymentPageTip": MessageLookupByLibrary.simpleMessage(
      "如需重新打开，可点击下方\\\"重新打开\\\"按钮",
    ),
    "xboardReplaceOldConfig": MessageLookupByLibrary.simpleMessage("替换旧的订阅配置"),
    "xboardReplacingProfile": MessageLookupByLibrary.simpleMessage("正在替换配置文件"),
    "xboardReplied": MessageLookupByLibrary.simpleMessage("已回复"),
    "xboardReply": MessageLookupByLibrary.simpleMessage("回复"),
    "xboardReplyFailed": MessageLookupByLibrary.simpleMessage("回复发送失败"),
    "xboardReplySent": MessageLookupByLibrary.simpleMessage("回复发送成功"),
    "xboardResetConfirmDesc": MessageLookupByLibrary.simpleMessage(
      "将生成新的订阅链接，旧链接将失效，您需要重新导入订阅。确定继续吗？",
    ),
    "xboardResetConfirmTitle": MessageLookupByLibrary.simpleMessage("重置订阅"),
    "xboardResetSubscription": MessageLookupByLibrary.simpleMessage("重置订阅"),
    "xboardResetSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "将生成新的订阅链接并使旧链接失效",
    ),
    "xboardResetSubscriptionError": MessageLookupByLibrary.simpleMessage(
      "重置订阅失败",
    ),
    "xboardResetSubscriptionSuccess": MessageLookupByLibrary.simpleMessage(
      "订阅重置成功，请重新导入订阅",
    ),
    "xboardResetTraffic": MessageLookupByLibrary.simpleMessage("重置流量"),
    "xboardResetTrafficDescription": MessageLookupByLibrary.simpleMessage(
      "重置已用流量",
    ),
    "xboardResetting": MessageLookupByLibrary.simpleMessage("重置中..."),
    "xboardRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "xboardRetryAttemptFailed": m53,
    "xboardRetryGet": MessageLookupByLibrary.simpleMessage("重新获取"),
    "xboardReturn": MessageLookupByLibrary.simpleMessage("返回"),
    "xboardReturnAfterPaymentAutoDetect": MessageLookupByLibrary.simpleMessage(
      "3. 支付完成后返回应用，系统将自动检测",
    ),
    "xboardRunningTime": m54,
    "xboardSearchNode": MessageLookupByLibrary.simpleMessage("搜索节点"),
    "xboardSecureEncryption": MessageLookupByLibrary.simpleMessage("安全加密"),
    "xboardSecurity": MessageLookupByLibrary.simpleMessage("安全设置"),
    "xboardSelectPaymentMethod": MessageLookupByLibrary.simpleMessage("选择支付方式"),
    "xboardSelectPaymentPeriod": MessageLookupByLibrary.simpleMessage("选择购买周期"),
    "xboardSelectPeriod": MessageLookupByLibrary.simpleMessage("请选择购买周期"),
    "xboardSelectPriority": MessageLookupByLibrary.simpleMessage("选择优先级"),
    "xboardSend": MessageLookupByLibrary.simpleMessage("发送"),
    "xboardSendVerificationCode": MessageLookupByLibrary.simpleMessage("发送验证码"),
    "xboardServerError": MessageLookupByLibrary.simpleMessage("服务器错误"),
    "xboardServerHost": MessageLookupByLibrary.simpleMessage("服务器地址"),
    "xboardServerName": MessageLookupByLibrary.simpleMessage("服务器名称"),
    "xboardServerOffline": MessageLookupByLibrary.simpleMessage("不可用"),
    "xboardServerOnline": MessageLookupByLibrary.simpleMessage("可用"),
    "xboardServerStatus": MessageLookupByLibrary.simpleMessage("服务器状态"),
    "xboardServersOffline": MessageLookupByLibrary.simpleMessage("台离线"),
    "xboardServersOnline": MessageLookupByLibrary.simpleMessage("台在线"),
    "xboardSettings": MessageLookupByLibrary.simpleMessage("设置"),
    "xboardSettledCommission": MessageLookupByLibrary.simpleMessage("已结算佣金"),
    "xboardSetup": MessageLookupByLibrary.simpleMessage("设置"),
    "xboardSixMonthCycle": MessageLookupByLibrary.simpleMessage("6个月周期"),
    "xboardSkip": MessageLookupByLibrary.simpleMessage("跳过"),
    "xboardSpeedLimit": MessageLookupByLibrary.simpleMessage("限速"),
    "xboardStartImportingSubscription": MessageLookupByLibrary.simpleMessage(
      "开始导入订阅",
    ),
    "xboardStartProxy": MessageLookupByLibrary.simpleMessage("启动代理"),
    "xboardStatusCheckFailed": MessageLookupByLibrary.simpleMessage("状态检查失败"),
    "xboardStop": MessageLookupByLibrary.simpleMessage("停止"),
    "xboardStopProxy": MessageLookupByLibrary.simpleMessage("停止代理"),
    "xboardSubscription": MessageLookupByLibrary.simpleMessage("订阅"),
    "xboardSubscriptionCopied": MessageLookupByLibrary.simpleMessage(
      "订阅链接已复制到剪贴板",
    ),
    "xboardSubscriptionDetails": MessageLookupByLibrary.simpleMessage("订阅详情"),
    "xboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage("订阅已过期"),
    "xboardSubscriptionHasExpired": MessageLookupByLibrary.simpleMessage(
      "订阅已过期",
    ),
    "xboardSubscriptionInfo": MessageLookupByLibrary.simpleMessage("订阅信息"),
    "xboardSubscriptionLink": MessageLookupByLibrary.simpleMessage("订阅链接"),
    "xboardSubscriptionLinkCopied": MessageLookupByLibrary.simpleMessage(
      "订阅链接已复制到剪贴板",
    ),
    "xboardSubscriptionPurchase": MessageLookupByLibrary.simpleMessage("订阅购买"),
    "xboardSubscriptionStatus": MessageLookupByLibrary.simpleMessage("订阅状态"),
    "xboardSubtotal": MessageLookupByLibrary.simpleMessage("小计"),
    "xboardSupportTickets": MessageLookupByLibrary.simpleMessage("工单支持"),
    "xboardSurplusAmount": MessageLookupByLibrary.simpleMessage("剩余金额"),
    "xboardSwitch": MessageLookupByLibrary.simpleMessage("切换"),
    "xboardSwitchNode": MessageLookupByLibrary.simpleMessage("切换节点"),
    "xboardSystemCommissionRate": MessageLookupByLibrary.simpleMessage("系统比例"),
    "xboardTapToConnect": MessageLookupByLibrary.simpleMessage("轻触即可连接"),
    "xboardTapToCopy": MessageLookupByLibrary.simpleMessage("点击复制"),
    "xboardTaskCancelled": MessageLookupByLibrary.simpleMessage("任务已取消"),
    "xboardTestAllNodes": MessageLookupByLibrary.simpleMessage("测速全部节点"),
    "xboardTestComplete": MessageLookupByLibrary.simpleMessage("测速完成"),
    "xboardTesting": MessageLookupByLibrary.simpleMessage("测试中"),
    "xboardThirtySixMonthCycle": MessageLookupByLibrary.simpleMessage("36个月周期"),
    "xboardThreeMonthCycle": MessageLookupByLibrary.simpleMessage("3个月周期"),
    "xboardThreeYearPayment": MessageLookupByLibrary.simpleMessage("三年付"),
    "xboardTicketClosed": MessageLookupByLibrary.simpleMessage("工单已关闭"),
    "xboardTicketCreateFailed": MessageLookupByLibrary.simpleMessage("工单创建失败"),
    "xboardTicketCreated": MessageLookupByLibrary.simpleMessage("工单创建成功"),
    "xboardTicketDetail": MessageLookupByLibrary.simpleMessage("工单详情"),
    "xboardTicketMessage": MessageLookupByLibrary.simpleMessage("消息"),
    "xboardTicketStatus": MessageLookupByLibrary.simpleMessage("工单状态"),
    "xboardTicketStatusClosed": MessageLookupByLibrary.simpleMessage("已关闭"),
    "xboardTicketStatusPending": MessageLookupByLibrary.simpleMessage("待处理"),
    "xboardTicketSubject": MessageLookupByLibrary.simpleMessage("主题"),
    "xboardTickets": MessageLookupByLibrary.simpleMessage("工单"),
    "xboardTimeInfo": MessageLookupByLibrary.simpleMessage("时间信息"),
    "xboardTimeout": MessageLookupByLibrary.simpleMessage("超时"),
    "xboardToday": MessageLookupByLibrary.simpleMessage("今天"),
    "xboardTokenExpiredContent": MessageLookupByLibrary.simpleMessage(
      "您的登录状态已过期，请重新登录以继续使用。",
    ),
    "xboardTokenExpiredTitle": MessageLookupByLibrary.simpleMessage("登录已过期"),
    "xboardTomorrow": MessageLookupByLibrary.simpleMessage("明天"),
    "xboardTotal": MessageLookupByLibrary.simpleMessage("总计"),
    "xboardTotalAmount": MessageLookupByLibrary.simpleMessage("订单金额"),
    "xboardTradeNo": MessageLookupByLibrary.simpleMessage("订单号"),
    "xboardTraffic": MessageLookupByLibrary.simpleMessage("流量"),
    "xboardTrafficExhausted": MessageLookupByLibrary.simpleMessage("流量耗尽"),
    "xboardTrafficHistory": MessageLookupByLibrary.simpleMessage("流量历史"),
    "xboardTrafficHistoryTitle": MessageLookupByLibrary.simpleMessage("流量使用历史"),
    "xboardTrafficNoData": MessageLookupByLibrary.simpleMessage("暂无流量数据"),
    "xboardTrafficTotal": MessageLookupByLibrary.simpleMessage("总计"),
    "xboardTrafficUsage": MessageLookupByLibrary.simpleMessage("流量使用"),
    "xboardTrafficUsedUp": MessageLookupByLibrary.simpleMessage("流量已用完"),
    "xboardTunEnabled": MessageLookupByLibrary.simpleMessage("TUN已启用"),
    "xboardTunFeatureFullTraffic": MessageLookupByLibrary.simpleMessage(
      "全流量代理",
    ),
    "xboardTunFeatureFullTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "捕获所有应用的网络流量，无需单独配置",
    ),
    "xboardTunFeaturePerformance": MessageLookupByLibrary.simpleMessage("性能优化"),
    "xboardTunFeaturePerformanceDesc": MessageLookupByLibrary.simpleMessage(
      "减少代理层级，提升网络访问速度",
    ),
    "xboardTunFeatureTransparent": MessageLookupByLibrary.simpleMessage("透明代理"),
    "xboardTunFeatureTransparentDesc": MessageLookupByLibrary.simpleMessage(
      "应用无感知的代理模式，兼容性更好",
    ),
    "xboardTunLater": MessageLookupByLibrary.simpleMessage("稍后再说"),
    "xboardTunModeDescription": MessageLookupByLibrary.simpleMessage(
      "TUN 模式是一种高级网络代理技术，通过虚拟网络接口实现更完整的流量代理。",
    ),
    "xboardTunModeTitle": MessageLookupByLibrary.simpleMessage("TUN 模式"),
    "xboardTunRecommendGlobal": MessageLookupByLibrary.simpleMessage(
      "• 备用方案：全局 + TUN（如规则模式异常时使用）",
    ),
    "xboardTunRecommendRule": MessageLookupByLibrary.simpleMessage(
      "• 日常使用：规则 + TUN（智能分流，性能最佳）",
    ),
    "xboardTunRecommendations": MessageLookupByLibrary.simpleMessage("推荐使用方式"),
    "xboardTwelveMonthCycle": MessageLookupByLibrary.simpleMessage("12个月周期"),
    "xboardTwentyFourMonthCycle": MessageLookupByLibrary.simpleMessage(
      "24个月周期",
    ),
    "xboardTwoYearPayment": MessageLookupByLibrary.simpleMessage("两年付"),
    "xboardUnauthorizedAccess": MessageLookupByLibrary.simpleMessage(
      "未授权访问，请先登录",
    ),
    "xboardUnknownErrorRetry": MessageLookupByLibrary.simpleMessage("未知错误，请重试"),
    "xboardUnknownPriority": MessageLookupByLibrary.simpleMessage("未知"),
    "xboardUnknownUser": MessageLookupByLibrary.simpleMessage("未知用户"),
    "xboardUnlimited": MessageLookupByLibrary.simpleMessage("不限速"),
    "xboardUnlimitedDevices": MessageLookupByLibrary.simpleMessage("不限设备数量"),
    "xboardUnlimitedTime": MessageLookupByLibrary.simpleMessage("不限时"),
    "xboardUnselected": MessageLookupByLibrary.simpleMessage("未选择"),
    "xboardUnsupportedCouponType": MessageLookupByLibrary.simpleMessage(
      "不支持的优惠券类型",
    ),
    "xboardUpdateContent": MessageLookupByLibrary.simpleMessage("更新内容："),
    "xboardUpdateLater": MessageLookupByLibrary.simpleMessage("稍后更新"),
    "xboardUpdateNodes": MessageLookupByLibrary.simpleMessage("更新节点"),
    "xboardUpdateNow": MessageLookupByLibrary.simpleMessage("立即更新"),
    "xboardUpdateSubscriptionRegularly": MessageLookupByLibrary.simpleMessage(
      "定期更新订阅获取最新节点",
    ),
    "xboardUploadTrafficLabel": m55,
    "xboardUsageInstructions": MessageLookupByLibrary.simpleMessage("使用说明"),
    "xboardUsed": MessageLookupByLibrary.simpleMessage("已用"),
    "xboardUsedTraffic": MessageLookupByLibrary.simpleMessage("已用"),
    "xboardUserSpecificRate": MessageLookupByLibrary.simpleMessage("用户专享"),
    "xboardUsingFallbackMode": MessageLookupByLibrary.simpleMessage("使用降级方案"),
    "xboardValidatingConfigFormat": MessageLookupByLibrary.simpleMessage(
      "验证配置格式",
    ),
    "xboardValidatingProfile": MessageLookupByLibrary.simpleMessage("正在验证配置文件"),
    "xboardValidationFailed": MessageLookupByLibrary.simpleMessage("验证失败"),
    "xboardValidityPeriod": MessageLookupByLibrary.simpleMessage("有效期"),
    "xboardVerify": MessageLookupByLibrary.simpleMessage("核验"),
    "xboardVeryPoor": MessageLookupByLibrary.simpleMessage("很差"),
    "xboardViewChart": MessageLookupByLibrary.simpleMessage("查看图表"),
    "xboardViewList": MessageLookupByLibrary.simpleMessage("查看列表"),
    "xboardViewOrders": MessageLookupByLibrary.simpleMessage("查看订单历史"),
    "xboardWaitingForPayment": MessageLookupByLibrary.simpleMessage(
      "正在等待支付...",
    ),
    "xboardWaitingPaymentCompletion": MessageLookupByLibrary.simpleMessage(
      "等待支付完成",
    ),
    "xboardWeeks": MessageLookupByLibrary.simpleMessage("周"),
    "xboardWeeksAgo": MessageLookupByLibrary.simpleMessage("周前"),
    "xboardWithdrawTransferComingSoon": MessageLookupByLibrary.simpleMessage(
      "提现和转账功能即将推出",
    ),
    "xboardYearlyPayment": MessageLookupByLibrary.simpleMessage("年付"),
    "xboardYearsAgo": MessageLookupByLibrary.simpleMessage("年前"),
    "xboardYesterday": MessageLookupByLibrary.simpleMessage("昨天"),
    "years": MessageLookupByLibrary.simpleMessage("年"),
    "yearsAgo": m56,
    "zh_CN": MessageLookupByLibrary.simpleMessage("中文简体"),
  };
}
