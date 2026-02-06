/// Crisp Configuration
///
/// Provides dynamic Crisp website ID resolution:
/// 1. Environment variable (CRISP_WEBSITE_ID) takes priority
/// 2. Falls back to TXT-resolved value from API_TEXT_DOMAIN
library;

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/xboard/infrastructure/infrastructure.dart';

/// Get effective Crisp website ID
///
/// Resolution order:
/// 1. Environment variable `CRISP_WEBSITE_ID` (highest priority)
/// 2. TXT-resolved value from `API_TEXT_DOMAIN`
/// 3. Empty string if neither is available
String get effectiveCrispWebsiteId {
  // Environment variable takes priority
  if (crispWebsiteId.isNotEmpty) {
    return crispWebsiteId;
  }

  // Fall back to TXT-resolved value
  return ApiTextResolver.resolvedCrispWebsiteId ?? '';
}
