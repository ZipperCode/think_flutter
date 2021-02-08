import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/material.dart';

class DrawFlower extends ImplicitlyAnimatedWidget {
  final double width;

  final double height;

  @override
  _DrawFlowerState createState() => _DrawFlowerState();

  DrawFlower({
    Key key,
    this.width,
    this.height,
    Duration duration = const Duration(milliseconds: 1000),
    Curve curve = const Cubic(0, 0.35, 0.75, 1),
    VoidCallback onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);
}

class _DrawFlowerState extends ImplicitlyAnimatedWidgetState<DrawFlower> {
  Tween<double> _value;

  List<Flower> _flowers = [];

  Random _random = Random();

  List<String> resPaths = [
    "assets/images/bar_0.webp",
    "assets/images/bar_1.webp",
    "assets/images/bar_2.webp",
    "assets/images/bar_3.webp",
    "assets/images/bar_4.webp",
  ];

  @override
  void initState() {
    for (var i = 0; i < 150; i++) {
      _flowers.add(randomFlower());
    }
    super.initState();

    controller.addListener(() {
      // print("listener");
      setState(() {
        for (var fl in _flowers) {
          double t = animation.value;
          var bx = (1 - t) * (1 - t) * fl.startPoint.dx + 2 * t * (1 - t) * fl.bizerPoint.dx + t * t * fl.endPoint.dx;
          var by = (1 - t) * (1 - t) * fl.startPoint.dy + 2 * t * (1 - t) * fl.bizerPoint.dy + t * t * fl.endPoint.dy;
          fl.curX = bx;
          fl.curY = by;
          // print("flower = $fl");
        }
      });
    });
  }

  Flower randomFlower() {
    bool isLeft = _random.nextBool();

    double startX = 0;
    double startY = 0;

    double endX = 0;
    double endY = 0;

    if (isLeft) {
      startX = _random.nextDouble() * -widget.width * 0.4;
      startY = (_random.nextDouble() + 1) * widget.height * 0.4;
    } else {
      startX = widget.width + _random.nextDouble() * widget.width * 0.4;
      startY = (_random.nextDouble() + 1) * widget.height * 0.4;
    }

    endX = _random.nextDouble() * widget.width;
    endY = _random.nextDouble() * widget.height * 0.2 + _random.nextDouble() * widget.height * 0.7;

    double pointX = (startX + endX) / 2;
    double pointY = _random.nextDouble() * widget.width;

    Offset start = Offset(startX, startY);
    Offset point = Offset(pointX, pointY);
    Offset end = Offset(endX, endY);

    return Flower(
      20,
      20,
      startPoint: start,
      endPoint: end,
      bizerPoint: point,
      path: resPaths[_random.nextInt(resPaths.length)],
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(color: Colors.blueGrey),
        child: CustomPaint(
          painter: DrawFlowerPointer(_flowers),
        ),
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    print("forEachTween $_value");
    _value = visitor(
      _value,
      _random.nextDouble(),
      (dynamic value) => Tween<double>(begin: value),
    );
  }

  @override
  void didUpdateTweens() {
    super.didUpdateTweens();
    // print("didUpdateTweens");
    // _valueAnimation = animation..drive(_value);
    // print("_valueAnimation $_valueAnimation");
    // print("animation $animation");
  }
}

class DrawFlowerPointer extends CustomPainter {
  final List<Flower> _flowers;

  Paint _paint = Paint();

  Paint _dotPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  Paint _endDotPaint = Paint()
    ..color = Colors.lightBlue
    ..style = PaintingStyle.fill;

  DrawFlowerPointer(this._flowers);

  @override
  void paint(Canvas canvas, Size size) {
    for (var flower in _flowers) {
      if (flower != null && flower.image != null) {
        Rect imageRect = Rect.fromLTRB(0, 0, flower.width, flower.height);
        Rect dstRect = Rect.fromCenter(center: Offset(flower.curX, flower.curY), width: flower.width, height: flower.height);
        canvas.drawImageRect(flower.image, imageRect, dstRect, _paint);
        // canvas.drawCircle(flower.startPoint, 2, _dotPaint);
        // canvas.drawCircle(flower.bizerPoint, 2, _dotPaint);
        // canvas.drawCircle(flower.endPoint, 2, _endDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Flower {
  double width;
  double height;

  /// 开始位置
  Offset startPoint;

  /// 三阶贝塞尔中间点
  Offset bizerPoint;

  /// 结束位置
  Offset endPoint;

  /// 当前曲线上的点
  double curX;
  double curY;

  /// 封装的图片
  ui.Image image;

  String path;

  Flower(
    this.width,
    this.height, {
    this.startPoint,
    this.endPoint,
    this.bizerPoint,
    this.image,
    this.path,
  }) {
    this.curX = this.startPoint.dx;
    this.curY = this.startPoint.dy;
  }

  void load() async {
    ByteData byteData = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width.floor(),
      targetHeight: height.floor(),
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
  }

  @override
  String toString() {
    return 'Flower{width: $width, height: $height, startPoint: $startPoint, bizerPoint: $bizerPoint, endPoint: $endPoint, curX: $curX, curY: $curY, image: $image, path: $path}';
  }
}
