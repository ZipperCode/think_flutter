import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'user_dao.dart';

class UpgradeTableBean {
  String upgradeSql = "";
}

class UpgradeDbBean {
  int version;

  String dbName;
}

class DbHelper {
  static const DB_NAME = '';

  static const DB_VERSION = 1;

  static DbHelper _instance;

  /// 数据库访问路径
  String _dbPath;

  /// 数据库版本号
  int _dbVersion;

  /// 数据库对象
  Database _database;

  DbHelper._internal();

  void init() async {
    var databasePath = await getDatabasesPath();
    _dbPath = join(databasePath, DB_NAME);
    _dbVersion = DB_VERSION;
    _database = await openDatabase(_dbPath,
        version: _dbVersion, onCreate: onCreate, onUpgrade: onUpgrade);
  }

  void onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(UserDao.CREATE_TABLE);
    }).catchError((e) {
      print("数据库创建失败 $e");
    });
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    /// TODO
    for (var i = oldVersion + 1; i <= newVersion; i++) {
      switch (i) {
      }
    }
  }

  Future<Database> open() async {
    if (_database == null || !_database.isOpen) {
      _database = await openDatabase(_dbPath);
    }
    return _database;
  }

  void close() {
    if (_database != null && _database.isOpen) {
      _database.close();
    }
  }

  factory DbHelper.getInstance() {
    if (_instance == null) {
      _instance = DbHelper._internal();
      _instance.init();
    }
    return _instance;
  }
}
