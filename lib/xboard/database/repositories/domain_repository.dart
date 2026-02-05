import 'package:drift/drift.dart';
import '../xboard_database.dart';

/// 域名配置模型（简化版）
class DomainConfig {
  final String url;
  final int? latencyMs;
  final bool isActive;
  final bool isAvailable;
  final DateTime? lastCheckedAt;

  const DomainConfig({
    required this.url,
    this.latencyMs,
    this.isActive = false,
    this.isAvailable = true,
    this.lastCheckedAt,
  });
}

/// 域名数据仓库
class DomainRepository {
  final XBoardDatabase _db;

  DomainRepository(this._db);

  /// 获取所有域名
  Future<List<DomainConfig>> getAllDomains() async {
    final rows = await _db.xBoardDomainsDao.getAllDomains();
    return rows.map(_rowToConfig).toList();
  }

  /// 获取可用域名（按延迟排序）
  Future<List<DomainConfig>> getAvailableDomains() async {
    final rows = await _db.xBoardDomainsDao.getAvailableDomains();
    return rows.map(_rowToConfig).toList();
  }

  /// 获取当前激活的域名
  Future<DomainConfig?> getActiveDomain() async {
    final row = await _db.xBoardDomainsDao.getActiveDomain();
    return row != null ? _rowToConfig(row) : null;
  }

  /// 设置激活域名
  Future<void> setActiveDomain(String url) async {
    await _db.xBoardDomainsDao.setActiveDomain(url);
  }

  /// 保存域名
  Future<void> saveDomain(DomainConfig domain) async {
    await _db.xBoardDomainsDao.upsertDomain(XBoardDomainsCompanion(
      url: Value(domain.url),
      latencyMs: Value(domain.latencyMs),
      isActive: Value(domain.isActive),
      isAvailable: Value(domain.isAvailable),
      lastCheckedAt: Value(domain.lastCheckedAt),
    ));
  }

  /// 批量保存域名
  Future<void> saveDomains(List<DomainConfig> domains) async {
    final companions = domains.map((d) => XBoardDomainsCompanion(
      url: Value(d.url),
      latencyMs: Value(d.latencyMs),
      isActive: Value(d.isActive),
      isAvailable: Value(d.isAvailable),
      lastCheckedAt: Value(d.lastCheckedAt),
    )).toList();
    await _db.xBoardDomainsDao.upsertDomains(companions);
  }

  /// 更新域名延迟
  Future<void> updateLatency(String url, int latencyMs) async {
    await _db.xBoardDomainsDao.updateLatency(url, latencyMs);
  }

  /// 标记域名不可用
  Future<void> markUnavailable(String url) async {
    await _db.xBoardDomainsDao.markUnavailable(url);
  }

  /// 清空所有域名
  Future<void> clearAll() async {
    await _db.xBoardDomainsDao.clearAll();
  }

  DomainConfig _rowToConfig(XBoardDomainRow row) {
    return DomainConfig(
      url: row.url,
      latencyMs: row.latencyMs,
      isActive: row.isActive,
      isAvailable: row.isAvailable,
      lastCheckedAt: row.lastCheckedAt,
    );
  }
}
