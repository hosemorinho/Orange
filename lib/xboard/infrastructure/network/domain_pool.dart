import 'package:fl_clash/common/constant.dart' show apiTextDomain, appName;
import 'package:fl_clash/xboard/core/core.dart';
import 'package:fl_clash/xboard/config/xboard_config.dart';

import 'api_text_resolver.dart';
import 'domain_racing_service.dart';

final _logger = FileLogger('domain_pool.dart');

/// Manages candidate domains for automatic fallback.
///
/// After initial domain racing selects a winner, DomainPool preserves
/// all candidates so that if the current domain fails, the system can
/// transparently switch to the next candidate (Phase 2) or re-resolve
/// TXT records and re-race (Phase 3).
class DomainPool {
  static DomainPool? _instance;

  List<String> _candidates = []; // ordered: winner first, then by response time
  int _currentIndex = 0;
  late String _currentDomain;
  Function(String newDomain)? onDomainSwitch;

  DomainPool._();

  static DomainPool get instance {
    _instance ??= DomainPool._();
    return _instance!;
  }

  /// Initialize with racing results.
  ///
  /// [winner] is placed first; remaining [allCandidates] follow in order,
  /// with duplicates removed.
  void initialize(
    String winner,
    List<String> allCandidates, {
    Function(String)? onSwitch,
  }) {
    _currentDomain = winner;
    _currentIndex = 0;
    onDomainSwitch = onSwitch;

    // Build ordered list: winner first, then others preserving order
    _candidates = [winner];
    for (final c in allCandidates) {
      if (c != winner) {
        _candidates.add(c);
      }
    }

    _logger.info(
      '[DomainPool] initialized: current=$winner, '
      'candidates=${_candidates.length}',
    );
  }

  /// Current active domain.
  String get currentDomain => _currentDomain;

  /// Whether the pool has been initialized with candidates.
  bool get isInitialized => _candidates.isNotEmpty;

  /// Switch to next candidate domain.
  ///
  /// Returns the new domain, or null if all candidates are exhausted.
  String? switchToNext() {
    if (_candidates.isEmpty) return null;

    _currentIndex++;
    if (_currentIndex >= _candidates.length) {
      _logger.warning('[DomainPool] all ${_candidates.length} candidates exhausted');
      return null;
    }

    _currentDomain = _candidates[_currentIndex];
    _logger.info(
      '[DomainPool] switching to candidate ${_currentIndex + 1}/${_candidates.length}: '
      '$_currentDomain',
    );

    onDomainSwitch?.call(_currentDomain);
    return _currentDomain;
  }

  /// Re-resolve TXT records and re-race all domains (Phase 3 - last resort).
  ///
  /// Returns the new winning domain, or null if resolution/racing fails.
  Future<String?> reResolveAndRace() async {
    _logger.info('[DomainPool] Phase 3: re-resolving TXT and re-racing');

    try {
      List<String> hostsToRace = [];

      // 1. Try TXT resolution if configured
      if (apiTextDomain.isNotEmpty) {
        final config = await ApiTextResolver.resolve(apiTextDomain, appName);
        if (config != null && config.hosts.isNotEmpty) {
          hostsToRace.addAll(config.hosts);
          _logger.info('[DomainPool] TXT resolved ${config.hosts.length} hosts');
        }
      }

      // 2. Add any config-file panel URLs
      final configPanelUrls = XBoardConfig.allPanelUrls;
      for (final url in configPanelUrls) {
        if (!hostsToRace.contains(url)) {
          hostsToRace.add(url);
        }
      }

      if (hostsToRace.isEmpty) {
        _logger.warning('[DomainPool] no hosts to race after re-resolution');
        return null;
      }

      // 3. Race
      final proxyUrls = XBoardConfig.allProxyUrls;
      final result = await DomainRacingService.raceSelectFastestDomain(
        hostsToRace,
        forceHttpsResult: true,
        proxyUrls: proxyUrls,
      );

      if (result == null) {
        _logger.warning('[DomainPool] re-racing failed, no winner');
        return null;
      }

      // 4. Update state
      XBoardConfig.setLastRacingResult(result);
      XBoardConfig.setLastRacingCandidates(hostsToRace);

      _currentDomain = result.domain;
      _currentIndex = 0;
      _candidates = [result.domain];
      for (final c in hostsToRace) {
        if (c != result.domain) {
          _candidates.add(c);
        }
      }

      _logger.info('[DomainPool] re-race winner: ${result.domain}');

      onDomainSwitch?.call(_currentDomain);
      return _currentDomain;
    } catch (e) {
      _logger.error('[DomainPool] re-resolve/race failed', e);
      return null;
    }
  }

  /// Reset failure state after a successful request on the current domain.
  ///
  /// Moves the current domain to position 0 so subsequent failures
  /// start cycling from the next candidate again.
  void resetFailureState() {
    if (_candidates.isEmpty) return;

    // Move current domain to front if not already there
    if (_currentIndex != 0) {
      _candidates.remove(_currentDomain);
      _candidates.insert(0, _currentDomain);
      _currentIndex = 0;
      _logger.info('[DomainPool] failure state reset, current=$_currentDomain');
    }
  }
}
