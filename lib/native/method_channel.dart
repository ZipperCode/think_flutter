import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MyMethodChannel {
  static const CHANNEL_KEY = "";

  MethodChannel _methodChannel = MethodChannel(CHANNEL_KEY);

  /// 函数缓存，用于原生 -> flutter回调
  Map<String, Function> funcCache = {};

  MyMethodChannel._internal() {
    _methodChannel..setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> invokeNative(String name, Map<String, dynamic> args, {Function delayCallback}) async {
    if (name != null && delayCallback != null) {
      funcCache[name] = delayCallback;
    }

    dynamic result = await compute(_invoke, args);

    return result;
  }

  Future<dynamic> _invoke(Map<String, dynamic> params) async {
    String name = params["method"];
    if (name == null) {
      return "";
    }
    dynamic result = await _methodChannel.invokeMethod(name, params);
    return result;
  }

  /// 原生回调flutter
  Future<dynamic> _methodCallHandler(MethodCall methodCall) {
    String name = methodCall.method;
    Map arguments = methodCall.arguments;
    if (funcCache.containsKey(name)) {
      return Function.apply(funcCache[name], null, arguments);
    } else {
      return Future.sync(() => arguments);
    }
  }

  void registerCallback(String name, Function function) {
    if (name != null) {
      funcCache[name] = function;
    }
  }

  void unRegisterCallback(String name) {
    if (name != null && funcCache.containsKey(name)) {
      funcCache.remove(name);
    }
  }

  static MyMethodChannel _instance;

  factory MyMethodChannel.instance() {
    if (_instance == null) {
      _instance = MyMethodChannel._internal();
    }
    return _instance;
  }
}
