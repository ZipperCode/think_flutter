import 'dart:async';

import 'package:flutter/services.dart';
import 'package:think_flutter/native/native_exception.dart';

class EventChannelProxy {
  static const CHANNEL_KEY = "";

  /// 事件接收
  EventChannel _eventChannel = EventChannel(CHANNEL_KEY);

  /// 事件转发
  StreamController _streamController;

  /// 存储订阅
  Map<dynamic, StreamSubscription> _nativeSubscription = {};

  StreamSink get _streamSink => _streamController?.sink ?? null;

  static EventChannelProxy _instance;

  EventChannelProxy._internal() {
    _eventChannel.receiveBroadcastStream().listen(_onNativeData, onError: _onNativeError);
    _streamController = StreamController.broadcast();
  }

  StreamSubscription<dynamic> register<T>(dynamic key, {void onData(T event), Function onError}) {
    if (key == null) {
      return null;
    }
    var subscription;
    if (T == dynamic) {
      subscription = _streamController.stream.listen(onData, onError: onError);
    } else {
      _streamController.stream.where((event) => event is T).cast<T>().listen(onData, onError: onError);
    }

    _nativeSubscription[key] = subscription;
    return subscription;
  }

  void unRegister(dynamic key) {
    if (_nativeSubscription.containsKey(key)) {
      var subscription = _nativeSubscription.remove(key);
      subscription?.cancel();
    }
  }

  void dispose() {
    _streamController?.close();
  }

  /// 收到原生传递的事件
  void _onNativeData(dynamic event) {
    print("原生传递的事件 $event");
    _streamSink?.add(event);
  }

  void _onNativeError(dynamic error) {
    print("原生传递事件错误");
    _streamSink?.add(NativeException(data: error));
  }

  factory EventChannelProxy.getInstance() {
    if (_instance == null) {
      _instance = EventChannelProxy._internal();
    }
    return _instance;
  }
}
