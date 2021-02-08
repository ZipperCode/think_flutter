import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef ProgressCompleteCallback = void Function();

class AutoProgress extends StatefulWidget {
  /// 进度条宽度
  final double width;

  /// 进度条高度
  final double height;

  /// 进度颜色
  final Color progressColor;

  /// 未加载中的进度颜色
  final Color backgroundColor;

  /// 缓冲的进度颜色
  final Color bufferProgressColor;

  /// 边框颜色
  final Color borderProgressColor;

  /// 显示文本的颜色
  final Color textColor;

  /// 当前进度值
  final double progress = 0;

  /// 最大进度值
  final double maxProgress = 1;

  /// 内部显示的文字
  final String text;

  /// 进度的持续的时间
  final Duration duration;

  /// 圆角大小
  final Radius radius;

  /// 动画结束后回调
  final void Function() durationDone;

  AutoProgress({
    @required this.width,
    @required this.height,
    @required this.progressColor,
    @required this.backgroundColor,
    this.bufferProgressColor,
    this.borderProgressColor,
    this.textColor,
    this.text,
    this.duration = const Duration(seconds: 1),
    this.radius,
    this.durationDone,
  });

  @override
  _AutoProgressState createState() => _AutoProgressState();
}

class _AutoProgressState extends State<AutoProgress> with SingleTickerProviderStateMixin {
  /// 动画控制
  AnimationController _controller;

  /// 自动进度
  ValueNotifier<double> _progressNotifier;

  _AutoProgressState();

  @override
  void initState() {
    super.initState();
    _progressNotifier = ValueNotifier(0);
    _controller = new AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..addListener(() {
        _progressNotifier.value = _controller.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.durationDone?.call();
        }
      });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.dispose();
        widget.durationDone?.call();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: _progressNotifier,
              builder: _buildProgress,
            ),
            Text(
              widget.text ?? '',
              style: TextStyle(
                color: widget.textColor ?? Color(0xFFFFFFFF),
                fontSize: 25,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                height: 1.2,
              ),
              textScaleFactor: 1,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context, double progress, Widget child) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: ProgressPainter(
        widget.progressColor,
        widget.backgroundColor,
        widget.textColor,
        progress,
        widget.maxProgress,
        radius: widget.radius ?? Radius.circular(widget.height / 2),
      ),
    );
  }
}

class ProgressPainter extends CustomPainter {
  /// 进度的颜色
  final progressColor;

  /// 背景颜色
  final backgroundColor;

  /// 边框颜色
  final borderColor;

  /// 进度的画笔
  Paint progressPaint;

  /// 背景的画笔
  Paint backgroundPaint;

  /// 边框画笔
  Paint borderPaint;

  /// 进度值
  double progress;

  /// 最大进度值
  double maxProgress;

  /// 圆角大小
  Radius radius;

  ProgressPainter(
    this.progressColor,
    this.backgroundColor,
    this.borderColor,
    this.progress,
    this.maxProgress, {
    this.progressPaint,
    this.backgroundPaint,
    this.radius,
  }) {
    progressPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = progressColor;

    backgroundPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = backgroundColor;

    borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..color = borderColor ?? Color(0x00FFFFFF);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    canvas.save();

    /// 画背景
    RRect backgroundRRect = RRect.fromLTRBR(0, 0, width, height, radius);
    canvas.clipRRect(backgroundRRect);
    canvas.drawRRect(backgroundRRect, backgroundPaint);

    /// 画边框
    RRect borderRRect = RRect.fromLTRBR(0, 0, width, height, radius);
    canvas.drawRRect(borderRRect, borderPaint);

    /// 画进度
    double radio = this.progress / this.maxProgress;
    RRect progressRRect = RRect.fromLTRBAndCorners(0, 0, width * radio, height, topLeft: radius, bottomLeft: radius);
    canvas.drawRRect(progressRRect, progressPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
