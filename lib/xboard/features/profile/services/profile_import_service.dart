import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/xboard/features/profile/profile.dart';
import 'package:fl_clash/xboard/features/subscription/services/subscription_downloader.dart';
import 'package:fl_clash/xboard/core/core.dart';

// 初始化文件级日志器
final _logger = FileLogger('profile_import_service.dart');

final xboardProfileImportServiceProvider = Provider<XBoardProfileImportService>((ref) {
  return XBoardProfileImportService(ref);
});
class XBoardProfileImportService {
  final Ref _ref;
  bool _isImporting = false;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration downloadTimeout = Duration(seconds: 30);
  XBoardProfileImportService(this._ref);
  Future<ImportResult> importSubscription(
    String url, {
    Function(ImportStatus, double, String?)? onProgress,
  }) async {
    if (_isImporting) {
      _logger.warning('❌ 已有导入任务在进行，拒绝新的导入');
      return ImportResult.failure(
        errorMessage: '正在导入中，请稍候',
        errorType: ImportErrorType.unknownError,
      );
    }
    _isImporting = true;
    final stopwatch = Stopwatch()..start();
    try {
      _logger.info('════════════════════════════════════════');
      _logger.info('📥 开始导入订阅配置');
      _logger.info('   URL: $url');
      _logger.info('════════════════════════════════════════');

      // 1. 先下载并验证新配置（不删除旧配置）
      _logger.info('[步骤 1/3] 下载并验证配置...');
      onProgress?.call(ImportStatus.downloading, 0.3, '下载配置文件');
      final profile = await _downloadAndValidateProfile(url);
      _logger.info('[步骤 1/3] ✅ 配置下载成功');
      onProgress?.call(ImportStatus.validating, 0.6, '验证配置格式');

      // 2. 下载成功后，再清理旧配置（避免 UI 闪烁显示"无订阅"）
      _logger.info('[步骤 2/3] 清理旧配置...');
      onProgress?.call(ImportStatus.cleaning, 0.8, '替换旧的订阅配置');
      await _cleanOldUrlProfiles();
      _logger.info('[步骤 2/3] ✅ 旧配置清理完成');

      // 3. 添加新配置
      _logger.info('[步骤 3/3] 添加新配置到数据库...');
      onProgress?.call(ImportStatus.adding, 0.9, '添加到配置列表');
      await _addProfile(profile);
      _logger.info('[步骤 3/3] ✅ 新配置添加成功');

      stopwatch.stop();
      onProgress?.call(ImportStatus.success, 1.0, '导入成功');
      _logger.info('════════════════════════════════════════');
      _logger.info('✅ 订阅配置导入成功');
      _logger.info('   总耗时: ${stopwatch.elapsedMilliseconds}ms');
      _logger.info('   配置ID: ${profile.id}');
      _logger.info('   配置名: ${profile.label ?? "无"}');
      _logger.info('════════════════════════════════════════');
      return ImportResult.success(
        profile: profile,
        duration: stopwatch.elapsed,
      );
    } catch (e, st) {
      stopwatch.stop();
      _logger.error('❌ 订阅配置导入失败', e, st);
      _logger.error('   错误类型: ${e.runtimeType}');
      _logger.error('   耗时: ${stopwatch.elapsedMilliseconds}ms');
      final errorType = _classifyError(e);
      final userMessage = _getUserFriendlyErrorMessage(e, errorType);
      onProgress?.call(ImportStatus.failed, 0.0, userMessage);
      _logger.info('════════════════════════════════════════');
      return ImportResult.failure(
        errorMessage: userMessage,
        errorType: errorType,
        duration: stopwatch.elapsed,
      );
    } finally {
      _isImporting = false;
    }
  }
  Future<ImportResult> importSubscriptionWithRetry(
    String url, {
    Function(ImportStatus, double, String?)? onProgress,
    int retries = maxRetries,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      _logger.debug('导入尝试 $attempt/$retries');
      final result = await importSubscription(url, onProgress: onProgress);
      if (result.isSuccess) {
        return result;
      }
      if (result.errorType != ImportErrorType.networkError && 
          result.errorType != ImportErrorType.downloadError) {
        return result;
      }
      if (attempt == retries) {
        return result;
      }
      _logger.debug('等待 ${retryDelay.inSeconds} 秒后重试');
      onProgress?.call(ImportStatus.downloading, 0.0, '第 $attempt 次尝试失败，等待重试...');
      await Future.delayed(retryDelay);
    }
    return ImportResult.failure(
      errorMessage: '多次重试后仍然失败',
      errorType: ImportErrorType.networkError,
    );
  }
  Future<void> _cleanOldUrlProfiles() async {
    try {
      _logger.info('⏳ 清理旧配置...');
      final profiles = _ref.read(profilesProvider);
      final urlProfiles = profiles.where((profile) => profile.type == ProfileType.url).toList();

      _logger.info('   找到 ${urlProfiles.length} 个旧的 URL 类型配置');

      for (final profile in urlProfiles) {
        _logger.info('   删除: ${profile.label ?? profile.id} (ID: ${profile.id})');
        _ref.read(profilesProvider.notifier).del(profile.id);
        // 删除实际的 yaml 配置文件和 providers 目录，避免文件堆积
        try {
          await appController.clearEffect(profile.id);
          _logger.info('     ✅ 已清理本地文件');
        } catch (e) {
          _logger.warning('     ⚠️  清理本地文件失败: $e');
        }
      }

      _logger.info('✅ 清理完成 (清理了 ${urlProfiles.length} 个旧配置)');
    } catch (e, st) {
      _logger.error('❌ 清理旧配置出错', e, st);
      throw Exception('清理旧配置失败: $e');
    }
  }
  Future<Profile> _downloadAndValidateProfile(String url) async {
    try {
      _logger.info('⏳ 开始下载配置...');
      _logger.info('   URL: $url');
      _logger.info('   超时: ${downloadTimeout.inSeconds}s');

      // 使用 XBoard 订阅下载服务
      _logger.info('📄 调用 SubscriptionDownloader.downloadSubscription()...');
      final startTime = DateTime.now();
      final profile = await SubscriptionDownloader.downloadSubscription(
        url,
        enableRacing: true,
      ).timeout(
        downloadTimeout,
        onTimeout: () {
          _logger.error('❌ 下载超时 (>${downloadTimeout.inSeconds}s)');
          throw TimeoutException('下载超时', downloadTimeout);
        },
      );
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;

      _logger.info('✅ 配置下载和验证成功');
      _logger.info('   耗时: ${elapsed}ms');
      _logger.info('   配置ID: ${profile.id}');
      _logger.info('   配置名: ${profile.label ?? "无"}');
      _logger.info('   URL: ${profile.url}');
      _logger.info('   类型: ${profile.type}');
      _logger.info('   当前组: ${profile.currentGroupName ?? "未设置"}');
      return profile;

    } on TimeoutException catch (e) {
      _logger.error('❌ 下载超时异常', e);
      throw Exception('下载超时: ${e.message}');
    } on SocketException catch (e) {
      _logger.error('❌ 网络连接异常', e);
      throw Exception('网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      _logger.error('❌ HTTP请求异常', e);
      throw Exception('HTTP请求失败: ${e.message}');
    } catch (e, st) {
      _logger.error('❌ 下载过程出错', e, st);
      if (e.toString().contains('validateConfig')) {
        _logger.error('   错误原因: 配置格式验证失败（validateConfig）');
        throw Exception('配置文件格式错误: $e');
      }
      if (e.toString().contains('isAndroid') || e.toString().contains('Android')) {
        _logger.error('   错误原因: Android 特定问题');
      }
      throw Exception('下载配置失败: $e');
    }
  }

  Future<void> _addProfile(Profile profile) async {
    try {
      _logger.info('添加配置到数据库...');

      // 1. 添加配置到列表
      _ref.read(profilesProvider.notifier).put(profile);
      _logger.info('配置已保存到数据库 (ID: ${profile.id})');

      // 2. 强制设置为当前配置（订阅导入是用户主动操作，应该立即生效）
      _ref.read(currentProfileIdProvider.notifier).value = profile.id;
      _logger.info('已设置为当前配置');

      // 3. 尝试应用配置到 Clash 核心
      if (_ref.read(initProvider)) {
        _logger.info('核心已初始化，使用 xboardQuickSetup() 原子应用配置...');
        final message = await appController.xboardQuickSetup();
        if (message.isNotEmpty) {
          _logger.warning('xboardQuickSetup 返回错误，回退到 fullSetup(): $message');
          appController.fullSetup();
        }
      } else {
        _logger.info('核心尚未初始化完成，配置将在初始化完成后自动加载');
      }

      _logger.info('配置添加完成 (ID: ${profile.id}, Label: ${profile.label})');
    } catch (e, st) {
      _logger.error('添加配置失败', e, st);
      throw Exception('添加配置失败: $e');
    }
  }
  ImportErrorType _classifyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout') || 
        errorString.contains('连接失败') ||
        errorString.contains('network')) {
      return ImportErrorType.networkError;
    }
    if (errorString.contains('下载') || 
        errorString.contains('http') ||
        errorString.contains('响应')) {
      return ImportErrorType.downloadError;
    }
    if (errorString.contains('validateconfig') ||
        errorString.contains('格式错误') ||
        errorString.contains('解析') ||
        errorString.contains('配置文件格式错误') ||
        errorString.contains('clash配置') ||
        errorString.contains('invalid config')) {
      return ImportErrorType.validationError;
    }
    if (errorString.contains('存储') || 
        errorString.contains('文件') ||
        errorString.contains('保存')) {
      return ImportErrorType.storageError;
    }
    return ImportErrorType.unknownError;
  }
  String _getUserFriendlyErrorMessage(dynamic error, ImportErrorType errorType) {
    final errorString = error.toString();
    
    switch (errorType) {
      case ImportErrorType.networkError:
        return '网络连接失败，请检查网络设置后重试';
      case ImportErrorType.downloadError:
        // 特殊处理User-Agent相关错误
        if (errorString.contains('Invalid HTTP header field value')) {
          return '配置文件下载失败：HTTP请求头格式错误，请稍后重试';
        }
        if (errorString.contains('FormatException')) {
          return '配置文件下载失败：请求格式错误，请稍后重试';
        }
        return '配置文件下载失败，请检查订阅链接是否正确';
      case ImportErrorType.validationError:
        return '配置文件格式验证失败，请联系服务提供商检查配置格式';
      case ImportErrorType.storageError:
        return '保存配置失败，请检查存储空间';
      case ImportErrorType.unknownError:
        // 简化未知错误的显示，避免显示技术细节
        if (errorString.contains('Invalid HTTP header field value') || 
            errorString.contains('FormatException')) {
          return '导入失败：应用配置错误，请稍后重试或重启应用';
        }
        return '导入失败，请稍后重试或联系技术支持';
    }
  }
  bool get isImporting => _isImporting;
} 
