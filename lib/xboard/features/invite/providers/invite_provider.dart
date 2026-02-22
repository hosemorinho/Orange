import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/xboard/infrastructure/api/v2board_mappers.dart';
import 'package:fl_clash/xboard/core/core.dart';

part 'generated/invite_provider.g.dart';

final _logger = FileLogger('invite_provider.dart');

/// Invite codes and statistics data
class InviteData {
  final List<DomainInviteCode> codes;
  final DomainInviteStats stats;

  const InviteData({
    required this.codes,
    required this.stats,
  });
}

/// Invite data provider
///
/// Fetches invite codes and statistics from API
@riverpod
class InviteDataProvider extends _$InviteDataProvider {
  @override
  Future<InviteData> build() async {
    return await _fetchInviteData();
  }

  Future<InviteData> _fetchInviteData() async {
    try {
      final api = await ref.read(xboardSdkProvider.future);
      final response = await api.getInviteCodes();

      // Parse codes
      final codesJson = response['data']?['codes'] as List<dynamic>? ?? [];
      final codes = codesJson
          .map((json) => mapInviteCode(json as Map<String, dynamic>))
          .toList();

      // Parse stats
      final statList = response['data']?['stat'] as List<dynamic>? ?? [];
      final stats = mapInviteStats(statList);

      return InviteData(codes: codes, stats: stats);
    } catch (e, stackTrace) {
      _logger.error('[InviteDataProvider] Failed to fetch invite data', e, stackTrace);
      rethrow;
    }
  }

  /// Refresh invite data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInviteData());
  }
}

/// Create a new invite code
@riverpod
Future<void> createInviteCode(Ref ref) async {
  try {
    final api = await ref.read(xboardSdkProvider.future);
    await api.createInviteCode();

    // Refresh invite data
    if (!ref.mounted) return;
    ref.invalidate(inviteDataProviderProvider);
  } catch (e, stackTrace) {
    _logger.error('[createInviteCode] Failed to create invite code', e, stackTrace);
    rethrow;
  }
}

/// Transfer commission to balance
@riverpod
Future<void> transferCommission(Ref ref, double amount) async {
  try {
    final api = await ref.read(xboardSdkProvider.future);
    await api.transferCommission(amount);

    // Refresh invite data and user info
    if (!ref.mounted) return;
    ref.invalidate(inviteDataProviderProvider);
  } catch (e, stackTrace) {
    _logger.error('[transferCommission] Failed to transfer commission', e, stackTrace);
    rethrow;
  }
}

/// Get commission config (withdrawal methods)
@riverpod
Future<Map<String, dynamic>> commissionConfig(Ref ref) async {
  try {
    final api = await ref.read(xboardSdkProvider.future);
    final response = await api.getCommissionConfig();
    return response['data'] as Map<String, dynamic>? ?? {};
  } catch (e, stackTrace) {
    _logger.error('[commissionConfig] Failed to get commission config', e, stackTrace);
    rethrow;
  }
}

/// Submit withdrawal ticket
@riverpod
Future<void> withdrawCommission(Ref ref, String method, String account) async {
  try {
    final api = await ref.read(xboardSdkProvider.future);
    await api.withdrawTicket(method, account);

    // Refresh invite data
    if (!ref.mounted) return;
    ref.invalidate(inviteDataProviderProvider);
  } catch (e, stackTrace) {
    _logger.error('[withdrawCommission] Failed to submit withdrawal', e, stackTrace);
    rethrow;
  }
}
