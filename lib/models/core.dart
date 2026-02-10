import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core.freezed.dart';
part 'generated/core.g.dart';

@freezed
abstract class SetupParams with _$SetupParams {
  const factory SetupParams({
    @JsonKey(name: 'selected-map') required Map<String, String> selectedMap,
    @JsonKey(name: 'test-url') required String testUrl,
  }) = _SetupParams;

  factory SetupParams.fromJson(Map<String, dynamic> json) =>
      _$SetupParamsFromJson(json);
}

@freezed
abstract class UpdateParams with _$UpdateParams {
  const factory UpdateParams({
    required Tun tun,
    @JsonKey(name: 'mixed-port') required int mixedPort,
    @JsonKey(name: 'allow-lan') required bool allowLan,
    @JsonKey(name: 'find-process-mode')
    required FindProcessMode findProcessMode,
    required Mode mode,
    @JsonKey(name: 'log-level') required LogLevel logLevel,
    required bool ipv6,
    @JsonKey(name: 'tcp-concurrent') required bool tcpConcurrent,
    @JsonKey(name: 'external-controller')
    required ExternalControllerStatus externalController,
    @JsonKey(name: 'unified-delay') required bool unifiedDelay,
  }) = _UpdateParams;

  factory UpdateParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateParamsFromJson(json);
}

@freezed
abstract class VpnOptions with _$VpnOptions {
  const factory VpnOptions({
    required bool enable,
    required int port,
    required bool ipv6,
    required bool dnsHijacking,
    required AccessControlProps accessControlProps,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    required String stack,
    @Default([]) List<String> routeAddress,
  }) = _VpnOptions;

  factory VpnOptions.fromJson(Map<String, Object?> json) =>
      _$VpnOptionsFromJson(json);
}

@freezed
abstract class Delay with _$Delay {
  const factory Delay({required String name, required String url, int? value}) =
      _Delay;

  factory Delay.fromJson(Map<String, Object?> json) => _$DelayFromJson(json);
}

@freezed
abstract class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    String? path,
    required int count,
    SubscriptionInfo? subscriptionInfo,
    @JsonKey(name: 'vehicle-type') required String vehicleType,
    @JsonKey(name: 'update-at') required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

extension ExternalProviderExt on ExternalProvider {
  String get updatingKey => 'provider_$name';
}
