part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardDomains])
class XBoardDomainsDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardDomainsDaoMixin {
  XBoardDomainsDao(super.attachedDatabase);

  /// 获取所有域名
  Future<List<XBoardDomainRow>> getAllDomains() {
    return select(xBoardDomains).get();
  }

  /// 获取可用域名（按延迟排序）
  Future<List<XBoardDomainRow>> getAvailableDomains() {
    return (select(xBoardDomains)
          ..where((t) => t.isAvailable.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.latencyMs)]))
        .get();
  }

  /// 获取当前激活的域名
  Future<XBoardDomainRow?> getActiveDomain() {
    return (select(xBoardDomains)..where((t) => t.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// 设置激活域名
  Future<void> setActiveDomain(String url) async {
    await transaction(() async {
      // 先取消所有激活状态
      await (update(xBoardDomains)..where((t) => t.isActive.equals(true)))
          .write(const XBoardDomainsCompanion(isActive: Value(false)));
      // 设置新的激活域名
      await (update(xBoardDomains)..where((t) => t.url.equals(url)))
          .write(const XBoardDomainsCompanion(isActive: Value(true)));
    });
  }

  /// 保存或更新域名
  Future<int> upsertDomain(XBoardDomainsCompanion domain) {
    return into(xBoardDomains).insertOnConflictUpdate(domain);
  }

  /// 批量保存域名
  Future<void> upsertDomains(List<XBoardDomainsCompanion> domains) async {
    await batch((b) => b.insertAllOnConflictUpdate(xBoardDomains, domains));
  }

  /// 更新域名延迟
  Future<int> updateLatency(String url, int latencyMs) {
    return (update(xBoardDomains)..where((t) => t.url.equals(url))).write(
      XBoardDomainsCompanion(
        latencyMs: Value(latencyMs),
        lastCheckedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 标记域名不可用
  Future<int> markUnavailable(String url) {
    return (update(xBoardDomains)..where((t) => t.url.equals(url))).write(
      const XBoardDomainsCompanion(
        isAvailable: Value(false),
        isActive: Value(false),
      ),
    );
  }

  /// 清空所有域名
  Future<int> clearAll() {
    return delete(xBoardDomains).go();
  }
}
