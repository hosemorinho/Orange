/// Invite feature - Referral & Commission system
///
/// Provides referral code management and commission tracking:
/// - Create and manage invite codes (max 5)
/// - Track commission statistics
/// - Copy invite codes and links
/// - View commission rates
/// - Transfer commission to wallet
/// - Withdraw commission
library;

// Pages
export 'pages/invite_page.dart';

// Providers
export 'providers/invite_provider.dart';

// Widgets
export 'widgets/invite_stats_section.dart';
export 'widgets/invite_codes_card.dart';
export 'widgets/commission_transfer_dialog.dart';
export 'widgets/commission_withdraw_dialog.dart';
