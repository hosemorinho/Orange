import 'package:fl_clash/xboard/domain/domain.dart';
import '../xboard_database.dart';
import '../converters/converters.dart';

/// 套餐数据仓库
class PlanRepository {
  final XBoardDatabase _db;

  /// 缓存有效期（默认 1 小时）
  final Duration cacheMaxAge;

  PlanRepository(this._db, {this.cacheMaxAge = const Duration(hours: 1)});

  /// 获取所有套餐
  Future<List<DomainPlan>> getAllPlans() async {
    final rows = await _db.xBoardPlansDao.getAllPlans();
    return rows.map((row) => row.toDomain()).toList();
  }

  /// 获取可见套餐
  Future<List<DomainPlan>> getVisiblePlans() async {
    final rows = await _db.xBoardPlansDao.getVisiblePlans();
    return rows.map((row) => row.toDomain()).toList();
  }

  /// 根据 ID 获取套餐
  Future<DomainPlan?> getPlanById(int id) async {
    final row = await _db.xBoardPlansDao.getPlanById(id);
    return row?.toDomain();
  }

  /// 批量保存套餐（替换所有）
  Future<void> replacePlans(List<DomainPlan> plans) async {
    final companions = plans.map((p) => p.toCompanion()).toList();
    await _db.xBoardPlansDao.replacePlans(companions);
  }

  /// 保存单个套餐
  Future<void> savePlan(DomainPlan plan) async {
    await _db.xBoardPlansDao.upsertPlan(plan.toCompanion());
  }

  /// 检查缓存是否过期
  Future<bool> isCacheExpired() async {
    return _db.xBoardPlansDao.isCacheExpired(cacheMaxAge);
  }

  /// 清空所有套餐
  Future<void> clearAll() async {
    await _db.xBoardPlansDao.clearAll();
  }
}
