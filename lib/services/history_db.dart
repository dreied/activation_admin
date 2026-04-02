import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ActivationRecord {
  final int? id;
  final String app;
  final String deviceId;
  final String customerName;
  final String customerPhone;
  final String activationCode;
  final DateTime createdAt;
  final bool synced;

  ActivationRecord({
    this.id,
    required this.app,
    required this.deviceId,
    required this.customerName,
    required this.customerPhone,
    required this.activationCode,
    required this.createdAt,
    required this.synced,
  });

  ActivationRecord copyWith({
    int? id,
    String? app,
    String? deviceId,
    String? customerName,
    String? customerPhone,
    String? activationCode,
    DateTime? createdAt,
    bool? synced,
  }) {
    return ActivationRecord(
      id: id ?? this.id,
      app: app ?? this.app,
      deviceId: deviceId ?? this.deviceId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      activationCode: activationCode ?? this.activationCode,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app': app,
      'deviceId': deviceId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'activationCode': activationCode,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  static ActivationRecord fromMap(Map<String, dynamic> map) {
    return ActivationRecord(
      id: map['id'] as int?,
      app: map['app'] as String,
      deviceId: map['deviceId'] as String,
      customerName: map['customerName'] as String,
      customerPhone: map['customerPhone'] as String,
      activationCode: map['activationCode'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      synced: (map['synced'] as int) == 1,
    );
  }
}

class HistoryDb {
  HistoryDb._();
  static final HistoryDb instance = HistoryDb._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'activation_history.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            app TEXT NOT NULL,
            deviceId TEXT NOT NULL,
            customerName TEXT NOT NULL,
            customerPhone TEXT NOT NULL,
            activationCode TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            synced INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_app_device ON history(app, deviceId)',
        );
      },
    );
  }

  Future<int> insertRecord(ActivationRecord record) async {
    final db = await database;
    return db.insert('history', record.toMap());
  }

  Future<List<ActivationRecord>> getAllRecords() async {
    final db = await database;
    final rows = await db.query(
      'history',
      orderBy: 'createdAt DESC',
    );
    return rows.map(ActivationRecord.fromMap).toList();
  }

  Future<List<ActivationRecord>> getUnsyncedWebActivations() async {
    final db = await database;
    final rows = await db.query(
      'history',
      where: 'app = ? AND synced = 0',
      whereArgs: ['web'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(ActivationRecord.fromMap).toList();
  }

  Future<void> markSynced(int id) async {
    final db = await database;
    await db.update(
      'history',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCustomerInfo({
    required int id,
    required String customerName,
    required String customerPhone,
  }) async {
    final db = await database;
    await db.update(
      'history',
      {
        'customerName': customerName,
        'customerPhone': customerPhone,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ActivationRecord?> getByAppAndDevice(
      String app, String deviceId) async {
    final db = await database;
    final rows = await db.query(
      'history',
      where: 'app = ? AND deviceId = ?',
      whereArgs: [app, deviceId],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ActivationRecord.fromMap(rows.first);
  }

  Future<void> upsertByAppAndDevice(ActivationRecord record) async {
    final existing = await getByAppAndDevice(record.app, record.deviceId);
    final db = await database;

    if (existing == null) {
      await db.insert('history', record.toMap());
    } else {
      final updated = existing.copyWith(
        customerName: record.customerName,
        customerPhone: record.customerPhone,
        activationCode: record.activationCode,
        createdAt: record.createdAt,
        synced: false,
      );
      await db.update(
        'history',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
