import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill.dart';

/// SQLite 数据库管理 —— 单例模式
///
/// 设计要点：
/// - 单例 + 懒加载初始化，确保全局只有一个数据库连接
/// - sqflite 仅支持 Android / iOS / macOS，其他平台抛出明确异常
/// - 调用方通过 isSupported 预先判断，或在 async 方法中 catch UnsupportedError

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName = 'cheese_book.db';
  static const int _dbVersion = 1;
  static const String _tableBills = 'bills';

  /// 当前平台是否可用 SQLite
  static bool get isSupported {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (!isSupported) {
      throw UnsupportedError(
        '起司记账当前仅支持 Android / iOS / macOS 运行。\n'
        '请在 MuMu 模拟器或安卓真机上调试。',
      );
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableBills (
        id       TEXT PRIMARY KEY,
        type     TEXT NOT NULL,
        amount   REAL NOT NULL,
        category TEXT NOT NULL,
        note     TEXT DEFAULT '',
        date     TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_bills_date ON $_tableBills(date)',
    );
    await db.execute(
      'CREATE INDEX idx_bills_type ON $_tableBills(type)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 预留版本升级迁移逻辑
  }

  // ── CRUD ──

  Future<void> insertBill(Bill bill) async {
    final db = await database;
    await db.insert(_tableBills, bill.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBill(Bill bill) async {
    final db = await database;
    await db.update(
      _tableBills,
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<void> deleteBill(String id) async {
    final db = await database;
    await db.delete(_tableBills, where: 'id = ?', whereArgs: [id]);
  }

  Future<Bill?> getBillById(String id) async {
    final db = await database;
    final rows = await db.query(
      _tableBills,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Bill.fromMap(rows.first);
  }

  Future<List<Bill>> getAllBills({int? limit, int? offset}) async {
    final db = await database;
    final rows = await db.query(
      _tableBills,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((row) => Bill.fromMap(row)).toList();
  }

  Future<List<Bill>> getBillsByMonth(String month) async {
    final db = await database;
    final rows = await db.query(
      _tableBills,
      where: 'date LIKE ?',
      whereArgs: ['$month%'],
      orderBy: 'date DESC',
    );
    return rows.map((row) => Bill.fromMap(row)).toList();
  }

  // ── 统计 ──

  Future<Map<String, double>> getMonthSummary(String month) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM $_tableBills
      WHERE date LIKE ?
      GROUP BY type
    ''', ['$month%']);

    double income = 0;
    double expense = 0;
    for (final row in result) {
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (row['type'] == 'income') {
        income = total;
      } else {
        expense = total;
      }
    }
    return {'income': income, 'expense': expense};
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(String month) async {
    final db = await database;
    return db.rawQuery('''
      SELECT category, SUM(amount) as total, COUNT(*) as count
      FROM $_tableBills
      WHERE type = 'expense' AND date LIKE ?
      GROUP BY category
      ORDER BY total DESC
    ''', ['$month%']);
  }

  Future<int> getBillCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM $_tableBills');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
