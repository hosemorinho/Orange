part of '../xboard_database.dart';

@DriftAccessor(tables: [XBoardPlans])
class XBoardPlansDao extends DatabaseAccessor<XBoardDatabase>
    with _$XBoardPlansDaoMixin {
  XBoardPlansDao(super.attachedDatabase);

  /// 获取所有套餐
  Future<List<XBoardPlanRow>> getAllPlans() {
    return (select(xBoardPlans)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sort),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  /// 获取可见套餐
  Future<List<XBoardPlanRow>> getVisiblePlans() {
    return (select(xBoardPlans)
          ..where((t) => t.isVisible.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sort),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  /// 根据 ID 获取套餐
  Future<XBoardPlanRow?> getPlanById(int id) {
    return (select(xBoardPlans)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 批量保存套餐（替换所有）
  Future<void> replacePlans(List<XBoardPlansCompanion> plans) async {
    await transaction(() async {
      await delete(xBoardPlans).go();
      await batch((b) => b.insertAll(xBoardPlans, plans));
    });
  }

  /// 保存或更新单个套餐
  Future<int> upsertPlan(XBoardPlansCompanion plan) {
    return into(xBoardPlans).insertOnConflictUpdate(plan);
  }

  /// 清空所有套餐
  Future<int> clearAll() {
    return delete(xBoardPlans).go();
  }

  /// 检查缓存是否过期（超过指定时间）
  Future<bool> isCacheExpired(Duration maxAge) async {
    final query = select(xBoardPlans)
      ..orderBy([(t) => OrderingTerm.desc(t.cachedAt)])
      ..limit(1);
    final latest = await query.getSingleOrNull();
    if (latest == null) return true;
    return DateTime.now().difference(latest.cachedAt) > maxAge;
  }
}
