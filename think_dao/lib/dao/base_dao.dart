import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'base_bean.dart';
import 'db_helper.dart';

abstract class BaseDao<T extends BaseBean> {
  DbHelper _dbHelper;

  StreamController<T> _streamController;
  StreamSink<T> _streamSink;
  Stream<T> _stream;
  List<T> _allLiveData = [];

  BaseDao() {
    this._dbHelper = DbHelper.getInstance();
    _streamController = StreamController.broadcast();
    _streamSink = _streamController.sink;
    _stream = _streamController.stream
      ..listen((event) {
        if (_allLiveData.contains(event)) {
          _allLiveData.remove(event);
        }
        _allLiveData.add(event);
      });
  }

  /// get获取
  String get tableName;

  Future<int> insert(T data) async {
    int result = 0;
    try {
      final db = await _dbHelper.open();
      result = await db.insert(tableName, data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await db.close();
    } catch (e) {
      print("");
    } finally {
      _streamSink.add(data);
    }
    return result;
  }

  Future<int> update(T data) async {
    final db = await _dbHelper.open();
    int result = await db
        .update(tableName, data.toMap(), where: "id = ?", whereArgs: [data.id]);
    await db.close();
    return result;
  }

  Future<int> delete(T data) async {
    final db = await _dbHelper.open();
    int result =
        await db.delete(tableName, where: "id = ?", whereArgs: [data.id]);
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
