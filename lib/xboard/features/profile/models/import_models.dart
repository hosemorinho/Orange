import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/models/profile.dart';
enum ImportStatus {
  idle,        // 空闲状态
  cleaning,    // 清理旧配置
  downloading, // 下载配置
  validating,  // 验证配置
  adding,      // 添加配置
  success,     // 成功完成
  failed,      // 导入失败
}
enum ImportErrorType {
  networkError,     // 网络错误
  downloadError,    // 下载失败
  validationError,  // 配置验证失败
  storageError,     // 存储错误
  unknownError,     // 未知错误
}
class ImportResult {
  final bool isSuccess;
  final String? errorMessage;
  final ImportErrorType? errorType;
  final Profile? profile;
  final Duration? duration;
  const ImportResult({
    required this.isSuccess,
    this.errorMessage,
    this.errorType,
    this.profile,
    this.duration,
  });
  factory ImportResult.success({
    Profile? profile,
    Duration? duration,
  }) {
    return ImportResult(
      isSuccess: true,
      profile: profile,
      duration: duration,
    );
  }
  factory ImportResult.failure({
    required String errorMessage,
    required ImportErrorType errorType,
    Duration? duration,
  }) {
    return ImportResult(
      isSuccess: false,
      errorMessage: errorMessage,
      errorType: errorType,
      duration: duration,
    );
  }
}
class ImportState {
  final ImportStatus status;
  final String? message;
  final double progress; // 0.0 - 1.0
  final String? currentUrl;
  final ImportResult? lastResult;
  final bool isImporting;
  final DateTime? lastSuccessTime; // 最后成功导入的时间
  const ImportState({
    this.status = ImportStatus.idle,
    this.message,
    this.progress = 0.0,
    this.currentUrl,
    this.lastResult,
    this.isImporting = false,
    this.lastSuccessTime,
  });
  ImportState copyWith({
    ImportStatus? status,
    String? message,
    double? progress,
    String? currentUrl,
    ImportResult? lastResult,
    bool? isImporting,
    DateTime? lastSuccessTime,
  }) {
    return ImportState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      currentUrl: currentUrl ?? this.currentUrl,
      lastResult: lastResult ?? this.lastResult,
      isImporting: isImporting ?? this.isImporting,
      lastSuccessTime: lastSuccessTime ?? this.lastSuccessTime,
    );
  }
  /// Localized status text resolved via [appLocalizations].
  String get statusText {
    switch (status) {
      case ImportStatus.idle:
        return appLocalizations.xboardImportStatusIdle;
      case ImportStatus.cleaning:
        return appLocalizations.xboardImportStatusCleaning;
      case ImportStatus.downloading:
        return appLocalizations.xboardImportStatusDownloading;
      case ImportStatus.validating:
        return appLocalizations.xboardImportStatusValidating;
      case ImportStatus.adding:
        return appLocalizations.xboardImportStatusAdding;
      case ImportStatus.success:
        return appLocalizations.xboardImportStatusSuccess;
      case ImportStatus.failed:
        return appLocalizations.xboardImportStatusFailed;
    }
  }

  /// Localized error type message resolved via [appLocalizations].
  String? get errorTypeMessage {
    if (lastResult?.errorType == null) return null;
    switch (lastResult!.errorType!) {
      case ImportErrorType.networkError:
        return appLocalizations.xboardImportErrorNetwork;
      case ImportErrorType.downloadError:
        return appLocalizations.xboardImportErrorDownload;
      case ImportErrorType.validationError:
        return appLocalizations.xboardImportErrorValidation;
      case ImportErrorType.storageError:
        return appLocalizations.xboardImportErrorStorage;
      case ImportErrorType.unknownError:
        return appLocalizations.xboardImportErrorUnknown;
    }
  }

  // Status text keys - to be translated in UI layer with AppLocalizations
  String get statusTextKey {
    switch (status) {
      case ImportStatus.idle:
        return 'xboardImportStatusIdle';
      case ImportStatus.cleaning:
        return 'xboardImportStatusCleaning';
      case ImportStatus.downloading:
        return 'xboardImportStatusDownloading';
      case ImportStatus.validating:
        return 'xboardImportStatusValidating';
      case ImportStatus.adding:
        return 'xboardImportStatusAdding';
      case ImportStatus.success:
        return 'xboardImportStatusSuccess';
      case ImportStatus.failed:
        return 'xboardImportStatusFailed';
    }
  }

  // Error type message keys - to be translated in UI layer with AppLocalizations
  String? get errorTypeMessageKey {
    if (lastResult?.errorType == null) return null;
    switch (lastResult!.errorType!) {
      case ImportErrorType.networkError:
        return 'xboardImportErrorNetwork';
      case ImportErrorType.downloadError:
        return 'xboardImportErrorDownload';
      case ImportErrorType.validationError:
        return 'xboardImportErrorValidation';
      case ImportErrorType.storageError:
        return 'xboardImportErrorStorage';
      case ImportErrorType.unknownError:
        return 'xboardImportErrorUnknown';
    }
  }
} 
