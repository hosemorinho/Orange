// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../xboard_database.dart';

// ignore_for_file: type=lint
class $XBoardUsersTable extends XBoardUsers
    with TableInfo<$XBoardUsersTable, XBoardUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferLimitMeta = const VerificationMeta(
    'transferLimit',
  );
  @override
  late final GeneratedColumn<int> transferLimit = GeneratedColumn<int>(
    'transfer_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uploadedBytesMeta = const VerificationMeta(
    'uploadedBytes',
  );
  @override
  late final GeneratedColumn<int> uploadedBytes = GeneratedColumn<int>(
    'uploaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _balanceInCentsMeta = const VerificationMeta(
    'balanceInCents',
  );
  @override
  late final GeneratedColumn<int> balanceInCents = GeneratedColumn<int>(
    'balance_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _commissionBalanceInCentsMeta =
      const VerificationMeta('commissionBalanceInCents');
  @override
  late final GeneratedColumn<int> commissionBalanceInCents =
      GeneratedColumn<int>(
        'commission_balance_in_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _expiredAtMeta = const VerificationMeta(
    'expiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiredAt = GeneratedColumn<DateTime>(
    'expired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bannedMeta = const VerificationMeta('banned');
  @override
  late final GeneratedColumn<bool> banned = GeneratedColumn<bool>(
    'banned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("banned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remindExpireMeta = const VerificationMeta(
    'remindExpire',
  );
  @override
  late final GeneratedColumn<bool> remindExpire = GeneratedColumn<bool>(
    'remind_expire',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_expire" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remindTrafficMeta = const VerificationMeta(
    'remindTraffic',
  );
  @override
  late final GeneratedColumn<bool> remindTraffic = GeneratedColumn<bool>(
    'remind_traffic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_traffic" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionRateMeta = const VerificationMeta(
    'commissionRate',
  );
  @override
  late final GeneratedColumn<double> commissionRate = GeneratedColumn<double>(
    'commission_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telegramIdMeta = const VerificationMeta(
    'telegramId',
  );
  @override
  late final GeneratedColumn<String> telegramId = GeneratedColumn<String>(
    'telegram_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    uuid,
    avatarUrl,
    planId,
    transferLimit,
    uploadedBytes,
    downloadedBytes,
    balanceInCents,
    commissionBalanceInCents,
    expiredAt,
    lastLoginAt,
    createdAt,
    banned,
    remindExpire,
    remindTraffic,
    discount,
    commissionRate,
    telegramId,
    metadata,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardUserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('transfer_limit')) {
      context.handle(
        _transferLimitMeta,
        transferLimit.isAcceptableOrUnknown(
          data['transfer_limit']!,
          _transferLimitMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_bytes')) {
      context.handle(
        _uploadedBytesMeta,
        uploadedBytes.isAcceptableOrUnknown(
          data['uploaded_bytes']!,
          _uploadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('balance_in_cents')) {
      context.handle(
        _balanceInCentsMeta,
        balanceInCents.isAcceptableOrUnknown(
          data['balance_in_cents']!,
          _balanceInCentsMeta,
        ),
      );
    }
    if (data.containsKey('commission_balance_in_cents')) {
      context.handle(
        _commissionBalanceInCentsMeta,
        commissionBalanceInCents.isAcceptableOrUnknown(
          data['commission_balance_in_cents']!,
          _commissionBalanceInCentsMeta,
        ),
      );
    }
    if (data.containsKey('expired_at')) {
      context.handle(
        _expiredAtMeta,
        expiredAt.isAcceptableOrUnknown(data['expired_at']!, _expiredAtMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('banned')) {
      context.handle(
        _bannedMeta,
        banned.isAcceptableOrUnknown(data['banned']!, _bannedMeta),
      );
    }
    if (data.containsKey('remind_expire')) {
      context.handle(
        _remindExpireMeta,
        remindExpire.isAcceptableOrUnknown(
          data['remind_expire']!,
          _remindExpireMeta,
        ),
      );
    }
    if (data.containsKey('remind_traffic')) {
      context.handle(
        _remindTrafficMeta,
        remindTraffic.isAcceptableOrUnknown(
          data['remind_traffic']!,
          _remindTrafficMeta,
        ),
      );
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('commission_rate')) {
      context.handle(
        _commissionRateMeta,
        commissionRate.isAcceptableOrUnknown(
          data['commission_rate']!,
          _commissionRateMeta,
        ),
      );
    }
    if (data.containsKey('telegram_id')) {
      context.handle(
        _telegramIdMeta,
        telegramId.isAcceptableOrUnknown(data['telegram_id']!, _telegramIdMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardUserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      transferLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_limit'],
      )!,
      uploadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_bytes'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      balanceInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_in_cents'],
      )!,
      commissionBalanceInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission_balance_in_cents'],
      )!,
      expiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expired_at'],
      ),
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      banned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}banned'],
      )!,
      remindExpire: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_expire'],
      )!,
      remindTraffic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_traffic'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      ),
      commissionRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission_rate'],
      ),
      telegramId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telegram_id'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $XBoardUsersTable createAlias(String alias) {
    return $XBoardUsersTable(attachedDatabase, alias);
  }
}

class XBoardUserRow extends DataClass implements Insertable<XBoardUserRow> {
  final int id;
  final String email;
  final String uuid;
  final String avatarUrl;
  final int? planId;
  final int transferLimit;
  final int uploadedBytes;
  final int downloadedBytes;
  final int balanceInCents;
  final int commissionBalanceInCents;
  final DateTime? expiredAt;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final bool banned;
  final bool remindExpire;
  final bool remindTraffic;
  final double? discount;
  final double? commissionRate;
  final String? telegramId;
  final String metadata;
  final DateTime? lastSyncedAt;
  const XBoardUserRow({
    required this.id,
    required this.email,
    required this.uuid,
    required this.avatarUrl,
    this.planId,
    required this.transferLimit,
    required this.uploadedBytes,
    required this.downloadedBytes,
    required this.balanceInCents,
    required this.commissionBalanceInCents,
    this.expiredAt,
    this.lastLoginAt,
    this.createdAt,
    required this.banned,
    required this.remindExpire,
    required this.remindTraffic,
    this.discount,
    this.commissionRate,
    this.telegramId,
    required this.metadata,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['uuid'] = Variable<String>(uuid);
    map['avatar_url'] = Variable<String>(avatarUrl);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['transfer_limit'] = Variable<int>(transferLimit);
    map['uploaded_bytes'] = Variable<int>(uploadedBytes);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['balance_in_cents'] = Variable<int>(balanceInCents);
    map['commission_balance_in_cents'] = Variable<int>(
      commissionBalanceInCents,
    );
    if (!nullToAbsent || expiredAt != null) {
      map['expired_at'] = Variable<DateTime>(expiredAt);
    }
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['banned'] = Variable<bool>(banned);
    map['remind_expire'] = Variable<bool>(remindExpire);
    map['remind_traffic'] = Variable<bool>(remindTraffic);
    if (!nullToAbsent || discount != null) {
      map['discount'] = Variable<double>(discount);
    }
    if (!nullToAbsent || commissionRate != null) {
      map['commission_rate'] = Variable<double>(commissionRate);
    }
    if (!nullToAbsent || telegramId != null) {
      map['telegram_id'] = Variable<String>(telegramId);
    }
    map['metadata'] = Variable<String>(metadata);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  XBoardUsersCompanion toCompanion(bool nullToAbsent) {
    return XBoardUsersCompanion(
      id: Value(id),
      email: Value(email),
      uuid: Value(uuid),
      avatarUrl: Value(avatarUrl),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      transferLimit: Value(transferLimit),
      uploadedBytes: Value(uploadedBytes),
      downloadedBytes: Value(downloadedBytes),
      balanceInCents: Value(balanceInCents),
      commissionBalanceInCents: Value(commissionBalanceInCents),
      expiredAt: expiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiredAt),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      banned: Value(banned),
      remindExpire: Value(remindExpire),
      remindTraffic: Value(remindTraffic),
      discount: discount == null && nullToAbsent
          ? const Value.absent()
          : Value(discount),
      commissionRate: commissionRate == null && nullToAbsent
          ? const Value.absent()
          : Value(commissionRate),
      telegramId: telegramId == null && nullToAbsent
          ? const Value.absent()
          : Value(telegramId),
      metadata: Value(metadata),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory XBoardUserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardUserRow(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      uuid: serializer.fromJson<String>(json['uuid']),
      avatarUrl: serializer.fromJson<String>(json['avatarUrl']),
      planId: serializer.fromJson<int?>(json['planId']),
      transferLimit: serializer.fromJson<int>(json['transferLimit']),
      uploadedBytes: serializer.fromJson<int>(json['uploadedBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      balanceInCents: serializer.fromJson<int>(json['balanceInCents']),
      commissionBalanceInCents: serializer.fromJson<int>(
        json['commissionBalanceInCents'],
      ),
      expiredAt: serializer.fromJson<DateTime?>(json['expiredAt']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      banned: serializer.fromJson<bool>(json['banned']),
      remindExpire: serializer.fromJson<bool>(json['remindExpire']),
      remindTraffic: serializer.fromJson<bool>(json['remindTraffic']),
      discount: serializer.fromJson<double?>(json['discount']),
      commissionRate: serializer.fromJson<double?>(json['commissionRate']),
      telegramId: serializer.fromJson<String?>(json['telegramId']),
      metadata: serializer.fromJson<String>(json['metadata']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'uuid': serializer.toJson<String>(uuid),
      'avatarUrl': serializer.toJson<String>(avatarUrl),
      'planId': serializer.toJson<int?>(planId),
      'transferLimit': serializer.toJson<int>(transferLimit),
      'uploadedBytes': serializer.toJson<int>(uploadedBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'balanceInCents': serializer.toJson<int>(balanceInCents),
      'commissionBalanceInCents': serializer.toJson<int>(
        commissionBalanceInCents,
      ),
      'expiredAt': serializer.toJson<DateTime?>(expiredAt),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'banned': serializer.toJson<bool>(banned),
      'remindExpire': serializer.toJson<bool>(remindExpire),
      'remindTraffic': serializer.toJson<bool>(remindTraffic),
      'discount': serializer.toJson<double?>(discount),
      'commissionRate': serializer.toJson<double?>(commissionRate),
      'telegramId': serializer.toJson<String?>(telegramId),
      'metadata': serializer.toJson<String>(metadata),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  XBoardUserRow copyWith({
    int? id,
    String? email,
    String? uuid,
    String? avatarUrl,
    Value<int?> planId = const Value.absent(),
    int? transferLimit,
    int? uploadedBytes,
    int? downloadedBytes,
    int? balanceInCents,
    int? commissionBalanceInCents,
    Value<DateTime?> expiredAt = const Value.absent(),
    Value<DateTime?> lastLoginAt = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    bool? banned,
    bool? remindExpire,
    bool? remindTraffic,
    Value<double?> discount = const Value.absent(),
    Value<double?> commissionRate = const Value.absent(),
    Value<String?> telegramId = const Value.absent(),
    String? metadata,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => XBoardUserRow(
    id: id ?? this.id,
    email: email ?? this.email,
    uuid: uuid ?? this.uuid,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    planId: planId.present ? planId.value : this.planId,
    transferLimit: transferLimit ?? this.transferLimit,
    uploadedBytes: uploadedBytes ?? this.uploadedBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    balanceInCents: balanceInCents ?? this.balanceInCents,
    commissionBalanceInCents:
        commissionBalanceInCents ?? this.commissionBalanceInCents,
    expiredAt: expiredAt.present ? expiredAt.value : this.expiredAt,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    banned: banned ?? this.banned,
    remindExpire: remindExpire ?? this.remindExpire,
    remindTraffic: remindTraffic ?? this.remindTraffic,
    discount: discount.present ? discount.value : this.discount,
    commissionRate: commissionRate.present
        ? commissionRate.value
        : this.commissionRate,
    telegramId: telegramId.present ? telegramId.value : this.telegramId,
    metadata: metadata ?? this.metadata,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  XBoardUserRow copyWithCompanion(XBoardUsersCompanion data) {
    return XBoardUserRow(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      planId: data.planId.present ? data.planId.value : this.planId,
      transferLimit: data.transferLimit.present
          ? data.transferLimit.value
          : this.transferLimit,
      uploadedBytes: data.uploadedBytes.present
          ? data.uploadedBytes.value
          : this.uploadedBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      balanceInCents: data.balanceInCents.present
          ? data.balanceInCents.value
          : this.balanceInCents,
      commissionBalanceInCents: data.commissionBalanceInCents.present
          ? data.commissionBalanceInCents.value
          : this.commissionBalanceInCents,
      expiredAt: data.expiredAt.present ? data.expiredAt.value : this.expiredAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      banned: data.banned.present ? data.banned.value : this.banned,
      remindExpire: data.remindExpire.present
          ? data.remindExpire.value
          : this.remindExpire,
      remindTraffic: data.remindTraffic.present
          ? data.remindTraffic.value
          : this.remindTraffic,
      discount: data.discount.present ? data.discount.value : this.discount,
      commissionRate: data.commissionRate.present
          ? data.commissionRate.value
          : this.commissionRate,
      telegramId: data.telegramId.present
          ? data.telegramId.value
          : this.telegramId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardUserRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('uuid: $uuid, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('planId: $planId, ')
          ..write('transferLimit: $transferLimit, ')
          ..write('uploadedBytes: $uploadedBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('balanceInCents: $balanceInCents, ')
          ..write('commissionBalanceInCents: $commissionBalanceInCents, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('banned: $banned, ')
          ..write('remindExpire: $remindExpire, ')
          ..write('remindTraffic: $remindTraffic, ')
          ..write('discount: $discount, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('telegramId: $telegramId, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    email,
    uuid,
    avatarUrl,
    planId,
    transferLimit,
    uploadedBytes,
    downloadedBytes,
    balanceInCents,
    commissionBalanceInCents,
    expiredAt,
    lastLoginAt,
    createdAt,
    banned,
    remindExpire,
    remindTraffic,
    discount,
    commissionRate,
    telegramId,
    metadata,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardUserRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.uuid == this.uuid &&
          other.avatarUrl == this.avatarUrl &&
          other.planId == this.planId &&
          other.transferLimit == this.transferLimit &&
          other.uploadedBytes == this.uploadedBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.balanceInCents == this.balanceInCents &&
          other.commissionBalanceInCents == this.commissionBalanceInCents &&
          other.expiredAt == this.expiredAt &&
          other.lastLoginAt == this.lastLoginAt &&
          other.createdAt == this.createdAt &&
          other.banned == this.banned &&
          other.remindExpire == this.remindExpire &&
          other.remindTraffic == this.remindTraffic &&
          other.discount == this.discount &&
          other.commissionRate == this.commissionRate &&
          other.telegramId == this.telegramId &&
          other.metadata == this.metadata &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class XBoardUsersCompanion extends UpdateCompanion<XBoardUserRow> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> uuid;
  final Value<String> avatarUrl;
  final Value<int?> planId;
  final Value<int> transferLimit;
  final Value<int> uploadedBytes;
  final Value<int> downloadedBytes;
  final Value<int> balanceInCents;
  final Value<int> commissionBalanceInCents;
  final Value<DateTime?> expiredAt;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime?> createdAt;
  final Value<bool> banned;
  final Value<bool> remindExpire;
  final Value<bool> remindTraffic;
  final Value<double?> discount;
  final Value<double?> commissionRate;
  final Value<String?> telegramId;
  final Value<String> metadata;
  final Value<DateTime?> lastSyncedAt;
  const XBoardUsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.uuid = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.planId = const Value.absent(),
    this.transferLimit = const Value.absent(),
    this.uploadedBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.balanceInCents = const Value.absent(),
    this.commissionBalanceInCents = const Value.absent(),
    this.expiredAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.banned = const Value.absent(),
    this.remindExpire = const Value.absent(),
    this.remindTraffic = const Value.absent(),
    this.discount = const Value.absent(),
    this.commissionRate = const Value.absent(),
    this.telegramId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  XBoardUsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String uuid,
    this.avatarUrl = const Value.absent(),
    this.planId = const Value.absent(),
    this.transferLimit = const Value.absent(),
    this.uploadedBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.balanceInCents = const Value.absent(),
    this.commissionBalanceInCents = const Value.absent(),
    this.expiredAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.banned = const Value.absent(),
    this.remindExpire = const Value.absent(),
    this.remindTraffic = const Value.absent(),
    this.discount = const Value.absent(),
    this.commissionRate = const Value.absent(),
    this.telegramId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : email = Value(email),
       uuid = Value(uuid);
  static Insertable<XBoardUserRow> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? uuid,
    Expression<String>? avatarUrl,
    Expression<int>? planId,
    Expression<int>? transferLimit,
    Expression<int>? uploadedBytes,
    Expression<int>? downloadedBytes,
    Expression<int>? balanceInCents,
    Expression<int>? commissionBalanceInCents,
    Expression<DateTime>? expiredAt,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? banned,
    Expression<bool>? remindExpire,
    Expression<bool>? remindTraffic,
    Expression<double>? discount,
    Expression<double>? commissionRate,
    Expression<String>? telegramId,
    Expression<String>? metadata,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (uuid != null) 'uuid': uuid,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (planId != null) 'plan_id': planId,
      if (transferLimit != null) 'transfer_limit': transferLimit,
      if (uploadedBytes != null) 'uploaded_bytes': uploadedBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (balanceInCents != null) 'balance_in_cents': balanceInCents,
      if (commissionBalanceInCents != null)
        'commission_balance_in_cents': commissionBalanceInCents,
      if (expiredAt != null) 'expired_at': expiredAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (createdAt != null) 'created_at': createdAt,
      if (banned != null) 'banned': banned,
      if (remindExpire != null) 'remind_expire': remindExpire,
      if (remindTraffic != null) 'remind_traffic': remindTraffic,
      if (discount != null) 'discount': discount,
      if (commissionRate != null) 'commission_rate': commissionRate,
      if (telegramId != null) 'telegram_id': telegramId,
      if (metadata != null) 'metadata': metadata,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  XBoardUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? uuid,
    Value<String>? avatarUrl,
    Value<int?>? planId,
    Value<int>? transferLimit,
    Value<int>? uploadedBytes,
    Value<int>? downloadedBytes,
    Value<int>? balanceInCents,
    Value<int>? commissionBalanceInCents,
    Value<DateTime?>? expiredAt,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime?>? createdAt,
    Value<bool>? banned,
    Value<bool>? remindExpire,
    Value<bool>? remindTraffic,
    Value<double?>? discount,
    Value<double?>? commissionRate,
    Value<String?>? telegramId,
    Value<String>? metadata,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return XBoardUsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      uuid: uuid ?? this.uuid,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      planId: planId ?? this.planId,
      transferLimit: transferLimit ?? this.transferLimit,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      balanceInCents: balanceInCents ?? this.balanceInCents,
      commissionBalanceInCents:
          commissionBalanceInCents ?? this.commissionBalanceInCents,
      expiredAt: expiredAt ?? this.expiredAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      banned: banned ?? this.banned,
      remindExpire: remindExpire ?? this.remindExpire,
      remindTraffic: remindTraffic ?? this.remindTraffic,
      discount: discount ?? this.discount,
      commissionRate: commissionRate ?? this.commissionRate,
      telegramId: telegramId ?? this.telegramId,
      metadata: metadata ?? this.metadata,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (transferLimit.present) {
      map['transfer_limit'] = Variable<int>(transferLimit.value);
    }
    if (uploadedBytes.present) {
      map['uploaded_bytes'] = Variable<int>(uploadedBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (balanceInCents.present) {
      map['balance_in_cents'] = Variable<int>(balanceInCents.value);
    }
    if (commissionBalanceInCents.present) {
      map['commission_balance_in_cents'] = Variable<int>(
        commissionBalanceInCents.value,
      );
    }
    if (expiredAt.present) {
      map['expired_at'] = Variable<DateTime>(expiredAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (banned.present) {
      map['banned'] = Variable<bool>(banned.value);
    }
    if (remindExpire.present) {
      map['remind_expire'] = Variable<bool>(remindExpire.value);
    }
    if (remindTraffic.present) {
      map['remind_traffic'] = Variable<bool>(remindTraffic.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (commissionRate.present) {
      map['commission_rate'] = Variable<double>(commissionRate.value);
    }
    if (telegramId.present) {
      map['telegram_id'] = Variable<String>(telegramId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardUsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('uuid: $uuid, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('planId: $planId, ')
          ..write('transferLimit: $transferLimit, ')
          ..write('uploadedBytes: $uploadedBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('balanceInCents: $balanceInCents, ')
          ..write('commissionBalanceInCents: $commissionBalanceInCents, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('banned: $banned, ')
          ..write('remindExpire: $remindExpire, ')
          ..write('remindTraffic: $remindTraffic, ')
          ..write('discount: $discount, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('telegramId: $telegramId, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardSubscriptionsTable extends XBoardSubscriptions
    with TableInfo<$XBoardSubscriptionsTable, XBoardSubscriptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subscribeUrlMeta = const VerificationMeta(
    'subscribeUrl',
  );
  @override
  late final GeneratedColumn<String> subscribeUrl = GeneratedColumn<String>(
    'subscribe_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planNameMeta = const VerificationMeta(
    'planName',
  );
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
    'plan_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferLimitMeta = const VerificationMeta(
    'transferLimit',
  );
  @override
  late final GeneratedColumn<int> transferLimit = GeneratedColumn<int>(
    'transfer_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uploadedBytesMeta = const VerificationMeta(
    'uploadedBytes',
  );
  @override
  late final GeneratedColumn<int> uploadedBytes = GeneratedColumn<int>(
    'uploaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedLimitMeta = const VerificationMeta(
    'speedLimit',
  );
  @override
  late final GeneratedColumn<int> speedLimit = GeneratedColumn<int>(
    'speed_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceLimitMeta = const VerificationMeta(
    'deviceLimit',
  );
  @override
  late final GeneratedColumn<int> deviceLimit = GeneratedColumn<int>(
    'device_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiredAtMeta = const VerificationMeta(
    'expiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiredAt = GeneratedColumn<DateTime>(
    'expired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextResetAtMeta = const VerificationMeta(
    'nextResetAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextResetAt = GeneratedColumn<DateTime>(
    'next_reset_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    subscribeUrl,
    uuid,
    planId,
    planName,
    token,
    transferLimit,
    uploadedBytes,
    downloadedBytes,
    speedLimit,
    deviceLimit,
    expiredAt,
    nextResetAt,
    metadata,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardSubscriptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('subscribe_url')) {
      context.handle(
        _subscribeUrlMeta,
        subscribeUrl.isAcceptableOrUnknown(
          data['subscribe_url']!,
          _subscribeUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribeUrlMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('plan_name')) {
      context.handle(
        _planNameMeta,
        planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('transfer_limit')) {
      context.handle(
        _transferLimitMeta,
        transferLimit.isAcceptableOrUnknown(
          data['transfer_limit']!,
          _transferLimitMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_bytes')) {
      context.handle(
        _uploadedBytesMeta,
        uploadedBytes.isAcceptableOrUnknown(
          data['uploaded_bytes']!,
          _uploadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('speed_limit')) {
      context.handle(
        _speedLimitMeta,
        speedLimit.isAcceptableOrUnknown(data['speed_limit']!, _speedLimitMeta),
      );
    }
    if (data.containsKey('device_limit')) {
      context.handle(
        _deviceLimitMeta,
        deviceLimit.isAcceptableOrUnknown(
          data['device_limit']!,
          _deviceLimitMeta,
        ),
      );
    }
    if (data.containsKey('expired_at')) {
      context.handle(
        _expiredAtMeta,
        expiredAt.isAcceptableOrUnknown(data['expired_at']!, _expiredAtMeta),
      );
    }
    if (data.containsKey('next_reset_at')) {
      context.handle(
        _nextResetAtMeta,
        nextResetAt.isAcceptableOrUnknown(
          data['next_reset_at']!,
          _nextResetAtMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardSubscriptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardSubscriptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      subscribeUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscribe_url'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      planName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name'],
      ),
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      transferLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_limit'],
      )!,
      uploadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_bytes'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      speedLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_limit'],
      ),
      deviceLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_limit'],
      ),
      expiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expired_at'],
      ),
      nextResetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_reset_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $XBoardSubscriptionsTable createAlias(String alias) {
    return $XBoardSubscriptionsTable(attachedDatabase, alias);
  }
}

class XBoardSubscriptionRow extends DataClass
    implements Insertable<XBoardSubscriptionRow> {
  final int id;
  final String email;
  final String subscribeUrl;
  final String uuid;
  final int planId;
  final String? planName;
  final String? token;
  final int transferLimit;
  final int uploadedBytes;
  final int downloadedBytes;
  final int? speedLimit;
  final int? deviceLimit;
  final DateTime? expiredAt;
  final DateTime? nextResetAt;
  final String metadata;
  final DateTime? lastSyncedAt;
  const XBoardSubscriptionRow({
    required this.id,
    required this.email,
    required this.subscribeUrl,
    required this.uuid,
    required this.planId,
    this.planName,
    this.token,
    required this.transferLimit,
    required this.uploadedBytes,
    required this.downloadedBytes,
    this.speedLimit,
    this.deviceLimit,
    this.expiredAt,
    this.nextResetAt,
    required this.metadata,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['subscribe_url'] = Variable<String>(subscribeUrl);
    map['uuid'] = Variable<String>(uuid);
    map['plan_id'] = Variable<int>(planId);
    if (!nullToAbsent || planName != null) {
      map['plan_name'] = Variable<String>(planName);
    }
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    map['transfer_limit'] = Variable<int>(transferLimit);
    map['uploaded_bytes'] = Variable<int>(uploadedBytes);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    if (!nullToAbsent || speedLimit != null) {
      map['speed_limit'] = Variable<int>(speedLimit);
    }
    if (!nullToAbsent || deviceLimit != null) {
      map['device_limit'] = Variable<int>(deviceLimit);
    }
    if (!nullToAbsent || expiredAt != null) {
      map['expired_at'] = Variable<DateTime>(expiredAt);
    }
    if (!nullToAbsent || nextResetAt != null) {
      map['next_reset_at'] = Variable<DateTime>(nextResetAt);
    }
    map['metadata'] = Variable<String>(metadata);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  XBoardSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return XBoardSubscriptionsCompanion(
      id: Value(id),
      email: Value(email),
      subscribeUrl: Value(subscribeUrl),
      uuid: Value(uuid),
      planId: Value(planId),
      planName: planName == null && nullToAbsent
          ? const Value.absent()
          : Value(planName),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      transferLimit: Value(transferLimit),
      uploadedBytes: Value(uploadedBytes),
      downloadedBytes: Value(downloadedBytes),
      speedLimit: speedLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(speedLimit),
      deviceLimit: deviceLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceLimit),
      expiredAt: expiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiredAt),
      nextResetAt: nextResetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextResetAt),
      metadata: Value(metadata),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory XBoardSubscriptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardSubscriptionRow(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      subscribeUrl: serializer.fromJson<String>(json['subscribeUrl']),
      uuid: serializer.fromJson<String>(json['uuid']),
      planId: serializer.fromJson<int>(json['planId']),
      planName: serializer.fromJson<String?>(json['planName']),
      token: serializer.fromJson<String?>(json['token']),
      transferLimit: serializer.fromJson<int>(json['transferLimit']),
      uploadedBytes: serializer.fromJson<int>(json['uploadedBytes']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      speedLimit: serializer.fromJson<int?>(json['speedLimit']),
      deviceLimit: serializer.fromJson<int?>(json['deviceLimit']),
      expiredAt: serializer.fromJson<DateTime?>(json['expiredAt']),
      nextResetAt: serializer.fromJson<DateTime?>(json['nextResetAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'subscribeUrl': serializer.toJson<String>(subscribeUrl),
      'uuid': serializer.toJson<String>(uuid),
      'planId': serializer.toJson<int>(planId),
      'planName': serializer.toJson<String?>(planName),
      'token': serializer.toJson<String?>(token),
      'transferLimit': serializer.toJson<int>(transferLimit),
      'uploadedBytes': serializer.toJson<int>(uploadedBytes),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'speedLimit': serializer.toJson<int?>(speedLimit),
      'deviceLimit': serializer.toJson<int?>(deviceLimit),
      'expiredAt': serializer.toJson<DateTime?>(expiredAt),
      'nextResetAt': serializer.toJson<DateTime?>(nextResetAt),
      'metadata': serializer.toJson<String>(metadata),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  XBoardSubscriptionRow copyWith({
    int? id,
    String? email,
    String? subscribeUrl,
    String? uuid,
    int? planId,
    Value<String?> planName = const Value.absent(),
    Value<String?> token = const Value.absent(),
    int? transferLimit,
    int? uploadedBytes,
    int? downloadedBytes,
    Value<int?> speedLimit = const Value.absent(),
    Value<int?> deviceLimit = const Value.absent(),
    Value<DateTime?> expiredAt = const Value.absent(),
    Value<DateTime?> nextResetAt = const Value.absent(),
    String? metadata,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => XBoardSubscriptionRow(
    id: id ?? this.id,
    email: email ?? this.email,
    subscribeUrl: subscribeUrl ?? this.subscribeUrl,
    uuid: uuid ?? this.uuid,
    planId: planId ?? this.planId,
    planName: planName.present ? planName.value : this.planName,
    token: token.present ? token.value : this.token,
    transferLimit: transferLimit ?? this.transferLimit,
    uploadedBytes: uploadedBytes ?? this.uploadedBytes,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    speedLimit: speedLimit.present ? speedLimit.value : this.speedLimit,
    deviceLimit: deviceLimit.present ? deviceLimit.value : this.deviceLimit,
    expiredAt: expiredAt.present ? expiredAt.value : this.expiredAt,
    nextResetAt: nextResetAt.present ? nextResetAt.value : this.nextResetAt,
    metadata: metadata ?? this.metadata,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  XBoardSubscriptionRow copyWithCompanion(XBoardSubscriptionsCompanion data) {
    return XBoardSubscriptionRow(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      subscribeUrl: data.subscribeUrl.present
          ? data.subscribeUrl.value
          : this.subscribeUrl,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      planId: data.planId.present ? data.planId.value : this.planId,
      planName: data.planName.present ? data.planName.value : this.planName,
      token: data.token.present ? data.token.value : this.token,
      transferLimit: data.transferLimit.present
          ? data.transferLimit.value
          : this.transferLimit,
      uploadedBytes: data.uploadedBytes.present
          ? data.uploadedBytes.value
          : this.uploadedBytes,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      speedLimit: data.speedLimit.present
          ? data.speedLimit.value
          : this.speedLimit,
      deviceLimit: data.deviceLimit.present
          ? data.deviceLimit.value
          : this.deviceLimit,
      expiredAt: data.expiredAt.present ? data.expiredAt.value : this.expiredAt,
      nextResetAt: data.nextResetAt.present
          ? data.nextResetAt.value
          : this.nextResetAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardSubscriptionRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('subscribeUrl: $subscribeUrl, ')
          ..write('uuid: $uuid, ')
          ..write('planId: $planId, ')
          ..write('planName: $planName, ')
          ..write('token: $token, ')
          ..write('transferLimit: $transferLimit, ')
          ..write('uploadedBytes: $uploadedBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('speedLimit: $speedLimit, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('nextResetAt: $nextResetAt, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    subscribeUrl,
    uuid,
    planId,
    planName,
    token,
    transferLimit,
    uploadedBytes,
    downloadedBytes,
    speedLimit,
    deviceLimit,
    expiredAt,
    nextResetAt,
    metadata,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardSubscriptionRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.subscribeUrl == this.subscribeUrl &&
          other.uuid == this.uuid &&
          other.planId == this.planId &&
          other.planName == this.planName &&
          other.token == this.token &&
          other.transferLimit == this.transferLimit &&
          other.uploadedBytes == this.uploadedBytes &&
          other.downloadedBytes == this.downloadedBytes &&
          other.speedLimit == this.speedLimit &&
          other.deviceLimit == this.deviceLimit &&
          other.expiredAt == this.expiredAt &&
          other.nextResetAt == this.nextResetAt &&
          other.metadata == this.metadata &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class XBoardSubscriptionsCompanion
    extends UpdateCompanion<XBoardSubscriptionRow> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> subscribeUrl;
  final Value<String> uuid;
  final Value<int> planId;
  final Value<String?> planName;
  final Value<String?> token;
  final Value<int> transferLimit;
  final Value<int> uploadedBytes;
  final Value<int> downloadedBytes;
  final Value<int?> speedLimit;
  final Value<int?> deviceLimit;
  final Value<DateTime?> expiredAt;
  final Value<DateTime?> nextResetAt;
  final Value<String> metadata;
  final Value<DateTime?> lastSyncedAt;
  const XBoardSubscriptionsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.subscribeUrl = const Value.absent(),
    this.uuid = const Value.absent(),
    this.planId = const Value.absent(),
    this.planName = const Value.absent(),
    this.token = const Value.absent(),
    this.transferLimit = const Value.absent(),
    this.uploadedBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.speedLimit = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.expiredAt = const Value.absent(),
    this.nextResetAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  XBoardSubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String subscribeUrl,
    required String uuid,
    required int planId,
    this.planName = const Value.absent(),
    this.token = const Value.absent(),
    this.transferLimit = const Value.absent(),
    this.uploadedBytes = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.speedLimit = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.expiredAt = const Value.absent(),
    this.nextResetAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : email = Value(email),
       subscribeUrl = Value(subscribeUrl),
       uuid = Value(uuid),
       planId = Value(planId);
  static Insertable<XBoardSubscriptionRow> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? subscribeUrl,
    Expression<String>? uuid,
    Expression<int>? planId,
    Expression<String>? planName,
    Expression<String>? token,
    Expression<int>? transferLimit,
    Expression<int>? uploadedBytes,
    Expression<int>? downloadedBytes,
    Expression<int>? speedLimit,
    Expression<int>? deviceLimit,
    Expression<DateTime>? expiredAt,
    Expression<DateTime>? nextResetAt,
    Expression<String>? metadata,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (subscribeUrl != null) 'subscribe_url': subscribeUrl,
      if (uuid != null) 'uuid': uuid,
      if (planId != null) 'plan_id': planId,
      if (planName != null) 'plan_name': planName,
      if (token != null) 'token': token,
      if (transferLimit != null) 'transfer_limit': transferLimit,
      if (uploadedBytes != null) 'uploaded_bytes': uploadedBytes,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (speedLimit != null) 'speed_limit': speedLimit,
      if (deviceLimit != null) 'device_limit': deviceLimit,
      if (expiredAt != null) 'expired_at': expiredAt,
      if (nextResetAt != null) 'next_reset_at': nextResetAt,
      if (metadata != null) 'metadata': metadata,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  XBoardSubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? subscribeUrl,
    Value<String>? uuid,
    Value<int>? planId,
    Value<String?>? planName,
    Value<String?>? token,
    Value<int>? transferLimit,
    Value<int>? uploadedBytes,
    Value<int>? downloadedBytes,
    Value<int?>? speedLimit,
    Value<int?>? deviceLimit,
    Value<DateTime?>? expiredAt,
    Value<DateTime?>? nextResetAt,
    Value<String>? metadata,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return XBoardSubscriptionsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      subscribeUrl: subscribeUrl ?? this.subscribeUrl,
      uuid: uuid ?? this.uuid,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      token: token ?? this.token,
      transferLimit: transferLimit ?? this.transferLimit,
      uploadedBytes: uploadedBytes ?? this.uploadedBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      speedLimit: speedLimit ?? this.speedLimit,
      deviceLimit: deviceLimit ?? this.deviceLimit,
      expiredAt: expiredAt ?? this.expiredAt,
      nextResetAt: nextResetAt ?? this.nextResetAt,
      metadata: metadata ?? this.metadata,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (subscribeUrl.present) {
      map['subscribe_url'] = Variable<String>(subscribeUrl.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (transferLimit.present) {
      map['transfer_limit'] = Variable<int>(transferLimit.value);
    }
    if (uploadedBytes.present) {
      map['uploaded_bytes'] = Variable<int>(uploadedBytes.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (speedLimit.present) {
      map['speed_limit'] = Variable<int>(speedLimit.value);
    }
    if (deviceLimit.present) {
      map['device_limit'] = Variable<int>(deviceLimit.value);
    }
    if (expiredAt.present) {
      map['expired_at'] = Variable<DateTime>(expiredAt.value);
    }
    if (nextResetAt.present) {
      map['next_reset_at'] = Variable<DateTime>(nextResetAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardSubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('subscribeUrl: $subscribeUrl, ')
          ..write('uuid: $uuid, ')
          ..write('planId: $planId, ')
          ..write('planName: $planName, ')
          ..write('token: $token, ')
          ..write('transferLimit: $transferLimit, ')
          ..write('uploadedBytes: $uploadedBytes, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('speedLimit: $speedLimit, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('expiredAt: $expiredAt, ')
          ..write('nextResetAt: $nextResetAt, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardPlansTable extends XBoardPlans
    with TableInfo<$XBoardPlansTable, XBoardPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferQuotaMeta = const VerificationMeta(
    'transferQuota',
  );
  @override
  late final GeneratedColumn<int> transferQuota = GeneratedColumn<int>(
    'transfer_quota',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _speedLimitMeta = const VerificationMeta(
    'speedLimit',
  );
  @override
  late final GeneratedColumn<int> speedLimit = GeneratedColumn<int>(
    'speed_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceLimitMeta = const VerificationMeta(
    'deviceLimit',
  );
  @override
  late final GeneratedColumn<int> deviceLimit = GeneratedColumn<int>(
    'device_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVisibleMeta = const VerificationMeta(
    'isVisible',
  );
  @override
  late final GeneratedColumn<bool> isVisible = GeneratedColumn<bool>(
    'is_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _renewableMeta = const VerificationMeta(
    'renewable',
  );
  @override
  late final GeneratedColumn<bool> renewable = GeneratedColumn<bool>(
    'renewable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("renewable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onetimePriceMeta = const VerificationMeta(
    'onetimePrice',
  );
  @override
  late final GeneratedColumn<double> onetimePrice = GeneratedColumn<double>(
    'onetime_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyPriceMeta = const VerificationMeta(
    'monthlyPrice',
  );
  @override
  late final GeneratedColumn<double> monthlyPrice = GeneratedColumn<double>(
    'monthly_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quarterlyPriceMeta = const VerificationMeta(
    'quarterlyPrice',
  );
  @override
  late final GeneratedColumn<double> quarterlyPrice = GeneratedColumn<double>(
    'quarterly_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _halfYearlyPriceMeta = const VerificationMeta(
    'halfYearlyPrice',
  );
  @override
  late final GeneratedColumn<double> halfYearlyPrice = GeneratedColumn<double>(
    'half_yearly_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearlyPriceMeta = const VerificationMeta(
    'yearlyPrice',
  );
  @override
  late final GeneratedColumn<double> yearlyPrice = GeneratedColumn<double>(
    'yearly_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _twoYearPriceMeta = const VerificationMeta(
    'twoYearPrice',
  );
  @override
  late final GeneratedColumn<double> twoYearPrice = GeneratedColumn<double>(
    'two_year_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _threeYearPriceMeta = const VerificationMeta(
    'threeYearPrice',
  );
  @override
  late final GeneratedColumn<double> threeYearPrice = GeneratedColumn<double>(
    'three_year_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resetPriceMeta = const VerificationMeta(
    'resetPrice',
  );
  @override
  late final GeneratedColumn<double> resetPrice = GeneratedColumn<double>(
    'reset_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    groupId,
    transferQuota,
    description,
    tags,
    speedLimit,
    deviceLimit,
    isVisible,
    renewable,
    sort,
    onetimePrice,
    monthlyPrice,
    quarterlyPrice,
    halfYearlyPrice,
    yearlyPrice,
    twoYearPrice,
    threeYearPrice,
    resetPrice,
    createdAt,
    updatedAt,
    metadata,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('transfer_quota')) {
      context.handle(
        _transferQuotaMeta,
        transferQuota.isAcceptableOrUnknown(
          data['transfer_quota']!,
          _transferQuotaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferQuotaMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('speed_limit')) {
      context.handle(
        _speedLimitMeta,
        speedLimit.isAcceptableOrUnknown(data['speed_limit']!, _speedLimitMeta),
      );
    }
    if (data.containsKey('device_limit')) {
      context.handle(
        _deviceLimitMeta,
        deviceLimit.isAcceptableOrUnknown(
          data['device_limit']!,
          _deviceLimitMeta,
        ),
      );
    }
    if (data.containsKey('is_visible')) {
      context.handle(
        _isVisibleMeta,
        isVisible.isAcceptableOrUnknown(data['is_visible']!, _isVisibleMeta),
      );
    }
    if (data.containsKey('renewable')) {
      context.handle(
        _renewableMeta,
        renewable.isAcceptableOrUnknown(data['renewable']!, _renewableMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    if (data.containsKey('onetime_price')) {
      context.handle(
        _onetimePriceMeta,
        onetimePrice.isAcceptableOrUnknown(
          data['onetime_price']!,
          _onetimePriceMeta,
        ),
      );
    }
    if (data.containsKey('monthly_price')) {
      context.handle(
        _monthlyPriceMeta,
        monthlyPrice.isAcceptableOrUnknown(
          data['monthly_price']!,
          _monthlyPriceMeta,
        ),
      );
    }
    if (data.containsKey('quarterly_price')) {
      context.handle(
        _quarterlyPriceMeta,
        quarterlyPrice.isAcceptableOrUnknown(
          data['quarterly_price']!,
          _quarterlyPriceMeta,
        ),
      );
    }
    if (data.containsKey('half_yearly_price')) {
      context.handle(
        _halfYearlyPriceMeta,
        halfYearlyPrice.isAcceptableOrUnknown(
          data['half_yearly_price']!,
          _halfYearlyPriceMeta,
        ),
      );
    }
    if (data.containsKey('yearly_price')) {
      context.handle(
        _yearlyPriceMeta,
        yearlyPrice.isAcceptableOrUnknown(
          data['yearly_price']!,
          _yearlyPriceMeta,
        ),
      );
    }
    if (data.containsKey('two_year_price')) {
      context.handle(
        _twoYearPriceMeta,
        twoYearPrice.isAcceptableOrUnknown(
          data['two_year_price']!,
          _twoYearPriceMeta,
        ),
      );
    }
    if (data.containsKey('three_year_price')) {
      context.handle(
        _threeYearPriceMeta,
        threeYearPrice.isAcceptableOrUnknown(
          data['three_year_price']!,
          _threeYearPriceMeta,
        ),
      );
    }
    if (data.containsKey('reset_price')) {
      context.handle(
        _resetPriceMeta,
        resetPrice.isAcceptableOrUnknown(data['reset_price']!, _resetPriceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardPlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_id'],
      )!,
      transferQuota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_quota'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      speedLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_limit'],
      ),
      deviceLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_limit'],
      ),
      isVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_visible'],
      )!,
      renewable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}renewable'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      ),
      onetimePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}onetime_price'],
      ),
      monthlyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_price'],
      ),
      quarterlyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quarterly_price'],
      ),
      halfYearlyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}half_yearly_price'],
      ),
      yearlyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yearly_price'],
      ),
      twoYearPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}two_year_price'],
      ),
      threeYearPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}three_year_price'],
      ),
      resetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reset_price'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $XBoardPlansTable createAlias(String alias) {
    return $XBoardPlansTable(attachedDatabase, alias);
  }
}

class XBoardPlanRow extends DataClass implements Insertable<XBoardPlanRow> {
  final int id;
  final String name;
  final int groupId;
  final int transferQuota;
  final String? description;
  final String tags;
  final int? speedLimit;
  final int? deviceLimit;
  final bool isVisible;
  final bool renewable;
  final int? sort;
  final double? onetimePrice;
  final double? monthlyPrice;
  final double? quarterlyPrice;
  final double? halfYearlyPrice;
  final double? yearlyPrice;
  final double? twoYearPrice;
  final double? threeYearPrice;
  final double? resetPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String metadata;
  final DateTime cachedAt;
  const XBoardPlanRow({
    required this.id,
    required this.name,
    required this.groupId,
    required this.transferQuota,
    this.description,
    required this.tags,
    this.speedLimit,
    this.deviceLimit,
    required this.isVisible,
    required this.renewable,
    this.sort,
    this.onetimePrice,
    this.monthlyPrice,
    this.quarterlyPrice,
    this.halfYearlyPrice,
    this.yearlyPrice,
    this.twoYearPrice,
    this.threeYearPrice,
    this.resetPrice,
    this.createdAt,
    this.updatedAt,
    required this.metadata,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['group_id'] = Variable<int>(groupId);
    map['transfer_quota'] = Variable<int>(transferQuota);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || speedLimit != null) {
      map['speed_limit'] = Variable<int>(speedLimit);
    }
    if (!nullToAbsent || deviceLimit != null) {
      map['device_limit'] = Variable<int>(deviceLimit);
    }
    map['is_visible'] = Variable<bool>(isVisible);
    map['renewable'] = Variable<bool>(renewable);
    if (!nullToAbsent || sort != null) {
      map['sort'] = Variable<int>(sort);
    }
    if (!nullToAbsent || onetimePrice != null) {
      map['onetime_price'] = Variable<double>(onetimePrice);
    }
    if (!nullToAbsent || monthlyPrice != null) {
      map['monthly_price'] = Variable<double>(monthlyPrice);
    }
    if (!nullToAbsent || quarterlyPrice != null) {
      map['quarterly_price'] = Variable<double>(quarterlyPrice);
    }
    if (!nullToAbsent || halfYearlyPrice != null) {
      map['half_yearly_price'] = Variable<double>(halfYearlyPrice);
    }
    if (!nullToAbsent || yearlyPrice != null) {
      map['yearly_price'] = Variable<double>(yearlyPrice);
    }
    if (!nullToAbsent || twoYearPrice != null) {
      map['two_year_price'] = Variable<double>(twoYearPrice);
    }
    if (!nullToAbsent || threeYearPrice != null) {
      map['three_year_price'] = Variable<double>(threeYearPrice);
    }
    if (!nullToAbsent || resetPrice != null) {
      map['reset_price'] = Variable<double>(resetPrice);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['metadata'] = Variable<String>(metadata);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  XBoardPlansCompanion toCompanion(bool nullToAbsent) {
    return XBoardPlansCompanion(
      id: Value(id),
      name: Value(name),
      groupId: Value(groupId),
      transferQuota: Value(transferQuota),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      tags: Value(tags),
      speedLimit: speedLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(speedLimit),
      deviceLimit: deviceLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceLimit),
      isVisible: Value(isVisible),
      renewable: Value(renewable),
      sort: sort == null && nullToAbsent ? const Value.absent() : Value(sort),
      onetimePrice: onetimePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(onetimePrice),
      monthlyPrice: monthlyPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyPrice),
      quarterlyPrice: quarterlyPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(quarterlyPrice),
      halfYearlyPrice: halfYearlyPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(halfYearlyPrice),
      yearlyPrice: yearlyPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(yearlyPrice),
      twoYearPrice: twoYearPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(twoYearPrice),
      threeYearPrice: threeYearPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(threeYearPrice),
      resetPrice: resetPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(resetPrice),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      metadata: Value(metadata),
      cachedAt: Value(cachedAt),
    );
  }

  factory XBoardPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardPlanRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupId: serializer.fromJson<int>(json['groupId']),
      transferQuota: serializer.fromJson<int>(json['transferQuota']),
      description: serializer.fromJson<String?>(json['description']),
      tags: serializer.fromJson<String>(json['tags']),
      speedLimit: serializer.fromJson<int?>(json['speedLimit']),
      deviceLimit: serializer.fromJson<int?>(json['deviceLimit']),
      isVisible: serializer.fromJson<bool>(json['isVisible']),
      renewable: serializer.fromJson<bool>(json['renewable']),
      sort: serializer.fromJson<int?>(json['sort']),
      onetimePrice: serializer.fromJson<double?>(json['onetimePrice']),
      monthlyPrice: serializer.fromJson<double?>(json['monthlyPrice']),
      quarterlyPrice: serializer.fromJson<double?>(json['quarterlyPrice']),
      halfYearlyPrice: serializer.fromJson<double?>(json['halfYearlyPrice']),
      yearlyPrice: serializer.fromJson<double?>(json['yearlyPrice']),
      twoYearPrice: serializer.fromJson<double?>(json['twoYearPrice']),
      threeYearPrice: serializer.fromJson<double?>(json['threeYearPrice']),
      resetPrice: serializer.fromJson<double?>(json['resetPrice']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'groupId': serializer.toJson<int>(groupId),
      'transferQuota': serializer.toJson<int>(transferQuota),
      'description': serializer.toJson<String?>(description),
      'tags': serializer.toJson<String>(tags),
      'speedLimit': serializer.toJson<int?>(speedLimit),
      'deviceLimit': serializer.toJson<int?>(deviceLimit),
      'isVisible': serializer.toJson<bool>(isVisible),
      'renewable': serializer.toJson<bool>(renewable),
      'sort': serializer.toJson<int?>(sort),
      'onetimePrice': serializer.toJson<double?>(onetimePrice),
      'monthlyPrice': serializer.toJson<double?>(monthlyPrice),
      'quarterlyPrice': serializer.toJson<double?>(quarterlyPrice),
      'halfYearlyPrice': serializer.toJson<double?>(halfYearlyPrice),
      'yearlyPrice': serializer.toJson<double?>(yearlyPrice),
      'twoYearPrice': serializer.toJson<double?>(twoYearPrice),
      'threeYearPrice': serializer.toJson<double?>(threeYearPrice),
      'resetPrice': serializer.toJson<double?>(resetPrice),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'metadata': serializer.toJson<String>(metadata),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  XBoardPlanRow copyWith({
    int? id,
    String? name,
    int? groupId,
    int? transferQuota,
    Value<String?> description = const Value.absent(),
    String? tags,
    Value<int?> speedLimit = const Value.absent(),
    Value<int?> deviceLimit = const Value.absent(),
    bool? isVisible,
    bool? renewable,
    Value<int?> sort = const Value.absent(),
    Value<double?> onetimePrice = const Value.absent(),
    Value<double?> monthlyPrice = const Value.absent(),
    Value<double?> quarterlyPrice = const Value.absent(),
    Value<double?> halfYearlyPrice = const Value.absent(),
    Value<double?> yearlyPrice = const Value.absent(),
    Value<double?> twoYearPrice = const Value.absent(),
    Value<double?> threeYearPrice = const Value.absent(),
    Value<double?> resetPrice = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    String? metadata,
    DateTime? cachedAt,
  }) => XBoardPlanRow(
    id: id ?? this.id,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    transferQuota: transferQuota ?? this.transferQuota,
    description: description.present ? description.value : this.description,
    tags: tags ?? this.tags,
    speedLimit: speedLimit.present ? speedLimit.value : this.speedLimit,
    deviceLimit: deviceLimit.present ? deviceLimit.value : this.deviceLimit,
    isVisible: isVisible ?? this.isVisible,
    renewable: renewable ?? this.renewable,
    sort: sort.present ? sort.value : this.sort,
    onetimePrice: onetimePrice.present ? onetimePrice.value : this.onetimePrice,
    monthlyPrice: monthlyPrice.present ? monthlyPrice.value : this.monthlyPrice,
    quarterlyPrice: quarterlyPrice.present
        ? quarterlyPrice.value
        : this.quarterlyPrice,
    halfYearlyPrice: halfYearlyPrice.present
        ? halfYearlyPrice.value
        : this.halfYearlyPrice,
    yearlyPrice: yearlyPrice.present ? yearlyPrice.value : this.yearlyPrice,
    twoYearPrice: twoYearPrice.present ? twoYearPrice.value : this.twoYearPrice,
    threeYearPrice: threeYearPrice.present
        ? threeYearPrice.value
        : this.threeYearPrice,
    resetPrice: resetPrice.present ? resetPrice.value : this.resetPrice,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    metadata: metadata ?? this.metadata,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  XBoardPlanRow copyWithCompanion(XBoardPlansCompanion data) {
    return XBoardPlanRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      transferQuota: data.transferQuota.present
          ? data.transferQuota.value
          : this.transferQuota,
      description: data.description.present
          ? data.description.value
          : this.description,
      tags: data.tags.present ? data.tags.value : this.tags,
      speedLimit: data.speedLimit.present
          ? data.speedLimit.value
          : this.speedLimit,
      deviceLimit: data.deviceLimit.present
          ? data.deviceLimit.value
          : this.deviceLimit,
      isVisible: data.isVisible.present ? data.isVisible.value : this.isVisible,
      renewable: data.renewable.present ? data.renewable.value : this.renewable,
      sort: data.sort.present ? data.sort.value : this.sort,
      onetimePrice: data.onetimePrice.present
          ? data.onetimePrice.value
          : this.onetimePrice,
      monthlyPrice: data.monthlyPrice.present
          ? data.monthlyPrice.value
          : this.monthlyPrice,
      quarterlyPrice: data.quarterlyPrice.present
          ? data.quarterlyPrice.value
          : this.quarterlyPrice,
      halfYearlyPrice: data.halfYearlyPrice.present
          ? data.halfYearlyPrice.value
          : this.halfYearlyPrice,
      yearlyPrice: data.yearlyPrice.present
          ? data.yearlyPrice.value
          : this.yearlyPrice,
      twoYearPrice: data.twoYearPrice.present
          ? data.twoYearPrice.value
          : this.twoYearPrice,
      threeYearPrice: data.threeYearPrice.present
          ? data.threeYearPrice.value
          : this.threeYearPrice,
      resetPrice: data.resetPrice.present
          ? data.resetPrice.value
          : this.resetPrice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardPlanRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('transferQuota: $transferQuota, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('speedLimit: $speedLimit, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('isVisible: $isVisible, ')
          ..write('renewable: $renewable, ')
          ..write('sort: $sort, ')
          ..write('onetimePrice: $onetimePrice, ')
          ..write('monthlyPrice: $monthlyPrice, ')
          ..write('quarterlyPrice: $quarterlyPrice, ')
          ..write('halfYearlyPrice: $halfYearlyPrice, ')
          ..write('yearlyPrice: $yearlyPrice, ')
          ..write('twoYearPrice: $twoYearPrice, ')
          ..write('threeYearPrice: $threeYearPrice, ')
          ..write('resetPrice: $resetPrice, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    groupId,
    transferQuota,
    description,
    tags,
    speedLimit,
    deviceLimit,
    isVisible,
    renewable,
    sort,
    onetimePrice,
    monthlyPrice,
    quarterlyPrice,
    halfYearlyPrice,
    yearlyPrice,
    twoYearPrice,
    threeYearPrice,
    resetPrice,
    createdAt,
    updatedAt,
    metadata,
    cachedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardPlanRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupId == this.groupId &&
          other.transferQuota == this.transferQuota &&
          other.description == this.description &&
          other.tags == this.tags &&
          other.speedLimit == this.speedLimit &&
          other.deviceLimit == this.deviceLimit &&
          other.isVisible == this.isVisible &&
          other.renewable == this.renewable &&
          other.sort == this.sort &&
          other.onetimePrice == this.onetimePrice &&
          other.monthlyPrice == this.monthlyPrice &&
          other.quarterlyPrice == this.quarterlyPrice &&
          other.halfYearlyPrice == this.halfYearlyPrice &&
          other.yearlyPrice == this.yearlyPrice &&
          other.twoYearPrice == this.twoYearPrice &&
          other.threeYearPrice == this.threeYearPrice &&
          other.resetPrice == this.resetPrice &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.metadata == this.metadata &&
          other.cachedAt == this.cachedAt);
}

class XBoardPlansCompanion extends UpdateCompanion<XBoardPlanRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> groupId;
  final Value<int> transferQuota;
  final Value<String?> description;
  final Value<String> tags;
  final Value<int?> speedLimit;
  final Value<int?> deviceLimit;
  final Value<bool> isVisible;
  final Value<bool> renewable;
  final Value<int?> sort;
  final Value<double?> onetimePrice;
  final Value<double?> monthlyPrice;
  final Value<double?> quarterlyPrice;
  final Value<double?> halfYearlyPrice;
  final Value<double?> yearlyPrice;
  final Value<double?> twoYearPrice;
  final Value<double?> threeYearPrice;
  final Value<double?> resetPrice;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String> metadata;
  final Value<DateTime> cachedAt;
  const XBoardPlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupId = const Value.absent(),
    this.transferQuota = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.speedLimit = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.renewable = const Value.absent(),
    this.sort = const Value.absent(),
    this.onetimePrice = const Value.absent(),
    this.monthlyPrice = const Value.absent(),
    this.quarterlyPrice = const Value.absent(),
    this.halfYearlyPrice = const Value.absent(),
    this.yearlyPrice = const Value.absent(),
    this.twoYearPrice = const Value.absent(),
    this.threeYearPrice = const Value.absent(),
    this.resetPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  XBoardPlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int groupId,
    required int transferQuota,
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.speedLimit = const Value.absent(),
    this.deviceLimit = const Value.absent(),
    this.isVisible = const Value.absent(),
    this.renewable = const Value.absent(),
    this.sort = const Value.absent(),
    this.onetimePrice = const Value.absent(),
    this.monthlyPrice = const Value.absent(),
    this.quarterlyPrice = const Value.absent(),
    this.halfYearlyPrice = const Value.absent(),
    this.yearlyPrice = const Value.absent(),
    this.twoYearPrice = const Value.absent(),
    this.threeYearPrice = const Value.absent(),
    this.resetPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    required DateTime cachedAt,
  }) : name = Value(name),
       groupId = Value(groupId),
       transferQuota = Value(transferQuota),
       cachedAt = Value(cachedAt);
  static Insertable<XBoardPlanRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? groupId,
    Expression<int>? transferQuota,
    Expression<String>? description,
    Expression<String>? tags,
    Expression<int>? speedLimit,
    Expression<int>? deviceLimit,
    Expression<bool>? isVisible,
    Expression<bool>? renewable,
    Expression<int>? sort,
    Expression<double>? onetimePrice,
    Expression<double>? monthlyPrice,
    Expression<double>? quarterlyPrice,
    Expression<double>? halfYearlyPrice,
    Expression<double>? yearlyPrice,
    Expression<double>? twoYearPrice,
    Expression<double>? threeYearPrice,
    Expression<double>? resetPrice,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? metadata,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupId != null) 'group_id': groupId,
      if (transferQuota != null) 'transfer_quota': transferQuota,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
      if (speedLimit != null) 'speed_limit': speedLimit,
      if (deviceLimit != null) 'device_limit': deviceLimit,
      if (isVisible != null) 'is_visible': isVisible,
      if (renewable != null) 'renewable': renewable,
      if (sort != null) 'sort': sort,
      if (onetimePrice != null) 'onetime_price': onetimePrice,
      if (monthlyPrice != null) 'monthly_price': monthlyPrice,
      if (quarterlyPrice != null) 'quarterly_price': quarterlyPrice,
      if (halfYearlyPrice != null) 'half_yearly_price': halfYearlyPrice,
      if (yearlyPrice != null) 'yearly_price': yearlyPrice,
      if (twoYearPrice != null) 'two_year_price': twoYearPrice,
      if (threeYearPrice != null) 'three_year_price': threeYearPrice,
      if (resetPrice != null) 'reset_price': resetPrice,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (metadata != null) 'metadata': metadata,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  XBoardPlansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? groupId,
    Value<int>? transferQuota,
    Value<String?>? description,
    Value<String>? tags,
    Value<int?>? speedLimit,
    Value<int?>? deviceLimit,
    Value<bool>? isVisible,
    Value<bool>? renewable,
    Value<int?>? sort,
    Value<double?>? onetimePrice,
    Value<double?>? monthlyPrice,
    Value<double?>? quarterlyPrice,
    Value<double?>? halfYearlyPrice,
    Value<double?>? yearlyPrice,
    Value<double?>? twoYearPrice,
    Value<double?>? threeYearPrice,
    Value<double?>? resetPrice,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<String>? metadata,
    Value<DateTime>? cachedAt,
  }) {
    return XBoardPlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      transferQuota: transferQuota ?? this.transferQuota,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      speedLimit: speedLimit ?? this.speedLimit,
      deviceLimit: deviceLimit ?? this.deviceLimit,
      isVisible: isVisible ?? this.isVisible,
      renewable: renewable ?? this.renewable,
      sort: sort ?? this.sort,
      onetimePrice: onetimePrice ?? this.onetimePrice,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      quarterlyPrice: quarterlyPrice ?? this.quarterlyPrice,
      halfYearlyPrice: halfYearlyPrice ?? this.halfYearlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      twoYearPrice: twoYearPrice ?? this.twoYearPrice,
      threeYearPrice: threeYearPrice ?? this.threeYearPrice,
      resetPrice: resetPrice ?? this.resetPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (transferQuota.present) {
      map['transfer_quota'] = Variable<int>(transferQuota.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (speedLimit.present) {
      map['speed_limit'] = Variable<int>(speedLimit.value);
    }
    if (deviceLimit.present) {
      map['device_limit'] = Variable<int>(deviceLimit.value);
    }
    if (isVisible.present) {
      map['is_visible'] = Variable<bool>(isVisible.value);
    }
    if (renewable.present) {
      map['renewable'] = Variable<bool>(renewable.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (onetimePrice.present) {
      map['onetime_price'] = Variable<double>(onetimePrice.value);
    }
    if (monthlyPrice.present) {
      map['monthly_price'] = Variable<double>(monthlyPrice.value);
    }
    if (quarterlyPrice.present) {
      map['quarterly_price'] = Variable<double>(quarterlyPrice.value);
    }
    if (halfYearlyPrice.present) {
      map['half_yearly_price'] = Variable<double>(halfYearlyPrice.value);
    }
    if (yearlyPrice.present) {
      map['yearly_price'] = Variable<double>(yearlyPrice.value);
    }
    if (twoYearPrice.present) {
      map['two_year_price'] = Variable<double>(twoYearPrice.value);
    }
    if (threeYearPrice.present) {
      map['three_year_price'] = Variable<double>(threeYearPrice.value);
    }
    if (resetPrice.present) {
      map['reset_price'] = Variable<double>(resetPrice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardPlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupId: $groupId, ')
          ..write('transferQuota: $transferQuota, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('speedLimit: $speedLimit, ')
          ..write('deviceLimit: $deviceLimit, ')
          ..write('isVisible: $isVisible, ')
          ..write('renewable: $renewable, ')
          ..write('sort: $sort, ')
          ..write('onetimePrice: $onetimePrice, ')
          ..write('monthlyPrice: $monthlyPrice, ')
          ..write('quarterlyPrice: $quarterlyPrice, ')
          ..write('halfYearlyPrice: $halfYearlyPrice, ')
          ..write('yearlyPrice: $yearlyPrice, ')
          ..write('twoYearPrice: $twoYearPrice, ')
          ..write('threeYearPrice: $threeYearPrice, ')
          ..write('resetPrice: $resetPrice, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('metadata: $metadata, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardOrdersTable extends XBoardOrders
    with TableInfo<$XBoardOrdersTable, XBoardOrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tradeNoMeta = const VerificationMeta(
    'tradeNo',
  );
  @override
  late final GeneratedColumn<String> tradeNo = GeneratedColumn<String>(
    'trade_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta(
    'statusCode',
  );
  @override
  late final GeneratedColumn<int> statusCode = GeneratedColumn<int>(
    'status_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planNameMeta = const VerificationMeta(
    'planName',
  );
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
    'plan_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planContentMeta = const VerificationMeta(
    'planContent',
  );
  @override
  late final GeneratedColumn<String> planContent = GeneratedColumn<String>(
    'plan_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handlingAmountMeta = const VerificationMeta(
    'handlingAmount',
  );
  @override
  late final GeneratedColumn<double> handlingAmount = GeneratedColumn<double>(
    'handling_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _balanceAmountMeta = const VerificationMeta(
    'balanceAmount',
  );
  @override
  late final GeneratedColumn<double> balanceAmount = GeneratedColumn<double>(
    'balance_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refundAmountMeta = const VerificationMeta(
    'refundAmount',
  );
  @override
  late final GeneratedColumn<double> refundAmount = GeneratedColumn<double>(
    'refund_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _surplusAmountMeta = const VerificationMeta(
    'surplusAmount',
  );
  @override
  late final GeneratedColumn<double> surplusAmount = GeneratedColumn<double>(
    'surplus_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'payment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentNameMeta = const VerificationMeta(
    'paymentName',
  );
  @override
  late final GeneratedColumn<String> paymentName = GeneratedColumn<String>(
    'payment_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _couponIdMeta = const VerificationMeta(
    'couponId',
  );
  @override
  late final GeneratedColumn<int> couponId = GeneratedColumn<int>(
    'coupon_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionStatusCodeMeta =
      const VerificationMeta('commissionStatusCode');
  @override
  late final GeneratedColumn<int> commissionStatusCode = GeneratedColumn<int>(
    'commission_status_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commissionBalanceMeta = const VerificationMeta(
    'commissionBalance',
  );
  @override
  late final GeneratedColumn<double> commissionBalance =
      GeneratedColumn<double>(
        'commission_balance',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tradeNo,
    email,
    planId,
    period,
    totalAmount,
    statusCode,
    planName,
    planContent,
    createdAt,
    paidAt,
    handlingAmount,
    balanceAmount,
    refundAmount,
    discountAmount,
    surplusAmount,
    paymentId,
    paymentName,
    couponId,
    commissionStatusCode,
    commissionBalance,
    metadata,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardOrderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trade_no')) {
      context.handle(
        _tradeNoMeta,
        tradeNo.isAcceptableOrUnknown(data['trade_no']!, _tradeNoMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeNoMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_statusCodeMeta);
    }
    if (data.containsKey('plan_name')) {
      context.handle(
        _planNameMeta,
        planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta),
      );
    }
    if (data.containsKey('plan_content')) {
      context.handle(
        _planContentMeta,
        planContent.isAcceptableOrUnknown(
          data['plan_content']!,
          _planContentMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('handling_amount')) {
      context.handle(
        _handlingAmountMeta,
        handlingAmount.isAcceptableOrUnknown(
          data['handling_amount']!,
          _handlingAmountMeta,
        ),
      );
    }
    if (data.containsKey('balance_amount')) {
      context.handle(
        _balanceAmountMeta,
        balanceAmount.isAcceptableOrUnknown(
          data['balance_amount']!,
          _balanceAmountMeta,
        ),
      );
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
        _refundAmountMeta,
        refundAmount.isAcceptableOrUnknown(
          data['refund_amount']!,
          _refundAmountMeta,
        ),
      );
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('surplus_amount')) {
      context.handle(
        _surplusAmountMeta,
        surplusAmount.isAcceptableOrUnknown(
          data['surplus_amount']!,
          _surplusAmountMeta,
        ),
      );
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    }
    if (data.containsKey('payment_name')) {
      context.handle(
        _paymentNameMeta,
        paymentName.isAcceptableOrUnknown(
          data['payment_name']!,
          _paymentNameMeta,
        ),
      );
    }
    if (data.containsKey('coupon_id')) {
      context.handle(
        _couponIdMeta,
        couponId.isAcceptableOrUnknown(data['coupon_id']!, _couponIdMeta),
      );
    }
    if (data.containsKey('commission_status_code')) {
      context.handle(
        _commissionStatusCodeMeta,
        commissionStatusCode.isAcceptableOrUnknown(
          data['commission_status_code']!,
          _commissionStatusCodeMeta,
        ),
      );
    }
    if (data.containsKey('commission_balance')) {
      context.handle(
        _commissionBalanceMeta,
        commissionBalance.isAcceptableOrUnknown(
          data['commission_balance']!,
          _commissionBalanceMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardOrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardOrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tradeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_no'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_code'],
      )!,
      planName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name'],
      ),
      planContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_content'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      handlingAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}handling_amount'],
      )!,
      balanceAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_amount'],
      )!,
      refundAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}refund_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      surplusAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}surplus_amount'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_id'],
      ),
      paymentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_name'],
      ),
      couponId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coupon_id'],
      ),
      commissionStatusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commission_status_code'],
      ),
      commissionBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}commission_balance'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $XBoardOrdersTable createAlias(String alias) {
    return $XBoardOrdersTable(attachedDatabase, alias);
  }
}

class XBoardOrderRow extends DataClass implements Insertable<XBoardOrderRow> {
  final int id;
  final String tradeNo;
  final String email;
  final int planId;
  final String period;
  final double totalAmount;
  final int statusCode;
  final String? planName;
  final String? planContent;
  final DateTime createdAt;
  final DateTime? paidAt;
  final double handlingAmount;
  final double balanceAmount;
  final double refundAmount;
  final double discountAmount;
  final double surplusAmount;
  final int? paymentId;
  final String? paymentName;
  final int? couponId;
  final int? commissionStatusCode;
  final double commissionBalance;
  final String metadata;
  final DateTime? lastSyncedAt;
  const XBoardOrderRow({
    required this.id,
    required this.tradeNo,
    required this.email,
    required this.planId,
    required this.period,
    required this.totalAmount,
    required this.statusCode,
    this.planName,
    this.planContent,
    required this.createdAt,
    this.paidAt,
    required this.handlingAmount,
    required this.balanceAmount,
    required this.refundAmount,
    required this.discountAmount,
    required this.surplusAmount,
    this.paymentId,
    this.paymentName,
    this.couponId,
    this.commissionStatusCode,
    required this.commissionBalance,
    required this.metadata,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trade_no'] = Variable<String>(tradeNo);
    map['email'] = Variable<String>(email);
    map['plan_id'] = Variable<int>(planId);
    map['period'] = Variable<String>(period);
    map['total_amount'] = Variable<double>(totalAmount);
    map['status_code'] = Variable<int>(statusCode);
    if (!nullToAbsent || planName != null) {
      map['plan_name'] = Variable<String>(planName);
    }
    if (!nullToAbsent || planContent != null) {
      map['plan_content'] = Variable<String>(planContent);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    map['handling_amount'] = Variable<double>(handlingAmount);
    map['balance_amount'] = Variable<double>(balanceAmount);
    map['refund_amount'] = Variable<double>(refundAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['surplus_amount'] = Variable<double>(surplusAmount);
    if (!nullToAbsent || paymentId != null) {
      map['payment_id'] = Variable<int>(paymentId);
    }
    if (!nullToAbsent || paymentName != null) {
      map['payment_name'] = Variable<String>(paymentName);
    }
    if (!nullToAbsent || couponId != null) {
      map['coupon_id'] = Variable<int>(couponId);
    }
    if (!nullToAbsent || commissionStatusCode != null) {
      map['commission_status_code'] = Variable<int>(commissionStatusCode);
    }
    map['commission_balance'] = Variable<double>(commissionBalance);
    map['metadata'] = Variable<String>(metadata);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  XBoardOrdersCompanion toCompanion(bool nullToAbsent) {
    return XBoardOrdersCompanion(
      id: Value(id),
      tradeNo: Value(tradeNo),
      email: Value(email),
      planId: Value(planId),
      period: Value(period),
      totalAmount: Value(totalAmount),
      statusCode: Value(statusCode),
      planName: planName == null && nullToAbsent
          ? const Value.absent()
          : Value(planName),
      planContent: planContent == null && nullToAbsent
          ? const Value.absent()
          : Value(planContent),
      createdAt: Value(createdAt),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      handlingAmount: Value(handlingAmount),
      balanceAmount: Value(balanceAmount),
      refundAmount: Value(refundAmount),
      discountAmount: Value(discountAmount),
      surplusAmount: Value(surplusAmount),
      paymentId: paymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentId),
      paymentName: paymentName == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentName),
      couponId: couponId == null && nullToAbsent
          ? const Value.absent()
          : Value(couponId),
      commissionStatusCode: commissionStatusCode == null && nullToAbsent
          ? const Value.absent()
          : Value(commissionStatusCode),
      commissionBalance: Value(commissionBalance),
      metadata: Value(metadata),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory XBoardOrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardOrderRow(
      id: serializer.fromJson<int>(json['id']),
      tradeNo: serializer.fromJson<String>(json['tradeNo']),
      email: serializer.fromJson<String>(json['email']),
      planId: serializer.fromJson<int>(json['planId']),
      period: serializer.fromJson<String>(json['period']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      statusCode: serializer.fromJson<int>(json['statusCode']),
      planName: serializer.fromJson<String?>(json['planName']),
      planContent: serializer.fromJson<String?>(json['planContent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      handlingAmount: serializer.fromJson<double>(json['handlingAmount']),
      balanceAmount: serializer.fromJson<double>(json['balanceAmount']),
      refundAmount: serializer.fromJson<double>(json['refundAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      surplusAmount: serializer.fromJson<double>(json['surplusAmount']),
      paymentId: serializer.fromJson<int?>(json['paymentId']),
      paymentName: serializer.fromJson<String?>(json['paymentName']),
      couponId: serializer.fromJson<int?>(json['couponId']),
      commissionStatusCode: serializer.fromJson<int?>(
        json['commissionStatusCode'],
      ),
      commissionBalance: serializer.fromJson<double>(json['commissionBalance']),
      metadata: serializer.fromJson<String>(json['metadata']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tradeNo': serializer.toJson<String>(tradeNo),
      'email': serializer.toJson<String>(email),
      'planId': serializer.toJson<int>(planId),
      'period': serializer.toJson<String>(period),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'statusCode': serializer.toJson<int>(statusCode),
      'planName': serializer.toJson<String?>(planName),
      'planContent': serializer.toJson<String?>(planContent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'handlingAmount': serializer.toJson<double>(handlingAmount),
      'balanceAmount': serializer.toJson<double>(balanceAmount),
      'refundAmount': serializer.toJson<double>(refundAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'surplusAmount': serializer.toJson<double>(surplusAmount),
      'paymentId': serializer.toJson<int?>(paymentId),
      'paymentName': serializer.toJson<String?>(paymentName),
      'couponId': serializer.toJson<int?>(couponId),
      'commissionStatusCode': serializer.toJson<int?>(commissionStatusCode),
      'commissionBalance': serializer.toJson<double>(commissionBalance),
      'metadata': serializer.toJson<String>(metadata),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  XBoardOrderRow copyWith({
    int? id,
    String? tradeNo,
    String? email,
    int? planId,
    String? period,
    double? totalAmount,
    int? statusCode,
    Value<String?> planName = const Value.absent(),
    Value<String?> planContent = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> paidAt = const Value.absent(),
    double? handlingAmount,
    double? balanceAmount,
    double? refundAmount,
    double? discountAmount,
    double? surplusAmount,
    Value<int?> paymentId = const Value.absent(),
    Value<String?> paymentName = const Value.absent(),
    Value<int?> couponId = const Value.absent(),
    Value<int?> commissionStatusCode = const Value.absent(),
    double? commissionBalance,
    String? metadata,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => XBoardOrderRow(
    id: id ?? this.id,
    tradeNo: tradeNo ?? this.tradeNo,
    email: email ?? this.email,
    planId: planId ?? this.planId,
    period: period ?? this.period,
    totalAmount: totalAmount ?? this.totalAmount,
    statusCode: statusCode ?? this.statusCode,
    planName: planName.present ? planName.value : this.planName,
    planContent: planContent.present ? planContent.value : this.planContent,
    createdAt: createdAt ?? this.createdAt,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    handlingAmount: handlingAmount ?? this.handlingAmount,
    balanceAmount: balanceAmount ?? this.balanceAmount,
    refundAmount: refundAmount ?? this.refundAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    surplusAmount: surplusAmount ?? this.surplusAmount,
    paymentId: paymentId.present ? paymentId.value : this.paymentId,
    paymentName: paymentName.present ? paymentName.value : this.paymentName,
    couponId: couponId.present ? couponId.value : this.couponId,
    commissionStatusCode: commissionStatusCode.present
        ? commissionStatusCode.value
        : this.commissionStatusCode,
    commissionBalance: commissionBalance ?? this.commissionBalance,
    metadata: metadata ?? this.metadata,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  XBoardOrderRow copyWithCompanion(XBoardOrdersCompanion data) {
    return XBoardOrderRow(
      id: data.id.present ? data.id.value : this.id,
      tradeNo: data.tradeNo.present ? data.tradeNo.value : this.tradeNo,
      email: data.email.present ? data.email.value : this.email,
      planId: data.planId.present ? data.planId.value : this.planId,
      period: data.period.present ? data.period.value : this.period,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      statusCode: data.statusCode.present
          ? data.statusCode.value
          : this.statusCode,
      planName: data.planName.present ? data.planName.value : this.planName,
      planContent: data.planContent.present
          ? data.planContent.value
          : this.planContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      handlingAmount: data.handlingAmount.present
          ? data.handlingAmount.value
          : this.handlingAmount,
      balanceAmount: data.balanceAmount.present
          ? data.balanceAmount.value
          : this.balanceAmount,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      surplusAmount: data.surplusAmount.present
          ? data.surplusAmount.value
          : this.surplusAmount,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      paymentName: data.paymentName.present
          ? data.paymentName.value
          : this.paymentName,
      couponId: data.couponId.present ? data.couponId.value : this.couponId,
      commissionStatusCode: data.commissionStatusCode.present
          ? data.commissionStatusCode.value
          : this.commissionStatusCode,
      commissionBalance: data.commissionBalance.present
          ? data.commissionBalance.value
          : this.commissionBalance,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardOrderRow(')
          ..write('id: $id, ')
          ..write('tradeNo: $tradeNo, ')
          ..write('email: $email, ')
          ..write('planId: $planId, ')
          ..write('period: $period, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('statusCode: $statusCode, ')
          ..write('planName: $planName, ')
          ..write('planContent: $planContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('handlingAmount: $handlingAmount, ')
          ..write('balanceAmount: $balanceAmount, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('surplusAmount: $surplusAmount, ')
          ..write('paymentId: $paymentId, ')
          ..write('paymentName: $paymentName, ')
          ..write('couponId: $couponId, ')
          ..write('commissionStatusCode: $commissionStatusCode, ')
          ..write('commissionBalance: $commissionBalance, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tradeNo,
    email,
    planId,
    period,
    totalAmount,
    statusCode,
    planName,
    planContent,
    createdAt,
    paidAt,
    handlingAmount,
    balanceAmount,
    refundAmount,
    discountAmount,
    surplusAmount,
    paymentId,
    paymentName,
    couponId,
    commissionStatusCode,
    commissionBalance,
    metadata,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardOrderRow &&
          other.id == this.id &&
          other.tradeNo == this.tradeNo &&
          other.email == this.email &&
          other.planId == this.planId &&
          other.period == this.period &&
          other.totalAmount == this.totalAmount &&
          other.statusCode == this.statusCode &&
          other.planName == this.planName &&
          other.planContent == this.planContent &&
          other.createdAt == this.createdAt &&
          other.paidAt == this.paidAt &&
          other.handlingAmount == this.handlingAmount &&
          other.balanceAmount == this.balanceAmount &&
          other.refundAmount == this.refundAmount &&
          other.discountAmount == this.discountAmount &&
          other.surplusAmount == this.surplusAmount &&
          other.paymentId == this.paymentId &&
          other.paymentName == this.paymentName &&
          other.couponId == this.couponId &&
          other.commissionStatusCode == this.commissionStatusCode &&
          other.commissionBalance == this.commissionBalance &&
          other.metadata == this.metadata &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class XBoardOrdersCompanion extends UpdateCompanion<XBoardOrderRow> {
  final Value<int> id;
  final Value<String> tradeNo;
  final Value<String> email;
  final Value<int> planId;
  final Value<String> period;
  final Value<double> totalAmount;
  final Value<int> statusCode;
  final Value<String?> planName;
  final Value<String?> planContent;
  final Value<DateTime> createdAt;
  final Value<DateTime?> paidAt;
  final Value<double> handlingAmount;
  final Value<double> balanceAmount;
  final Value<double> refundAmount;
  final Value<double> discountAmount;
  final Value<double> surplusAmount;
  final Value<int?> paymentId;
  final Value<String?> paymentName;
  final Value<int?> couponId;
  final Value<int?> commissionStatusCode;
  final Value<double> commissionBalance;
  final Value<String> metadata;
  final Value<DateTime?> lastSyncedAt;
  const XBoardOrdersCompanion({
    this.id = const Value.absent(),
    this.tradeNo = const Value.absent(),
    this.email = const Value.absent(),
    this.planId = const Value.absent(),
    this.period = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.planName = const Value.absent(),
    this.planContent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.handlingAmount = const Value.absent(),
    this.balanceAmount = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.surplusAmount = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.paymentName = const Value.absent(),
    this.couponId = const Value.absent(),
    this.commissionStatusCode = const Value.absent(),
    this.commissionBalance = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  XBoardOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String tradeNo,
    required String email,
    required int planId,
    required String period,
    required double totalAmount,
    required int statusCode,
    this.planName = const Value.absent(),
    this.planContent = const Value.absent(),
    required DateTime createdAt,
    this.paidAt = const Value.absent(),
    this.handlingAmount = const Value.absent(),
    this.balanceAmount = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.surplusAmount = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.paymentName = const Value.absent(),
    this.couponId = const Value.absent(),
    this.commissionStatusCode = const Value.absent(),
    this.commissionBalance = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : tradeNo = Value(tradeNo),
       email = Value(email),
       planId = Value(planId),
       period = Value(period),
       totalAmount = Value(totalAmount),
       statusCode = Value(statusCode),
       createdAt = Value(createdAt);
  static Insertable<XBoardOrderRow> custom({
    Expression<int>? id,
    Expression<String>? tradeNo,
    Expression<String>? email,
    Expression<int>? planId,
    Expression<String>? period,
    Expression<double>? totalAmount,
    Expression<int>? statusCode,
    Expression<String>? planName,
    Expression<String>? planContent,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? paidAt,
    Expression<double>? handlingAmount,
    Expression<double>? balanceAmount,
    Expression<double>? refundAmount,
    Expression<double>? discountAmount,
    Expression<double>? surplusAmount,
    Expression<int>? paymentId,
    Expression<String>? paymentName,
    Expression<int>? couponId,
    Expression<int>? commissionStatusCode,
    Expression<double>? commissionBalance,
    Expression<String>? metadata,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tradeNo != null) 'trade_no': tradeNo,
      if (email != null) 'email': email,
      if (planId != null) 'plan_id': planId,
      if (period != null) 'period': period,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (statusCode != null) 'status_code': statusCode,
      if (planName != null) 'plan_name': planName,
      if (planContent != null) 'plan_content': planContent,
      if (createdAt != null) 'created_at': createdAt,
      if (paidAt != null) 'paid_at': paidAt,
      if (handlingAmount != null) 'handling_amount': handlingAmount,
      if (balanceAmount != null) 'balance_amount': balanceAmount,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (surplusAmount != null) 'surplus_amount': surplusAmount,
      if (paymentId != null) 'payment_id': paymentId,
      if (paymentName != null) 'payment_name': paymentName,
      if (couponId != null) 'coupon_id': couponId,
      if (commissionStatusCode != null)
        'commission_status_code': commissionStatusCode,
      if (commissionBalance != null) 'commission_balance': commissionBalance,
      if (metadata != null) 'metadata': metadata,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  XBoardOrdersCompanion copyWith({
    Value<int>? id,
    Value<String>? tradeNo,
    Value<String>? email,
    Value<int>? planId,
    Value<String>? period,
    Value<double>? totalAmount,
    Value<int>? statusCode,
    Value<String?>? planName,
    Value<String?>? planContent,
    Value<DateTime>? createdAt,
    Value<DateTime?>? paidAt,
    Value<double>? handlingAmount,
    Value<double>? balanceAmount,
    Value<double>? refundAmount,
    Value<double>? discountAmount,
    Value<double>? surplusAmount,
    Value<int?>? paymentId,
    Value<String?>? paymentName,
    Value<int?>? couponId,
    Value<int?>? commissionStatusCode,
    Value<double>? commissionBalance,
    Value<String>? metadata,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return XBoardOrdersCompanion(
      id: id ?? this.id,
      tradeNo: tradeNo ?? this.tradeNo,
      email: email ?? this.email,
      planId: planId ?? this.planId,
      period: period ?? this.period,
      totalAmount: totalAmount ?? this.totalAmount,
      statusCode: statusCode ?? this.statusCode,
      planName: planName ?? this.planName,
      planContent: planContent ?? this.planContent,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      handlingAmount: handlingAmount ?? this.handlingAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      surplusAmount: surplusAmount ?? this.surplusAmount,
      paymentId: paymentId ?? this.paymentId,
      paymentName: paymentName ?? this.paymentName,
      couponId: couponId ?? this.couponId,
      commissionStatusCode: commissionStatusCode ?? this.commissionStatusCode,
      commissionBalance: commissionBalance ?? this.commissionBalance,
      metadata: metadata ?? this.metadata,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tradeNo.present) {
      map['trade_no'] = Variable<String>(tradeNo.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<int>(statusCode.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (planContent.present) {
      map['plan_content'] = Variable<String>(planContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (handlingAmount.present) {
      map['handling_amount'] = Variable<double>(handlingAmount.value);
    }
    if (balanceAmount.present) {
      map['balance_amount'] = Variable<double>(balanceAmount.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<double>(refundAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (surplusAmount.present) {
      map['surplus_amount'] = Variable<double>(surplusAmount.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<int>(paymentId.value);
    }
    if (paymentName.present) {
      map['payment_name'] = Variable<String>(paymentName.value);
    }
    if (couponId.present) {
      map['coupon_id'] = Variable<int>(couponId.value);
    }
    if (commissionStatusCode.present) {
      map['commission_status_code'] = Variable<int>(commissionStatusCode.value);
    }
    if (commissionBalance.present) {
      map['commission_balance'] = Variable<double>(commissionBalance.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardOrdersCompanion(')
          ..write('id: $id, ')
          ..write('tradeNo: $tradeNo, ')
          ..write('email: $email, ')
          ..write('planId: $planId, ')
          ..write('period: $period, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('statusCode: $statusCode, ')
          ..write('planName: $planName, ')
          ..write('planContent: $planContent, ')
          ..write('createdAt: $createdAt, ')
          ..write('paidAt: $paidAt, ')
          ..write('handlingAmount: $handlingAmount, ')
          ..write('balanceAmount: $balanceAmount, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('surplusAmount: $surplusAmount, ')
          ..write('paymentId: $paymentId, ')
          ..write('paymentName: $paymentName, ')
          ..write('couponId: $couponId, ')
          ..write('commissionStatusCode: $commissionStatusCode, ')
          ..write('commissionBalance: $commissionBalance, ')
          ..write('metadata: $metadata, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardNoticeReadsTable extends XBoardNoticeReads
    with TableInfo<$XBoardNoticeReadsTable, XBoardNoticeReadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardNoticeReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noticeIdMeta = const VerificationMeta(
    'noticeId',
  );
  @override
  late final GeneratedColumn<int> noticeId = GeneratedColumn<int>(
    'notice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, noticeId, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_notice_reads';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardNoticeReadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notice_id')) {
      context.handle(
        _noticeIdMeta,
        noticeId.isAcceptableOrUnknown(data['notice_id']!, _noticeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noticeIdMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {noticeId},
  ];
  @override
  XBoardNoticeReadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardNoticeReadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noticeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notice_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $XBoardNoticeReadsTable createAlias(String alias) {
    return $XBoardNoticeReadsTable(attachedDatabase, alias);
  }
}

class XBoardNoticeReadRow extends DataClass
    implements Insertable<XBoardNoticeReadRow> {
  final int id;
  final int noticeId;
  final DateTime readAt;
  const XBoardNoticeReadRow({
    required this.id,
    required this.noticeId,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notice_id'] = Variable<int>(noticeId);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  XBoardNoticeReadsCompanion toCompanion(bool nullToAbsent) {
    return XBoardNoticeReadsCompanion(
      id: Value(id),
      noticeId: Value(noticeId),
      readAt: Value(readAt),
    );
  }

  factory XBoardNoticeReadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardNoticeReadRow(
      id: serializer.fromJson<int>(json['id']),
      noticeId: serializer.fromJson<int>(json['noticeId']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noticeId': serializer.toJson<int>(noticeId),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  XBoardNoticeReadRow copyWith({int? id, int? noticeId, DateTime? readAt}) =>
      XBoardNoticeReadRow(
        id: id ?? this.id,
        noticeId: noticeId ?? this.noticeId,
        readAt: readAt ?? this.readAt,
      );
  XBoardNoticeReadRow copyWithCompanion(XBoardNoticeReadsCompanion data) {
    return XBoardNoticeReadRow(
      id: data.id.present ? data.id.value : this.id,
      noticeId: data.noticeId.present ? data.noticeId.value : this.noticeId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardNoticeReadRow(')
          ..write('id: $id, ')
          ..write('noticeId: $noticeId, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, noticeId, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardNoticeReadRow &&
          other.id == this.id &&
          other.noticeId == this.noticeId &&
          other.readAt == this.readAt);
}

class XBoardNoticeReadsCompanion extends UpdateCompanion<XBoardNoticeReadRow> {
  final Value<int> id;
  final Value<int> noticeId;
  final Value<DateTime> readAt;
  const XBoardNoticeReadsCompanion({
    this.id = const Value.absent(),
    this.noticeId = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  XBoardNoticeReadsCompanion.insert({
    this.id = const Value.absent(),
    required int noticeId,
    required DateTime readAt,
  }) : noticeId = Value(noticeId),
       readAt = Value(readAt);
  static Insertable<XBoardNoticeReadRow> custom({
    Expression<int>? id,
    Expression<int>? noticeId,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noticeId != null) 'notice_id': noticeId,
      if (readAt != null) 'read_at': readAt,
    });
  }

  XBoardNoticeReadsCompanion copyWith({
    Value<int>? id,
    Value<int>? noticeId,
    Value<DateTime>? readAt,
  }) {
    return XBoardNoticeReadsCompanion(
      id: id ?? this.id,
      noticeId: noticeId ?? this.noticeId,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noticeId.present) {
      map['notice_id'] = Variable<int>(noticeId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardNoticeReadsCompanion(')
          ..write('id: $id, ')
          ..write('noticeId: $noticeId, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardDomainsTable extends XBoardDomains
    with TableInfo<$XBoardDomainsTable, XBoardDomainRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardDomainsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    latencyMs,
    isActive,
    isAvailable,
    lastCheckedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_domains';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardDomainRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardDomainRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardDomainRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
    );
  }

  @override
  $XBoardDomainsTable createAlias(String alias) {
    return $XBoardDomainsTable(attachedDatabase, alias);
  }
}

class XBoardDomainRow extends DataClass implements Insertable<XBoardDomainRow> {
  final int id;
  final String url;
  final int? latencyMs;
  final bool isActive;
  final bool isAvailable;
  final DateTime? lastCheckedAt;
  const XBoardDomainRow({
    required this.id,
    required this.url,
    this.latencyMs,
    required this.isActive,
    required this.isAvailable,
    this.lastCheckedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_available'] = Variable<bool>(isAvailable);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    return map;
  }

  XBoardDomainsCompanion toCompanion(bool nullToAbsent) {
    return XBoardDomainsCompanion(
      id: Value(id),
      url: Value(url),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      isActive: Value(isActive),
      isAvailable: Value(isAvailable),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
    );
  }

  factory XBoardDomainRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardDomainRow(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'isActive': serializer.toJson<bool>(isActive),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
    };
  }

  XBoardDomainRow copyWith({
    int? id,
    String? url,
    Value<int?> latencyMs = const Value.absent(),
    bool? isActive,
    bool? isAvailable,
    Value<DateTime?> lastCheckedAt = const Value.absent(),
  }) => XBoardDomainRow(
    id: id ?? this.id,
    url: url ?? this.url,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    isActive: isActive ?? this.isActive,
    isAvailable: isAvailable ?? this.isAvailable,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
  );
  XBoardDomainRow copyWithCompanion(XBoardDomainsCompanion data) {
    return XBoardDomainRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardDomainRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('isActive: $isActive, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, url, latencyMs, isActive, isAvailable, lastCheckedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardDomainRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.latencyMs == this.latencyMs &&
          other.isActive == this.isActive &&
          other.isAvailable == this.isAvailable &&
          other.lastCheckedAt == this.lastCheckedAt);
}

class XBoardDomainsCompanion extends UpdateCompanion<XBoardDomainRow> {
  final Value<int> id;
  final Value<String> url;
  final Value<int?> latencyMs;
  final Value<bool> isActive;
  final Value<bool> isAvailable;
  final Value<DateTime?> lastCheckedAt;
  const XBoardDomainsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
  });
  XBoardDomainsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.latencyMs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
  }) : url = Value(url);
  static Insertable<XBoardDomainRow> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<int>? latencyMs,
    Expression<bool>? isActive,
    Expression<bool>? isAvailable,
    Expression<DateTime>? lastCheckedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (isActive != null) 'is_active': isActive,
      if (isAvailable != null) 'is_available': isAvailable,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
    });
  }

  XBoardDomainsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<int?>? latencyMs,
    Value<bool>? isActive,
    Value<bool>? isAvailable,
    Value<DateTime?>? lastCheckedAt,
  }) {
    return XBoardDomainsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      latencyMs: latencyMs ?? this.latencyMs,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardDomainsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('isActive: $isActive, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('lastCheckedAt: $lastCheckedAt')
          ..write(')'))
        .toString();
  }
}

class $XBoardAuthTokensTable extends XBoardAuthTokens
    with TableInfo<$XBoardAuthTokensTable, XBoardAuthTokenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XBoardAuthTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    token,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xboard_auth_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<XBoardAuthTokenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XBoardAuthTokenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XBoardAuthTokenRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $XBoardAuthTokensTable createAlias(String alias) {
    return $XBoardAuthTokensTable(attachedDatabase, alias);
  }
}

class XBoardAuthTokenRow extends DataClass
    implements Insertable<XBoardAuthTokenRow> {
  final int id;
  final String email;
  final String token;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  const XBoardAuthTokenRow({
    required this.id,
    required this.email,
    required this.token,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['token'] = Variable<String>(token);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  XBoardAuthTokensCompanion toCompanion(bool nullToAbsent) {
    return XBoardAuthTokensCompanion(
      id: Value(id),
      email: Value(email),
      token: Value(token),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory XBoardAuthTokenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XBoardAuthTokenRow(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      token: serializer.fromJson<String>(json['token']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'token': serializer.toJson<String>(token),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  XBoardAuthTokenRow copyWith({
    int? id,
    String? email,
    String? token,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => XBoardAuthTokenRow(
    id: id ?? this.id,
    email: email ?? this.email,
    token: token ?? this.token,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  XBoardAuthTokenRow copyWithCompanion(XBoardAuthTokensCompanion data) {
    return XBoardAuthTokenRow(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      token: data.token.present ? data.token.value : this.token,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XBoardAuthTokenRow(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, token, createdAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XBoardAuthTokenRow &&
          other.id == this.id &&
          other.email == this.email &&
          other.token == this.token &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class XBoardAuthTokensCompanion extends UpdateCompanion<XBoardAuthTokenRow> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> token;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  const XBoardAuthTokensCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.token = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  XBoardAuthTokensCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String token,
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
  }) : email = Value(email),
       token = Value(token),
       createdAt = Value(createdAt);
  static Insertable<XBoardAuthTokenRow> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? token,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (token != null) 'token': token,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  XBoardAuthTokensCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? token,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
  }) {
    return XBoardAuthTokensCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XBoardAuthTokensCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$XBoardDatabase extends GeneratedDatabase {
  _$XBoardDatabase(QueryExecutor e) : super(e);
  $XBoardDatabaseManager get managers => $XBoardDatabaseManager(this);
  late final $XBoardUsersTable xBoardUsers = $XBoardUsersTable(this);
  late final $XBoardSubscriptionsTable xBoardSubscriptions =
      $XBoardSubscriptionsTable(this);
  late final $XBoardPlansTable xBoardPlans = $XBoardPlansTable(this);
  late final $XBoardOrdersTable xBoardOrders = $XBoardOrdersTable(this);
  late final $XBoardNoticeReadsTable xBoardNoticeReads =
      $XBoardNoticeReadsTable(this);
  late final $XBoardDomainsTable xBoardDomains = $XBoardDomainsTable(this);
  late final $XBoardAuthTokensTable xBoardAuthTokens = $XBoardAuthTokensTable(
    this,
  );
  late final XBoardUsersDao xBoardUsersDao = XBoardUsersDao(
    this as XBoardDatabase,
  );
  late final XBoardSubscriptionsDao xBoardSubscriptionsDao =
      XBoardSubscriptionsDao(this as XBoardDatabase);
  late final XBoardPlansDao xBoardPlansDao = XBoardPlansDao(
    this as XBoardDatabase,
  );
  late final XBoardOrdersDao xBoardOrdersDao = XBoardOrdersDao(
    this as XBoardDatabase,
  );
  late final XBoardNoticeReadsDao xBoardNoticeReadsDao = XBoardNoticeReadsDao(
    this as XBoardDatabase,
  );
  late final XBoardDomainsDao xBoardDomainsDao = XBoardDomainsDao(
    this as XBoardDatabase,
  );
  late final XBoardAuthTokensDao xBoardAuthTokensDao = XBoardAuthTokensDao(
    this as XBoardDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    xBoardUsers,
    xBoardSubscriptions,
    xBoardPlans,
    xBoardOrders,
    xBoardNoticeReads,
    xBoardDomains,
    xBoardAuthTokens,
  ];
}

typedef $$XBoardUsersTableCreateCompanionBuilder =
    XBoardUsersCompanion Function({
      Value<int> id,
      required String email,
      required String uuid,
      Value<String> avatarUrl,
      Value<int?> planId,
      Value<int> transferLimit,
      Value<int> uploadedBytes,
      Value<int> downloadedBytes,
      Value<int> balanceInCents,
      Value<int> commissionBalanceInCents,
      Value<DateTime?> expiredAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> createdAt,
      Value<bool> banned,
      Value<bool> remindExpire,
      Value<bool> remindTraffic,
      Value<double?> discount,
      Value<double?> commissionRate,
      Value<String?> telegramId,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$XBoardUsersTableUpdateCompanionBuilder =
    XBoardUsersCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> uuid,
      Value<String> avatarUrl,
      Value<int?> planId,
      Value<int> transferLimit,
      Value<int> uploadedBytes,
      Value<int> downloadedBytes,
      Value<int> balanceInCents,
      Value<int> commissionBalanceInCents,
      Value<DateTime?> expiredAt,
      Value<DateTime?> lastLoginAt,
      Value<DateTime?> createdAt,
      Value<bool> banned,
      Value<bool> remindExpire,
      Value<bool> remindTraffic,
      Value<double?> discount,
      Value<double?> commissionRate,
      Value<String?> telegramId,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });

class $$XBoardUsersTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardUsersTable> {
  $$XBoardUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissionBalanceInCents => $composableBuilder(
    column: $table.commissionBalanceInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get banned => $composableBuilder(
    column: $table.banned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindExpire => $composableBuilder(
    column: $table.remindExpire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindTraffic => $composableBuilder(
    column: $table.remindTraffic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telegramId => $composableBuilder(
    column: $table.telegramId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardUsersTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardUsersTable> {
  $$XBoardUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissionBalanceInCents => $composableBuilder(
    column: $table.commissionBalanceInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get banned => $composableBuilder(
    column: $table.banned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindExpire => $composableBuilder(
    column: $table.remindExpire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindTraffic => $composableBuilder(
    column: $table.remindTraffic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telegramId => $composableBuilder(
    column: $table.telegramId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardUsersTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardUsersTable> {
  $$XBoardUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceInCents => $composableBuilder(
    column: $table.balanceInCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get commissionBalanceInCents => $composableBuilder(
    column: $table.commissionBalanceInCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiredAt =>
      $composableBuilder(column: $table.expiredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get banned =>
      $composableBuilder(column: $table.banned, builder: (column) => column);

  GeneratedColumn<bool> get remindExpire => $composableBuilder(
    column: $table.remindExpire,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindTraffic => $composableBuilder(
    column: $table.remindTraffic,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get commissionRate => $composableBuilder(
    column: $table.commissionRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telegramId => $composableBuilder(
    column: $table.telegramId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$XBoardUsersTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardUsersTable,
          XBoardUserRow,
          $$XBoardUsersTableFilterComposer,
          $$XBoardUsersTableOrderingComposer,
          $$XBoardUsersTableAnnotationComposer,
          $$XBoardUsersTableCreateCompanionBuilder,
          $$XBoardUsersTableUpdateCompanionBuilder,
          (
            XBoardUserRow,
            BaseReferences<_$XBoardDatabase, $XBoardUsersTable, XBoardUserRow>,
          ),
          XBoardUserRow,
          PrefetchHooks Function()
        > {
  $$XBoardUsersTableTableManager(_$XBoardDatabase db, $XBoardUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> avatarUrl = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int> transferLimit = const Value.absent(),
                Value<int> uploadedBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> balanceInCents = const Value.absent(),
                Value<int> commissionBalanceInCents = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool> banned = const Value.absent(),
                Value<bool> remindExpire = const Value.absent(),
                Value<bool> remindTraffic = const Value.absent(),
                Value<double?> discount = const Value.absent(),
                Value<double?> commissionRate = const Value.absent(),
                Value<String?> telegramId = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardUsersCompanion(
                id: id,
                email: email,
                uuid: uuid,
                avatarUrl: avatarUrl,
                planId: planId,
                transferLimit: transferLimit,
                uploadedBytes: uploadedBytes,
                downloadedBytes: downloadedBytes,
                balanceInCents: balanceInCents,
                commissionBalanceInCents: commissionBalanceInCents,
                expiredAt: expiredAt,
                lastLoginAt: lastLoginAt,
                createdAt: createdAt,
                banned: banned,
                remindExpire: remindExpire,
                remindTraffic: remindTraffic,
                discount: discount,
                commissionRate: commissionRate,
                telegramId: telegramId,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String uuid,
                Value<String> avatarUrl = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int> transferLimit = const Value.absent(),
                Value<int> uploadedBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int> balanceInCents = const Value.absent(),
                Value<int> commissionBalanceInCents = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool> banned = const Value.absent(),
                Value<bool> remindExpire = const Value.absent(),
                Value<bool> remindTraffic = const Value.absent(),
                Value<double?> discount = const Value.absent(),
                Value<double?> commissionRate = const Value.absent(),
                Value<String?> telegramId = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardUsersCompanion.insert(
                id: id,
                email: email,
                uuid: uuid,
                avatarUrl: avatarUrl,
                planId: planId,
                transferLimit: transferLimit,
                uploadedBytes: uploadedBytes,
                downloadedBytes: downloadedBytes,
                balanceInCents: balanceInCents,
                commissionBalanceInCents: commissionBalanceInCents,
                expiredAt: expiredAt,
                lastLoginAt: lastLoginAt,
                createdAt: createdAt,
                banned: banned,
                remindExpire: remindExpire,
                remindTraffic: remindTraffic,
                discount: discount,
                commissionRate: commissionRate,
                telegramId: telegramId,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardUsersTable,
      XBoardUserRow,
      $$XBoardUsersTableFilterComposer,
      $$XBoardUsersTableOrderingComposer,
      $$XBoardUsersTableAnnotationComposer,
      $$XBoardUsersTableCreateCompanionBuilder,
      $$XBoardUsersTableUpdateCompanionBuilder,
      (
        XBoardUserRow,
        BaseReferences<_$XBoardDatabase, $XBoardUsersTable, XBoardUserRow>,
      ),
      XBoardUserRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardSubscriptionsTableCreateCompanionBuilder =
    XBoardSubscriptionsCompanion Function({
      Value<int> id,
      required String email,
      required String subscribeUrl,
      required String uuid,
      required int planId,
      Value<String?> planName,
      Value<String?> token,
      Value<int> transferLimit,
      Value<int> uploadedBytes,
      Value<int> downloadedBytes,
      Value<int?> speedLimit,
      Value<int?> deviceLimit,
      Value<DateTime?> expiredAt,
      Value<DateTime?> nextResetAt,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$XBoardSubscriptionsTableUpdateCompanionBuilder =
    XBoardSubscriptionsCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> subscribeUrl,
      Value<String> uuid,
      Value<int> planId,
      Value<String?> planName,
      Value<String?> token,
      Value<int> transferLimit,
      Value<int> uploadedBytes,
      Value<int> downloadedBytes,
      Value<int?> speedLimit,
      Value<int?> deviceLimit,
      Value<DateTime?> expiredAt,
      Value<DateTime?> nextResetAt,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });

class $$XBoardSubscriptionsTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardSubscriptionsTable> {
  $$XBoardSubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscribeUrl => $composableBuilder(
    column: $table.subscribeUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextResetAt => $composableBuilder(
    column: $table.nextResetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardSubscriptionsTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardSubscriptionsTable> {
  $$XBoardSubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscribeUrl => $composableBuilder(
    column: $table.subscribeUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiredAt => $composableBuilder(
    column: $table.expiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextResetAt => $composableBuilder(
    column: $table.nextResetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardSubscriptionsTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardSubscriptionsTable> {
  $$XBoardSubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get subscribeUrl => $composableBuilder(
    column: $table.subscribeUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<int> get transferLimit => $composableBuilder(
    column: $table.transferLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uploadedBytes => $composableBuilder(
    column: $table.uploadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiredAt =>
      $composableBuilder(column: $table.expiredAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextResetAt => $composableBuilder(
    column: $table.nextResetAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$XBoardSubscriptionsTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardSubscriptionsTable,
          XBoardSubscriptionRow,
          $$XBoardSubscriptionsTableFilterComposer,
          $$XBoardSubscriptionsTableOrderingComposer,
          $$XBoardSubscriptionsTableAnnotationComposer,
          $$XBoardSubscriptionsTableCreateCompanionBuilder,
          $$XBoardSubscriptionsTableUpdateCompanionBuilder,
          (
            XBoardSubscriptionRow,
            BaseReferences<
              _$XBoardDatabase,
              $XBoardSubscriptionsTable,
              XBoardSubscriptionRow
            >,
          ),
          XBoardSubscriptionRow,
          PrefetchHooks Function()
        > {
  $$XBoardSubscriptionsTableTableManager(
    _$XBoardDatabase db,
    $XBoardSubscriptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardSubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardSubscriptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$XBoardSubscriptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> subscribeUrl = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<int> transferLimit = const Value.absent(),
                Value<int> uploadedBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int?> speedLimit = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                Value<DateTime?> nextResetAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardSubscriptionsCompanion(
                id: id,
                email: email,
                subscribeUrl: subscribeUrl,
                uuid: uuid,
                planId: planId,
                planName: planName,
                token: token,
                transferLimit: transferLimit,
                uploadedBytes: uploadedBytes,
                downloadedBytes: downloadedBytes,
                speedLimit: speedLimit,
                deviceLimit: deviceLimit,
                expiredAt: expiredAt,
                nextResetAt: nextResetAt,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String subscribeUrl,
                required String uuid,
                required int planId,
                Value<String?> planName = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<int> transferLimit = const Value.absent(),
                Value<int> uploadedBytes = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<int?> speedLimit = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<DateTime?> expiredAt = const Value.absent(),
                Value<DateTime?> nextResetAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardSubscriptionsCompanion.insert(
                id: id,
                email: email,
                subscribeUrl: subscribeUrl,
                uuid: uuid,
                planId: planId,
                planName: planName,
                token: token,
                transferLimit: transferLimit,
                uploadedBytes: uploadedBytes,
                downloadedBytes: downloadedBytes,
                speedLimit: speedLimit,
                deviceLimit: deviceLimit,
                expiredAt: expiredAt,
                nextResetAt: nextResetAt,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardSubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardSubscriptionsTable,
      XBoardSubscriptionRow,
      $$XBoardSubscriptionsTableFilterComposer,
      $$XBoardSubscriptionsTableOrderingComposer,
      $$XBoardSubscriptionsTableAnnotationComposer,
      $$XBoardSubscriptionsTableCreateCompanionBuilder,
      $$XBoardSubscriptionsTableUpdateCompanionBuilder,
      (
        XBoardSubscriptionRow,
        BaseReferences<
          _$XBoardDatabase,
          $XBoardSubscriptionsTable,
          XBoardSubscriptionRow
        >,
      ),
      XBoardSubscriptionRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardPlansTableCreateCompanionBuilder =
    XBoardPlansCompanion Function({
      Value<int> id,
      required String name,
      required int groupId,
      required int transferQuota,
      Value<String?> description,
      Value<String> tags,
      Value<int?> speedLimit,
      Value<int?> deviceLimit,
      Value<bool> isVisible,
      Value<bool> renewable,
      Value<int?> sort,
      Value<double?> onetimePrice,
      Value<double?> monthlyPrice,
      Value<double?> quarterlyPrice,
      Value<double?> halfYearlyPrice,
      Value<double?> yearlyPrice,
      Value<double?> twoYearPrice,
      Value<double?> threeYearPrice,
      Value<double?> resetPrice,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> metadata,
      required DateTime cachedAt,
    });
typedef $$XBoardPlansTableUpdateCompanionBuilder =
    XBoardPlansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> groupId,
      Value<int> transferQuota,
      Value<String?> description,
      Value<String> tags,
      Value<int?> speedLimit,
      Value<int?> deviceLimit,
      Value<bool> isVisible,
      Value<bool> renewable,
      Value<int?> sort,
      Value<double?> onetimePrice,
      Value<double?> monthlyPrice,
      Value<double?> quarterlyPrice,
      Value<double?> halfYearlyPrice,
      Value<double?> yearlyPrice,
      Value<double?> twoYearPrice,
      Value<double?> threeYearPrice,
      Value<double?> resetPrice,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<String> metadata,
      Value<DateTime> cachedAt,
    });

class $$XBoardPlansTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardPlansTable> {
  $$XBoardPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferQuota => $composableBuilder(
    column: $table.transferQuota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get renewable => $composableBuilder(
    column: $table.renewable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get onetimePrice => $composableBuilder(
    column: $table.onetimePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quarterlyPrice => $composableBuilder(
    column: $table.quarterlyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get halfYearlyPrice => $composableBuilder(
    column: $table.halfYearlyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yearlyPrice => $composableBuilder(
    column: $table.yearlyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get twoYearPrice => $composableBuilder(
    column: $table.twoYearPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get threeYearPrice => $composableBuilder(
    column: $table.threeYearPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get resetPrice => $composableBuilder(
    column: $table.resetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardPlansTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardPlansTable> {
  $$XBoardPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferQuota => $composableBuilder(
    column: $table.transferQuota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVisible => $composableBuilder(
    column: $table.isVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get renewable => $composableBuilder(
    column: $table.renewable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get onetimePrice => $composableBuilder(
    column: $table.onetimePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quarterlyPrice => $composableBuilder(
    column: $table.quarterlyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get halfYearlyPrice => $composableBuilder(
    column: $table.halfYearlyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yearlyPrice => $composableBuilder(
    column: $table.yearlyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get twoYearPrice => $composableBuilder(
    column: $table.twoYearPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get threeYearPrice => $composableBuilder(
    column: $table.threeYearPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get resetPrice => $composableBuilder(
    column: $table.resetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardPlansTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardPlansTable> {
  $$XBoardPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get transferQuota => $composableBuilder(
    column: $table.transferQuota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get speedLimit => $composableBuilder(
    column: $table.speedLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deviceLimit => $composableBuilder(
    column: $table.deviceLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVisible =>
      $composableBuilder(column: $table.isVisible, builder: (column) => column);

  GeneratedColumn<bool> get renewable =>
      $composableBuilder(column: $table.renewable, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<double> get onetimePrice => $composableBuilder(
    column: $table.onetimePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quarterlyPrice => $composableBuilder(
    column: $table.quarterlyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get halfYearlyPrice => $composableBuilder(
    column: $table.halfYearlyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yearlyPrice => $composableBuilder(
    column: $table.yearlyPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get twoYearPrice => $composableBuilder(
    column: $table.twoYearPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get threeYearPrice => $composableBuilder(
    column: $table.threeYearPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get resetPrice => $composableBuilder(
    column: $table.resetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$XBoardPlansTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardPlansTable,
          XBoardPlanRow,
          $$XBoardPlansTableFilterComposer,
          $$XBoardPlansTableOrderingComposer,
          $$XBoardPlansTableAnnotationComposer,
          $$XBoardPlansTableCreateCompanionBuilder,
          $$XBoardPlansTableUpdateCompanionBuilder,
          (
            XBoardPlanRow,
            BaseReferences<_$XBoardDatabase, $XBoardPlansTable, XBoardPlanRow>,
          ),
          XBoardPlanRow,
          PrefetchHooks Function()
        > {
  $$XBoardPlansTableTableManager(_$XBoardDatabase db, $XBoardPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> groupId = const Value.absent(),
                Value<int> transferQuota = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> speedLimit = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> renewable = const Value.absent(),
                Value<int?> sort = const Value.absent(),
                Value<double?> onetimePrice = const Value.absent(),
                Value<double?> monthlyPrice = const Value.absent(),
                Value<double?> quarterlyPrice = const Value.absent(),
                Value<double?> halfYearlyPrice = const Value.absent(),
                Value<double?> yearlyPrice = const Value.absent(),
                Value<double?> twoYearPrice = const Value.absent(),
                Value<double?> threeYearPrice = const Value.absent(),
                Value<double?> resetPrice = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => XBoardPlansCompanion(
                id: id,
                name: name,
                groupId: groupId,
                transferQuota: transferQuota,
                description: description,
                tags: tags,
                speedLimit: speedLimit,
                deviceLimit: deviceLimit,
                isVisible: isVisible,
                renewable: renewable,
                sort: sort,
                onetimePrice: onetimePrice,
                monthlyPrice: monthlyPrice,
                quarterlyPrice: quarterlyPrice,
                halfYearlyPrice: halfYearlyPrice,
                yearlyPrice: yearlyPrice,
                twoYearPrice: twoYearPrice,
                threeYearPrice: threeYearPrice,
                resetPrice: resetPrice,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadata: metadata,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int groupId,
                required int transferQuota,
                Value<String?> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> speedLimit = const Value.absent(),
                Value<int?> deviceLimit = const Value.absent(),
                Value<bool> isVisible = const Value.absent(),
                Value<bool> renewable = const Value.absent(),
                Value<int?> sort = const Value.absent(),
                Value<double?> onetimePrice = const Value.absent(),
                Value<double?> monthlyPrice = const Value.absent(),
                Value<double?> quarterlyPrice = const Value.absent(),
                Value<double?> halfYearlyPrice = const Value.absent(),
                Value<double?> yearlyPrice = const Value.absent(),
                Value<double?> twoYearPrice = const Value.absent(),
                Value<double?> threeYearPrice = const Value.absent(),
                Value<double?> resetPrice = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                required DateTime cachedAt,
              }) => XBoardPlansCompanion.insert(
                id: id,
                name: name,
                groupId: groupId,
                transferQuota: transferQuota,
                description: description,
                tags: tags,
                speedLimit: speedLimit,
                deviceLimit: deviceLimit,
                isVisible: isVisible,
                renewable: renewable,
                sort: sort,
                onetimePrice: onetimePrice,
                monthlyPrice: monthlyPrice,
                quarterlyPrice: quarterlyPrice,
                halfYearlyPrice: halfYearlyPrice,
                yearlyPrice: yearlyPrice,
                twoYearPrice: twoYearPrice,
                threeYearPrice: threeYearPrice,
                resetPrice: resetPrice,
                createdAt: createdAt,
                updatedAt: updatedAt,
                metadata: metadata,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardPlansTable,
      XBoardPlanRow,
      $$XBoardPlansTableFilterComposer,
      $$XBoardPlansTableOrderingComposer,
      $$XBoardPlansTableAnnotationComposer,
      $$XBoardPlansTableCreateCompanionBuilder,
      $$XBoardPlansTableUpdateCompanionBuilder,
      (
        XBoardPlanRow,
        BaseReferences<_$XBoardDatabase, $XBoardPlansTable, XBoardPlanRow>,
      ),
      XBoardPlanRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardOrdersTableCreateCompanionBuilder =
    XBoardOrdersCompanion Function({
      Value<int> id,
      required String tradeNo,
      required String email,
      required int planId,
      required String period,
      required double totalAmount,
      required int statusCode,
      Value<String?> planName,
      Value<String?> planContent,
      required DateTime createdAt,
      Value<DateTime?> paidAt,
      Value<double> handlingAmount,
      Value<double> balanceAmount,
      Value<double> refundAmount,
      Value<double> discountAmount,
      Value<double> surplusAmount,
      Value<int?> paymentId,
      Value<String?> paymentName,
      Value<int?> couponId,
      Value<int?> commissionStatusCode,
      Value<double> commissionBalance,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$XBoardOrdersTableUpdateCompanionBuilder =
    XBoardOrdersCompanion Function({
      Value<int> id,
      Value<String> tradeNo,
      Value<String> email,
      Value<int> planId,
      Value<String> period,
      Value<double> totalAmount,
      Value<int> statusCode,
      Value<String?> planName,
      Value<String?> planContent,
      Value<DateTime> createdAt,
      Value<DateTime?> paidAt,
      Value<double> handlingAmount,
      Value<double> balanceAmount,
      Value<double> refundAmount,
      Value<double> discountAmount,
      Value<double> surplusAmount,
      Value<int?> paymentId,
      Value<String?> paymentName,
      Value<int?> couponId,
      Value<int?> commissionStatusCode,
      Value<double> commissionBalance,
      Value<String> metadata,
      Value<DateTime?> lastSyncedAt,
    });

class $$XBoardOrdersTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardOrdersTable> {
  $$XBoardOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeNo => $composableBuilder(
    column: $table.tradeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planContent => $composableBuilder(
    column: $table.planContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get handlingAmount => $composableBuilder(
    column: $table.handlingAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAmount => $composableBuilder(
    column: $table.balanceAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get surplusAmount => $composableBuilder(
    column: $table.surplusAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentName => $composableBuilder(
    column: $table.paymentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get couponId => $composableBuilder(
    column: $table.couponId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commissionStatusCode => $composableBuilder(
    column: $table.commissionStatusCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get commissionBalance => $composableBuilder(
    column: $table.commissionBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardOrdersTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardOrdersTable> {
  $$XBoardOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeNo => $composableBuilder(
    column: $table.tradeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planContent => $composableBuilder(
    column: $table.planContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get handlingAmount => $composableBuilder(
    column: $table.handlingAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAmount => $composableBuilder(
    column: $table.balanceAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get surplusAmount => $composableBuilder(
    column: $table.surplusAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentName => $composableBuilder(
    column: $table.paymentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get couponId => $composableBuilder(
    column: $table.couponId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commissionStatusCode => $composableBuilder(
    column: $table.commissionStatusCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get commissionBalance => $composableBuilder(
    column: $table.commissionBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardOrdersTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardOrdersTable> {
  $$XBoardOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tradeNo =>
      $composableBuilder(column: $table.tradeNo, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statusCode => $composableBuilder(
    column: $table.statusCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<String> get planContent => $composableBuilder(
    column: $table.planContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<double> get handlingAmount => $composableBuilder(
    column: $table.handlingAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceAmount => $composableBuilder(
    column: $table.balanceAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get surplusAmount => $composableBuilder(
    column: $table.surplusAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<String> get paymentName => $composableBuilder(
    column: $table.paymentName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get couponId =>
      $composableBuilder(column: $table.couponId, builder: (column) => column);

  GeneratedColumn<int> get commissionStatusCode => $composableBuilder(
    column: $table.commissionStatusCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get commissionBalance => $composableBuilder(
    column: $table.commissionBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$XBoardOrdersTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardOrdersTable,
          XBoardOrderRow,
          $$XBoardOrdersTableFilterComposer,
          $$XBoardOrdersTableOrderingComposer,
          $$XBoardOrdersTableAnnotationComposer,
          $$XBoardOrdersTableCreateCompanionBuilder,
          $$XBoardOrdersTableUpdateCompanionBuilder,
          (
            XBoardOrderRow,
            BaseReferences<
              _$XBoardDatabase,
              $XBoardOrdersTable,
              XBoardOrderRow
            >,
          ),
          XBoardOrderRow,
          PrefetchHooks Function()
        > {
  $$XBoardOrdersTableTableManager(_$XBoardDatabase db, $XBoardOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tradeNo = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<int> statusCode = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<String?> planContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<double> handlingAmount = const Value.absent(),
                Value<double> balanceAmount = const Value.absent(),
                Value<double> refundAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> surplusAmount = const Value.absent(),
                Value<int?> paymentId = const Value.absent(),
                Value<String?> paymentName = const Value.absent(),
                Value<int?> couponId = const Value.absent(),
                Value<int?> commissionStatusCode = const Value.absent(),
                Value<double> commissionBalance = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardOrdersCompanion(
                id: id,
                tradeNo: tradeNo,
                email: email,
                planId: planId,
                period: period,
                totalAmount: totalAmount,
                statusCode: statusCode,
                planName: planName,
                planContent: planContent,
                createdAt: createdAt,
                paidAt: paidAt,
                handlingAmount: handlingAmount,
                balanceAmount: balanceAmount,
                refundAmount: refundAmount,
                discountAmount: discountAmount,
                surplusAmount: surplusAmount,
                paymentId: paymentId,
                paymentName: paymentName,
                couponId: couponId,
                commissionStatusCode: commissionStatusCode,
                commissionBalance: commissionBalance,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tradeNo,
                required String email,
                required int planId,
                required String period,
                required double totalAmount,
                required int statusCode,
                Value<String?> planName = const Value.absent(),
                Value<String?> planContent = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> paidAt = const Value.absent(),
                Value<double> handlingAmount = const Value.absent(),
                Value<double> balanceAmount = const Value.absent(),
                Value<double> refundAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> surplusAmount = const Value.absent(),
                Value<int?> paymentId = const Value.absent(),
                Value<String?> paymentName = const Value.absent(),
                Value<int?> couponId = const Value.absent(),
                Value<int?> commissionStatusCode = const Value.absent(),
                Value<double> commissionBalance = const Value.absent(),
                Value<String> metadata = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => XBoardOrdersCompanion.insert(
                id: id,
                tradeNo: tradeNo,
                email: email,
                planId: planId,
                period: period,
                totalAmount: totalAmount,
                statusCode: statusCode,
                planName: planName,
                planContent: planContent,
                createdAt: createdAt,
                paidAt: paidAt,
                handlingAmount: handlingAmount,
                balanceAmount: balanceAmount,
                refundAmount: refundAmount,
                discountAmount: discountAmount,
                surplusAmount: surplusAmount,
                paymentId: paymentId,
                paymentName: paymentName,
                couponId: couponId,
                commissionStatusCode: commissionStatusCode,
                commissionBalance: commissionBalance,
                metadata: metadata,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardOrdersTable,
      XBoardOrderRow,
      $$XBoardOrdersTableFilterComposer,
      $$XBoardOrdersTableOrderingComposer,
      $$XBoardOrdersTableAnnotationComposer,
      $$XBoardOrdersTableCreateCompanionBuilder,
      $$XBoardOrdersTableUpdateCompanionBuilder,
      (
        XBoardOrderRow,
        BaseReferences<_$XBoardDatabase, $XBoardOrdersTable, XBoardOrderRow>,
      ),
      XBoardOrderRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardNoticeReadsTableCreateCompanionBuilder =
    XBoardNoticeReadsCompanion Function({
      Value<int> id,
      required int noticeId,
      required DateTime readAt,
    });
typedef $$XBoardNoticeReadsTableUpdateCompanionBuilder =
    XBoardNoticeReadsCompanion Function({
      Value<int> id,
      Value<int> noticeId,
      Value<DateTime> readAt,
    });

class $$XBoardNoticeReadsTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardNoticeReadsTable> {
  $$XBoardNoticeReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noticeId => $composableBuilder(
    column: $table.noticeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardNoticeReadsTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardNoticeReadsTable> {
  $$XBoardNoticeReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noticeId => $composableBuilder(
    column: $table.noticeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardNoticeReadsTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardNoticeReadsTable> {
  $$XBoardNoticeReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get noticeId =>
      $composableBuilder(column: $table.noticeId, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$XBoardNoticeReadsTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardNoticeReadsTable,
          XBoardNoticeReadRow,
          $$XBoardNoticeReadsTableFilterComposer,
          $$XBoardNoticeReadsTableOrderingComposer,
          $$XBoardNoticeReadsTableAnnotationComposer,
          $$XBoardNoticeReadsTableCreateCompanionBuilder,
          $$XBoardNoticeReadsTableUpdateCompanionBuilder,
          (
            XBoardNoticeReadRow,
            BaseReferences<
              _$XBoardDatabase,
              $XBoardNoticeReadsTable,
              XBoardNoticeReadRow
            >,
          ),
          XBoardNoticeReadRow,
          PrefetchHooks Function()
        > {
  $$XBoardNoticeReadsTableTableManager(
    _$XBoardDatabase db,
    $XBoardNoticeReadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardNoticeReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardNoticeReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardNoticeReadsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noticeId = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
              }) => XBoardNoticeReadsCompanion(
                id: id,
                noticeId: noticeId,
                readAt: readAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noticeId,
                required DateTime readAt,
              }) => XBoardNoticeReadsCompanion.insert(
                id: id,
                noticeId: noticeId,
                readAt: readAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardNoticeReadsTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardNoticeReadsTable,
      XBoardNoticeReadRow,
      $$XBoardNoticeReadsTableFilterComposer,
      $$XBoardNoticeReadsTableOrderingComposer,
      $$XBoardNoticeReadsTableAnnotationComposer,
      $$XBoardNoticeReadsTableCreateCompanionBuilder,
      $$XBoardNoticeReadsTableUpdateCompanionBuilder,
      (
        XBoardNoticeReadRow,
        BaseReferences<
          _$XBoardDatabase,
          $XBoardNoticeReadsTable,
          XBoardNoticeReadRow
        >,
      ),
      XBoardNoticeReadRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardDomainsTableCreateCompanionBuilder =
    XBoardDomainsCompanion Function({
      Value<int> id,
      required String url,
      Value<int?> latencyMs,
      Value<bool> isActive,
      Value<bool> isAvailable,
      Value<DateTime?> lastCheckedAt,
    });
typedef $$XBoardDomainsTableUpdateCompanionBuilder =
    XBoardDomainsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<int?> latencyMs,
      Value<bool> isActive,
      Value<bool> isAvailable,
      Value<DateTime?> lastCheckedAt,
    });

class $$XBoardDomainsTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardDomainsTable> {
  $$XBoardDomainsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardDomainsTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardDomainsTable> {
  $$XBoardDomainsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardDomainsTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardDomainsTable> {
  $$XBoardDomainsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );
}

class $$XBoardDomainsTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardDomainsTable,
          XBoardDomainRow,
          $$XBoardDomainsTableFilterComposer,
          $$XBoardDomainsTableOrderingComposer,
          $$XBoardDomainsTableAnnotationComposer,
          $$XBoardDomainsTableCreateCompanionBuilder,
          $$XBoardDomainsTableUpdateCompanionBuilder,
          (
            XBoardDomainRow,
            BaseReferences<
              _$XBoardDatabase,
              $XBoardDomainsTable,
              XBoardDomainRow
            >,
          ),
          XBoardDomainRow,
          PrefetchHooks Function()
        > {
  $$XBoardDomainsTableTableManager(
    _$XBoardDatabase db,
    $XBoardDomainsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardDomainsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardDomainsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardDomainsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
              }) => XBoardDomainsCompanion(
                id: id,
                url: url,
                latencyMs: latencyMs,
                isActive: isActive,
                isAvailable: isAvailable,
                lastCheckedAt: lastCheckedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                Value<int?> latencyMs = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
              }) => XBoardDomainsCompanion.insert(
                id: id,
                url: url,
                latencyMs: latencyMs,
                isActive: isActive,
                isAvailable: isAvailable,
                lastCheckedAt: lastCheckedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardDomainsTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardDomainsTable,
      XBoardDomainRow,
      $$XBoardDomainsTableFilterComposer,
      $$XBoardDomainsTableOrderingComposer,
      $$XBoardDomainsTableAnnotationComposer,
      $$XBoardDomainsTableCreateCompanionBuilder,
      $$XBoardDomainsTableUpdateCompanionBuilder,
      (
        XBoardDomainRow,
        BaseReferences<_$XBoardDatabase, $XBoardDomainsTable, XBoardDomainRow>,
      ),
      XBoardDomainRow,
      PrefetchHooks Function()
    >;
typedef $$XBoardAuthTokensTableCreateCompanionBuilder =
    XBoardAuthTokensCompanion Function({
      Value<int> id,
      required String email,
      required String token,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
    });
typedef $$XBoardAuthTokensTableUpdateCompanionBuilder =
    XBoardAuthTokensCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> token,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
    });

class $$XBoardAuthTokensTableFilterComposer
    extends Composer<_$XBoardDatabase, $XBoardAuthTokensTable> {
  $$XBoardAuthTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XBoardAuthTokensTableOrderingComposer
    extends Composer<_$XBoardDatabase, $XBoardAuthTokensTable> {
  $$XBoardAuthTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XBoardAuthTokensTableAnnotationComposer
    extends Composer<_$XBoardDatabase, $XBoardAuthTokensTable> {
  $$XBoardAuthTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$XBoardAuthTokensTableTableManager
    extends
        RootTableManager<
          _$XBoardDatabase,
          $XBoardAuthTokensTable,
          XBoardAuthTokenRow,
          $$XBoardAuthTokensTableFilterComposer,
          $$XBoardAuthTokensTableOrderingComposer,
          $$XBoardAuthTokensTableAnnotationComposer,
          $$XBoardAuthTokensTableCreateCompanionBuilder,
          $$XBoardAuthTokensTableUpdateCompanionBuilder,
          (
            XBoardAuthTokenRow,
            BaseReferences<
              _$XBoardDatabase,
              $XBoardAuthTokensTable,
              XBoardAuthTokenRow
            >,
          ),
          XBoardAuthTokenRow,
          PrefetchHooks Function()
        > {
  $$XBoardAuthTokensTableTableManager(
    _$XBoardDatabase db,
    $XBoardAuthTokensTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XBoardAuthTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XBoardAuthTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XBoardAuthTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> token = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => XBoardAuthTokensCompanion(
                id: id,
                email: email,
                token: token,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String token,
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
              }) => XBoardAuthTokensCompanion.insert(
                id: id,
                email: email,
                token: token,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XBoardAuthTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$XBoardDatabase,
      $XBoardAuthTokensTable,
      XBoardAuthTokenRow,
      $$XBoardAuthTokensTableFilterComposer,
      $$XBoardAuthTokensTableOrderingComposer,
      $$XBoardAuthTokensTableAnnotationComposer,
      $$XBoardAuthTokensTableCreateCompanionBuilder,
      $$XBoardAuthTokensTableUpdateCompanionBuilder,
      (
        XBoardAuthTokenRow,
        BaseReferences<
          _$XBoardDatabase,
          $XBoardAuthTokensTable,
          XBoardAuthTokenRow
        >,
      ),
      XBoardAuthTokenRow,
      PrefetchHooks Function()
    >;

class $XBoardDatabaseManager {
  final _$XBoardDatabase _db;
  $XBoardDatabaseManager(this._db);
  $$XBoardUsersTableTableManager get xBoardUsers =>
      $$XBoardUsersTableTableManager(_db, _db.xBoardUsers);
  $$XBoardSubscriptionsTableTableManager get xBoardSubscriptions =>
      $$XBoardSubscriptionsTableTableManager(_db, _db.xBoardSubscriptions);
  $$XBoardPlansTableTableManager get xBoardPlans =>
      $$XBoardPlansTableTableManager(_db, _db.xBoardPlans);
  $$XBoardOrdersTableTableManager get xBoardOrders =>
      $$XBoardOrdersTableTableManager(_db, _db.xBoardOrders);
  $$XBoardNoticeReadsTableTableManager get xBoardNoticeReads =>
      $$XBoardNoticeReadsTableTableManager(_db, _db.xBoardNoticeReads);
  $$XBoardDomainsTableTableManager get xBoardDomains =>
      $$XBoardDomainsTableTableManager(_db, _db.xBoardDomains);
  $$XBoardAuthTokensTableTableManager get xBoardAuthTokens =>
      $$XBoardAuthTokensTableTableManager(_db, _db.xBoardAuthTokens);
}

mixin _$XBoardUsersDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardUsersTable get xBoardUsers => attachedDatabase.xBoardUsers;
  XBoardUsersDaoManager get managers => XBoardUsersDaoManager(this);
}

class XBoardUsersDaoManager {
  final _$XBoardUsersDaoMixin _db;
  XBoardUsersDaoManager(this._db);
  $$XBoardUsersTableTableManager get xBoardUsers =>
      $$XBoardUsersTableTableManager(_db.attachedDatabase, _db.xBoardUsers);
}

mixin _$XBoardSubscriptionsDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardSubscriptionsTable get xBoardSubscriptions =>
      attachedDatabase.xBoardSubscriptions;
  XBoardSubscriptionsDaoManager get managers =>
      XBoardSubscriptionsDaoManager(this);
}

class XBoardSubscriptionsDaoManager {
  final _$XBoardSubscriptionsDaoMixin _db;
  XBoardSubscriptionsDaoManager(this._db);
  $$XBoardSubscriptionsTableTableManager get xBoardSubscriptions =>
      $$XBoardSubscriptionsTableTableManager(
        _db.attachedDatabase,
        _db.xBoardSubscriptions,
      );
}

mixin _$XBoardPlansDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardPlansTable get xBoardPlans => attachedDatabase.xBoardPlans;
  XBoardPlansDaoManager get managers => XBoardPlansDaoManager(this);
}

class XBoardPlansDaoManager {
  final _$XBoardPlansDaoMixin _db;
  XBoardPlansDaoManager(this._db);
  $$XBoardPlansTableTableManager get xBoardPlans =>
      $$XBoardPlansTableTableManager(_db.attachedDatabase, _db.xBoardPlans);
}

mixin _$XBoardOrdersDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardOrdersTable get xBoardOrders => attachedDatabase.xBoardOrders;
  XBoardOrdersDaoManager get managers => XBoardOrdersDaoManager(this);
}

class XBoardOrdersDaoManager {
  final _$XBoardOrdersDaoMixin _db;
  XBoardOrdersDaoManager(this._db);
  $$XBoardOrdersTableTableManager get xBoardOrders =>
      $$XBoardOrdersTableTableManager(_db.attachedDatabase, _db.xBoardOrders);
}

mixin _$XBoardNoticeReadsDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardNoticeReadsTable get xBoardNoticeReads =>
      attachedDatabase.xBoardNoticeReads;
  XBoardNoticeReadsDaoManager get managers => XBoardNoticeReadsDaoManager(this);
}

class XBoardNoticeReadsDaoManager {
  final _$XBoardNoticeReadsDaoMixin _db;
  XBoardNoticeReadsDaoManager(this._db);
  $$XBoardNoticeReadsTableTableManager get xBoardNoticeReads =>
      $$XBoardNoticeReadsTableTableManager(
        _db.attachedDatabase,
        _db.xBoardNoticeReads,
      );
}

mixin _$XBoardDomainsDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardDomainsTable get xBoardDomains => attachedDatabase.xBoardDomains;
  XBoardDomainsDaoManager get managers => XBoardDomainsDaoManager(this);
}

class XBoardDomainsDaoManager {
  final _$XBoardDomainsDaoMixin _db;
  XBoardDomainsDaoManager(this._db);
  $$XBoardDomainsTableTableManager get xBoardDomains =>
      $$XBoardDomainsTableTableManager(_db.attachedDatabase, _db.xBoardDomains);
}

mixin _$XBoardAuthTokensDaoMixin on DatabaseAccessor<XBoardDatabase> {
  $XBoardAuthTokensTable get xBoardAuthTokens =>
      attachedDatabase.xBoardAuthTokens;
  XBoardAuthTokensDaoManager get managers => XBoardAuthTokensDaoManager(this);
}

class XBoardAuthTokensDaoManager {
  final _$XBoardAuthTokensDaoMixin _db;
  XBoardAuthTokensDaoManager(this._db);
  $$XBoardAuthTokensTableTableManager get xBoardAuthTokens =>
      $$XBoardAuthTokensTableTableManager(
        _db.attachedDatabase,
        _db.xBoardAuthTokens,
      );
}
