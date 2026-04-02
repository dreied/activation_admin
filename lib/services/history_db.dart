import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'activation_history.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activations (
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
      },
    );
  }

  Database get db {
    if (_db == null) {
      throw Exception('HistoryDb not initialized. Call HistoryDb.instance.init() in main().');
    }
    return _db!;
  }

  Future<int> insertRecord(ActivationRecord record) async {
    return await db.insert('activations', record.toMap());
  }

  Future<List<ActivationRecord>> getAllRecords() async {
    final rows = await db.query(
      'activations',
      orderBy: 'createdAt DESC',
    );
    return rows.map(ActivationRecord.fromMap).toList();
  }

  Future<void> updateCustomerInfo({
    required int id,
    required String customerName,
    required String customerPhone,
  }) async {
    await db.update(
      'activations',
      {
        'customerName': customerName,
        'customerPhone': customerPhone,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ActivationRecord>> getUnsyncedWebActivations() async {
    final rows = await db.query(
      'activations',
      where: 'app = ? AND synced = 0',
      whereArgs: ['web'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(ActivationRecord.fromMap).toList();
  }

  Future<void> markSynced(int id) async {
    await db.update(
      'activations',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
