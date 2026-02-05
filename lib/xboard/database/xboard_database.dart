import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:path/path.dart' as p;

part 'generated/xboard_database.g.dart';

// Tables
part 'tables/users.dart';
part 'tables/subscriptions.dart';
part 'tables/plans.dart';
part 'tables/orders.dart';
part 'tables/notice_reads.dart';
part 'tables/domains.dart';
part 'tables/auth_tokens.dart';

// DAOs
part 'dao/users_dao.dart';
part 'dao/subscriptions_dao.dart';
part 'dao/plans_dao.dart';
part 'dao/orders_dao.dart';
part 'dao/notice_reads_dao.dart';
part 'dao/domains_dao.dart';
part 'dao/auth_tokens_dao.dart';

@DriftDatabase(
  tables: [
    XBoardUsers,
    XBoardSubscriptions,
    XBoardPlans,
    XBoardOrders,
    XBoardNoticeReads,
    XBoardDomains,
    XBoardAuthTokens,
  ],
  daos: [
    XBoardUsersDao,
    XBoardSubscriptionsDao,
    XBoardPlansDao,
    XBoardOrdersDao,
    XBoardNoticeReadsDao,
    XBoardDomainsDao,
    XBoardAuthTokensDao,
  ],
)
class XBoardDatabase extends _$XBoardDatabase {
  XBoardDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await appPath.homeDirPath;
      final file = File(p.join(dbFolder, 'xboard.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  /// 清空所有数据（用于登出）
  Future<void> clearAllData() async {
    await transaction(() async {
      await xBoardUsersDao.clearAll();
      await xBoardSubscriptionsDao.clearAll();
      await xBoardPlansDao.clearAll();
      await xBoardOrdersDao.clearAll();
      await xBoardNoticeReadsDao.clearAll();
      await xBoardDomainsDao.clearAll();
      await xBoardAuthTokensDao.clearAll();
    });
  }

  /// 清空用户相关数据（保留域名配置）
  Future<void> clearUserData() async {
    await transaction(() async {
      await xBoardUsersDao.clearAll();
      await xBoardSubscriptionsDao.clearAll();
      await xBoardOrdersDao.clearAll();
      await xBoardAuthTokensDao.clearAll();
    });
  }
}

/// 全局数据库实例
final xboardDatabase = XBoardDatabase();
