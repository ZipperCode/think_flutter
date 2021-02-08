import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:think_flutter/dao/base_bean.dart';
import 'package:think_flutter/dao/db_helper.dart';

abstract class BaseDao<T extends BaseBean> {
  DbHelper _dbHelper;

  BaseDao() {
    this._dbHelper = DbHelper.getInstance();
  }

  /// get获取
  String get tableName;

  Future<int> insert(T data) async {
    final db = await _dbHelper.open();
    int result = await db.insert(tableName, data.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await db.close();
    return result;
  }

  Future<int> update(T data) async {
    final db = await _dbHelper.open();
    int result = await db.update(tableName, data.toMap(), where: "id = ?", whereArgs: [data.id]);
    await db.close();
    return result;
  }

  Future<int> delete(T data) async {
    final db = await _dbHelper.open();
    int result = await db.delete(tableName, where: "id = ?", whereArgs: [data.id]);
    await db.close();
    return result;
  }

  Future<Map<String, dynamic>> selectById(int id) async {
    final db = await _dbHelper.open();
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    await db.close();

    return maps[0];
  }

  Future<List<Map<String, dynamic>>> selectAll() async {
    final db = await _dbHelper.open();
    List<Map<String, dynamic>> maps = await db.query(tableName);
    await db.close();
    return maps;
  }
}
