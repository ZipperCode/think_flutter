import 'package:flutter/services.dart';

class MessageChannelProxy {
  static const String CHANNEL_KEY = "";

  BasicMessageChannel _messageChannel = BasicMessageChannel(CHANNEL_KEY, StandardMessageCodec());

  Map<dynamic, Function> _delayCallback = {};

  void sendMessage(Map<String, dynamic> args, {Function delayCallback}) async {
    if (args['key'] != null && delayCallback != null) {
      _delayCallback[args['key']] = delayCallback;
    }

    dynamic result = await _messageChannel.send(args);
    if (result is Map) {
      int code = result['code'];
      String message = result['message'];
      print("code = $code , message = $message");
    } else {
      print("result = $result");
    }
  }

  Future<dynamic> onReceiveMessage(dynamic message) {
    if (message != null) {
      if (message is Map && message['key'] ?? null != null) {
        Function.apply(_delayCallback[message['key']], null, message);
      } else {
        return Future.value(message);
      }
    }
    return null;
  }

  static MessageChannelProxy _instance;

  MessageChannelProxy._internal() {
    _messageChannel..setMessageHandler(onReceiveMessage);
  }

  factory MessageChannelProxy.instance() {
    if (_instance == null) {
      _instance = MessageChannelProxy._internal();
    }
    return _instance;
  }
}
