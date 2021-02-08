import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:think_flutter/paint/xml_utils.dart';

class DrawBoard extends StatefulWidget {
  @override
  _DrawBoardState createState() => _DrawBoardState();
}

class _DrawBoardState extends State<DrawBoard> {
  /// 手指绘制的点
  List<Offset> _points = <Offset>[];

  /// 形状
  List<DrawStroke> shapePaths;

  ValueNotifier<List<Offset>> _touchPoints = ValueNotifier(<Offset>[]);

  List<LetterPoint> matchOrderList = [];

  List<LetterPoint> list = <LetterPoint>[
    LetterPoint(1, Offset(55, 50)),
    LetterPoint(2, Offset(40, 80)),
    LetterPoint(3, Offset(40, 120)),
    LetterPoint(4, Offset(55, 150)),
    LetterPoint(5, Offset(85, 170)),
    LetterPoint(6, Offset(125, 165)),
    LetterPoint(7, Offset(155, 135)),
    LetterPoint(8, Offset(160, 100)),
    LetterPoint(9, Offset(150, 60)),
    LetterPoint(10, Offset(130, 40)),
    LetterPoint(11, Offset(90, 30)),
  ];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    init();
    super.initState();
  }

  void init() async {
    String text = await rootBundle.loadString("assets/o.svg");
    shapePaths = XmlUtils.parsePath(text, Size(200, 200));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(color: Colors.blueGrey),
      alignment: Alignment.center,
      child: GestureDetector(
        onPanStart: onPanStartCallback,
        onPanUpdate: onPanUpdateCallback,
        onPanEnd: onPanEndCallback,
        child: ValueListenableBuilder(
          valueListenable: _touchPoints,
          builder: (ctx, touchPoints, child) => CustomPaint(
            size: Size(200, 200),
            painter: new DrawBoardPainter(touchPoints, shapePaths, list, matchOrderList),
          ),
        ),
      ),
    );
  }

  void onPanStartCallback(DragStartDetails details) {
    print("start");
    for (var point in list) {
      point.isPass = false;
    }
  }

  void onPanUpdateCallback(DragUpdateDetails details) {
    _touchPoints.value = List.from(Set.from(_touchPoints.value)..add(details.localPosition));
  }

  void onPanEndCallback(DragEndDetails details) {
    print("onPanEndCallback");
    bool allPass = true;

    if (matchOrderList.length != list.length) {
      allPass = false;
    } else {
      for (int i = 0; i < list.length; i++) {
        allPass &= matchOrderList[i] == list[i];
      }
    }
    if (allPass) {
      print("对了");
    } else {
      print("错了 matchOrderPath ==> $matchOrderList");
    }
    _touchPoints.value = <Offset>[];
  }
}

class DrawBoardPainter extends CustomPainter {
  static const Color DEFAULT_DRAW_COLOR = Colors.orange;

  static const double DEFAULT_DRAW_STROKE_WIDTH = 20;

  /// 绘制手势的画笔
  Paint _paint;

  /// 辅助线画笔
  Paint _auxiliaryPaint;

  /// 绘制手势的颜色
  Color drawColor;

  /// 绘制笔画大小
  double drawStrokeWidth;

  /// svg路径bean对象
  final List<DrawStroke> shapePaths;

  /// 手指触摸过得点
  List<Offset> drawPointed;

  /// 正确的绘制点
  final List<LetterPoint> list;

  /// 触摸点与匹配点匹配后，将该点加入到此列表中
  final List<LetterPoint> matchOrderList;

  DrawBoardPainter(
    this.drawPointed,
    this.shapePaths,
    this.list,
    this.matchOrderList, {
    this.drawColor,
    this.drawStrokeWidth,
  }) {
    this.drawStrokeWidth = this.drawStrokeWidth ?? DEFAULT_DRAW_STROKE_WIDTH;
    _paint = Paint()
      ..color = this.drawColor ?? DEFAULT_DRAW_COLOR
      ..strokeCap = StrokeCap.round
      ..strokeWidth = this.drawStrokeWidth;
    _auxiliaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    /// 画布大小限制
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (shapePaths != null) {
      /// 绘制字母形状
      for (DrawStroke drawStroke in shapePaths) {
        drawStroke.drawPath(canvas, size);
      }
    }
    Path path = Path();
    path.addPolygon(list.map((e) => e.pointOffset).toList(), false);
    canvas.drawPath(path, _auxiliaryPaint);

    canvas.drawCircle(Offset(55, 50), 5, _paint);
    canvas.drawCircle(Offset(40, 80), 5, _paint);
    canvas.drawCircle(Offset(40, 120), 5, _paint);
    canvas.drawCircle(Offset(55, 150), 5, _paint);
    canvas.drawCircle(Offset(85, 170), 5, _paint);
    canvas.drawCircle(Offset(125, 165), 5, _paint);
    canvas.drawCircle(Offset(155, 135), 5, _paint);
    canvas.drawCircle(Offset(160, 100), 5, _paint);
    canvas.drawCircle(Offset(150, 60), 5, _paint);
    canvas.drawCircle(Offset(130, 40), 5, _paint);
    canvas.drawCircle(Offset(90, 30), 5, _paint);
    for (int i = 0; i < drawPointed.length - 1; i++) {
      if (drawPointed[i] != null && drawPointed[i + 1] != null) {
        if (shapePaths != null) {
          /// 绘制字母形状
          for (DrawStroke drawStroke in shapePaths) {
            if (drawStroke.drawStrokePath.contains(drawPointed[i]) && drawStroke.drawStrokePath.contains(drawPointed[i + 1])) {
              handleMatch(i);
              canvas.drawLine(drawPointed[i], drawPointed[i + 1], _paint);
            }
          }
        }
      }
    }

    canvas.restore();
  }

  void handleMatch(int i) {
    for (var point in list) {
      if (!point.isPass) {
        bool isMatch = Rect.fromCircle(center: drawPointed[i], radius: drawStrokeWidth).contains(point.pointOffset);
        if (isMatch) {
          point.isPass = true;
          matchOrderList.add(point);
          break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 字母符号位置的打点
class LetterPoint {
  /// 顺序
  int order;

  /// 打点位置
  Offset pointOffset;

  /// 是否通过此点
  bool isPass;

  LetterPoint(this.order, this.pointOffset, {this.isPass = false});

  @override
  bool operator ==(Object other) => identical(this, other) || other is LetterPoint && runtimeType == other.runtimeType && order == other.order && pointOffset == other.pointOffset;

  @override
  int get hashCode => order.hashCode ^ pointOffset.hashCode;

  @override
  String toString() {
    return 'LetterPoint{order: $order, pointOffset: $pointOffset, isPass: $isPass}';
  }
}

class DrawStroke {
  static const Color DEFAULT_COLOR = Colors.black38;

  /// 绘制路径
  Path drawStrokePath;

  /// 填充颜色
  Color fillColor;

  /// 绘制画笔
  Paint _paint = Paint();

  DrawStroke(this.drawStrokePath, this.fillColor) {
    _paint.color = DEFAULT_COLOR;
  }

  void drawPath(
    Canvas canvas,
    Size viewSize, {
    bool isFull = false,
  }) {
    if (isFull) {
      _paint..style = PaintingStyle.fill;
    } else {
      _paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
    }
    // canvas.clipPath(drawStrokePath);
    canvas.drawPath(drawStrokePath, _paint);
  }
}
