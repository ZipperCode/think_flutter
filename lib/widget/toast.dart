import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// [Overlay] 继承StateFullWidget 状态为[OverlayState]
/// 类似于Stack布局，将[OverlayEntry]插入到[Overlay]中
/// Overlay通过Navigator管理，所以相当于一个路由，类似于
/// 安卓原生的Window(OverlayEntry)，WindowManager(Overlay)
///
///

enum ToastGravity { TOP, CENTER, BOTTOM }

void showToast({BuildContext context, String message}) {
  Toast.make(context: context, message: message).show();
}

class Toast {
  static const Duration SHORT_DURATION = const Duration(seconds: 2);
  static const Duration LONG_DURATION = const Duration(seconds: 3);

  BuildContext _context;

  String _message;

  set message(String value) => _message = value;

  Duration _duration = SHORT_DURATION;

  set duration(Duration value) => _duration = value;

  Widget _child;

  set child(Widget value) => _child = value;

  double _position;

  bool _isShow = false;

  OverlayEntry _overlayEntry;

  set gravity(ToastGravity gravity) {
    double result = 0;
    switch (gravity) {
      case ToastGravity.TOP:
        result = MediaQueryData.fromWindow(window).size.height / 4;
        break;
      case ToastGravity.CENTER:
        result = MediaQueryData.fromWindow(window).size.height / 2;
        break;
      case ToastGravity.BOTTOM:
      default:
        result = MediaQueryData.fromWindow(window).size.height * 3 / 4;
    }
    _position = result;
  }

  Toast({@required BuildContext context}) {
    this._context = context;
  }

  static make({
    BuildContext context,
    String message,
    Duration duration,
    Widget child,
    ToastGravity gravity,
  }) {
    assert(context != null);
    return Toast(context: context)
      ..message = message
      ..duration = duration ?? SHORT_DURATION
      ..gravity = gravity ?? ToastGravity.CENTER
      ..child = child;
  }

  void show() {
    if (_overlayEntry != null) {
      dismiss();
    }
    _overlayEntry = OverlayEntry(builder: (ctx) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: _child ?? _buildToastWidget(),
            top: _position ??
                (MediaQueryData.fromWindow(window).size.height * 3 / 4),
          ),
        ],
      );
    });
    Overlay.of(_context)?.insert(_overlayEntry);
    _isShow = true;
    Future.delayed(_duration).then((value) => dismiss());
  }

  void dismiss() {
    if (!_isShow) {
      return;
    }
    _isShow = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildToastWidget() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 100,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _message ?? '',
        ),
      ),
    );
  }
}
