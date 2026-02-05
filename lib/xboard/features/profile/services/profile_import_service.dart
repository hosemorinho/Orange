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
      return ImportResult.failure(
        errorMessage: '正在导入中，请稍候',
        errorType: ImportErrorType.unknownError,
      );
    }
    _isImporting = true;
    final stopwatch = Stopwatch()..start();
    try {
      _logger.info('开始导入订阅配置: $url');
      
      // 1. 先下载并验证新配置（不删除旧配置）
      onProgress?.call(ImportStatus.downloading, 0.3, '下载配置文件');
      final profile = await _downloadAndValidateProfile(url);
      onProgress?.call(ImportStatus.validating, 0.6, '验证配置格式');
      
      // 2. 下载成功后，再清理旧配置（避免 UI 闪烁显示"无订阅"）
      onProgress?.call(ImportStatus.cleaning, 0.8, '替换旧的订阅配置');
      await _cleanOldUrlProfiles();
      
      // 3. 添加新配置
      onProgress?.call(ImportStatus.adding, 0.9, '添加到配置列表');
      await _addProfile(profile);
      
      stopwatch.stop();
      onProgress?.call(ImportStatus.success, 1.0, '导入成功');
      _logger.info('订阅配置导入成功，耗时: ${stopwatch.elapsedMilliseconds}ms');
      return ImportResult.success(
        profile: profile,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      _logger.error('订阅配置导入失败', e);
      final errorType = _classifyError(e);
      final userMessage = _getUserFriendlyErrorMessage(e, errorType);
      onProgress?.call(ImportStatus.failed, 0.0, userMessage);
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
      final profiles = _ref.read(profilesProvider);
      final urlProfiles = profiles.where((profile) => profile.type == ProfileType.url).toList();

      for (final profile in urlProfiles) {
        _logger.debug('删除旧的URL配置: ${profile.label ?? profile.id}');
        _ref.read(profilesProvider.notifier).del(profile.id);
        // 删除实际的 yaml 配置文件和 providers 目录，避免文件堆积
        await appController.clearEffect(profile.id);
      }

      _logger.info('清理了 ${urlProfiles.length} 个旧的URL配置');
    } catch (e) {
      _logger.warning('清理旧配置时出错', e);
      throw Exception('清理旧配置失败: $e');
    }
  }
  Future<Profile> _downloadAndValidateProfile(String url) async {
    try {
      _logger.info('开始下载配置: $url');
      
      // 使用 XBoard 订阅下载服务
      _logger.info('📄 使用 XBoard 订阅下载服务（并发竞速）');
      final profile = await SubscriptionDownloader.downloadSubscription(
        url,
        enableRacing: true,
      ).timeout(
        downloadTimeout,
        onTimeout: () {
          throw TimeoutException('下载超时', downloadTimeout);
        },
      );
      
      _logger.info('配置下载和验证成功: ${profile.label ?? profile.id}');
      return profile;
      
    } on TimeoutException catch (e) {
      throw Exception('下载超时: ${e.message}');
    } on SocketException catch (e) {
      throw Exception('网络连接失败: ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP请求失败: ${e.message}');
    } catch (e) {
      if (e.toString().contains('validateConfig')) {
        throw Exception('配置文件格式错误: $e');
      }
      throw Exception('下载配置失败: $e');
    }
  }

  Future<void> _addProfile(Profile profile) async {
    try {
      // 1. 添加配置到列表
      _ref.read(profilesProvider.notifier).put(profile);
      
      // 2. 强制设置为当前配置（订阅导入是用户主动操作，应该立即生效）
      final currentProfileIdNotifier = _ref.read(currentProfileIdProvider.notifier);
      currentProfileIdNotifier.value = profile.id;
      _logger.info('✅ 已设置为当前配置: ${profile.label ?? profile.id}');
      
      // 3. 使用 silence 模式直接应用配置（新路由系统中 homeScaffoldKey 不可用）
      // needSetupProvider 的监听器会触发 handleChangeProfile，但因为 commonScaffoldState 
      // 未 mounted 会失败，所以我们在这里手动用 silence 模式触发
      _logger.info('📋 使用 silence 模式应用配置...');
      try {
        await appController.applyProfile(silence: true);
        _logger.info('✅ 配置应用成功');
      } catch (e) {
        _logger.error('❌ 配置应用失败', e);
        // 不抛出异常，因为配置已经保存了
      }
      
      _logger.info('配置添加成功: ${profile.label ?? profile.id}');
    } catch (e) {
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