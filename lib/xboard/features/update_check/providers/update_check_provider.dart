import 'package:fl_clash/xboard/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update_check_state.dart';
import '../services/update_service.dart';

// 初始化文件级日志器
final _logger = FileLogger('update_check_provider.dart');

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());
final updateCheckProvider =
    NotifierProvider<UpdateCheckNotifier, UpdateCheckState>(
        UpdateCheckNotifier.new);

class UpdateCheckNotifier extends Notifier<UpdateCheckState> {
  late final UpdateService _updateService;

  @override
  UpdateCheckState build() {
    _updateService = ref.watch(updateServiceProvider);
    return const UpdateCheckState();
  }

  Future<void> initialize() async {
    _logger.info('开始检查更新');
    await checkForUpdates();
  }
  Future<void> refresh() async {
    _logger.info('刷新检查更新');
    await checkForUpdates();
  }
  Future<void> checkForUpdates() async {
    state = state.copyWith(
      isChecking: true,
      error: null,
    );
    try {
      final currentVersion = await _updateService.getCurrentVersion();
      _logger.info('当前版本: $currentVersion');
      state = state.copyWith(currentVersion: currentVersion);

      final updateInfo = await _updateService.checkForUpdates();

      // 如果没有配置更新URL，静默跳过
      if (updateInfo == null) {
        _logger.info('更新检查已跳过（未配置更新服务器）');
        state = state.copyWith(
          isChecking: false,
          hasUpdate: false,
        );
        return;
      }

      state = state.copyWith(
        isChecking: false,
        hasUpdate: updateInfo["hasUpdate"] as bool? ?? false,
        latestVersion: updateInfo["latestVersion"]?.toString(),
        updateUrl: updateInfo["updateUrl"]?.toString(),
        releaseNotes: updateInfo["releaseNotes"]?.toString(),
        forceUpdate: updateInfo["forceUpdate"] as bool? ?? false,
      );
      if (state.hasUpdate) {
        _logger.info('发现新版本: ${state.latestVersion}');
        if (state.releaseNotes != null && state.releaseNotes!.isNotEmpty) {
          // _logger.debug('发布说明: ${state.releaseNotes}');
        }
      } else {
        _logger.info('已是最新版本');
      }
    } catch (e) {
      _logger.error('检查更新失败', e);
      state = state.copyWith(
        isChecking: false,
        error: e.toString(),
      );
    }
  }
}