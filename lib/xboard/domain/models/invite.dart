import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/invite.freezed.dart';
part 'generated/invite.g.dart';

/// Domain layer: Invite Code model
@freezed
class DomainInviteCode with _$DomainInviteCode {
  const factory DomainInviteCode({
    /// Invite code string
    required String code,

    /// Code status (0=inactive, 1=active)
    @Default(1) int status,

    /// Commission rate for this code (0-100)
    required double commissionRate,

    /// Commission balance earned from this code (cents)
    @Default(0) int commissionBalanceInCents,

    /// Number of registered users
    @Default(0) int registeredUsers,

    /// Page views count
    @Default(0) int pageViews,

    /// Creation timestamp
    required DateTime createdAt,

    /// Metadata
    @Default({}) Map<String, dynamic> metadata,
  }) = _DomainInviteCode;

  const DomainInviteCode._();

  factory DomainInviteCode.fromJson(Map<String, dynamic> json) =>
      _$DomainInviteCodeFromJson(json);

  // ========== Business Logic ==========

  /// Is active
  bool get isActive => status == 1;

  /// Commission balance in yuan
  double get commissionBalance => commissionBalanceInCents / 100.0;

  /// Format commission rate as percentage
  String get formattedRate => '${commissionRate.toStringAsFixed(0)}%';
}

/// Domain layer: Invite Statistics model
///
/// Represents aggregated statistics from V2Board API response:
/// - stat[0]: Total registered users
/// - stat[1]: Settled commission (cents)
/// - stat[2]: Pending commission (cents)
/// - stat[3]: Commission rate (%)
/// - stat[4]: Available commission (cents)
@freezed
class DomainInviteStats with _$DomainInviteStats {
  const factory DomainInviteStats({
    /// Total registered users via all invite codes
    @Default(0) int registeredUsers,

    /// Settled commission in cents
    @Default(0) int settledCommissionInCents,

    /// Pending commission in cents
    @Default(0) int pendingCommissionInCents,

    /// System commission rate (0-100)
    @Default(0) double commissionRate,

    /// Available commission for withdrawal in cents
    @Default(0) int availableCommissionInCents,
  }) = _DomainInviteStats;

  const DomainInviteStats._();

  factory DomainInviteStats.fromJson(Map<String, dynamic> json) =>
      _$DomainInviteStatsFromJson(json);

  // ========== Business Logic ==========

  /// Settled commission in yuan
  double get settledCommission => settledCommissionInCents / 100.0;

  /// Pending commission in yuan
  double get pendingCommission => pendingCommissionInCents / 100.0;

  /// Available commission in yuan
  double get availableCommission => availableCommissionInCents / 100.0;

  /// Format commission rate as percentage
  String get formattedRate => '${commissionRate.toStringAsFixed(0)}%';

  /// Total commission (settled + pending)
  double get totalCommission => settledCommission + pendingCommission;

  /// Has available commission to withdraw
  bool get hasAvailableCommission => availableCommissionInCents > 0;
}
