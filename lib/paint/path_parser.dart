import 'dart:math' as Math;
import 'dart:ui';
import 'package:flutter/material.dart';

const _LOGTAG = 'PathParser';

class PathParser {
  factory PathParser._() => null;

  static List<double> copyOfRange(List<double> original, int start, int end) {
    if (start > end) throw ArgumentError();
    int originalLength = original.length;
    if (start < 0 || start > originalLength) throw Exception('IndexOutOfBounds');
    int resultLength = end - start;
    int copyLength = Math.min(resultLength, originalLength - start);
    return List()..addAll(original.take(copyLength));
  }

  static Path createPathFromPathData(String pathData) {
    Path path = new Path();
    List<PathDataNode> nodes = createNodesFromPathData(pathData);
    if (nodes != null) {
      try {
        PathDataNode.nodesToPath(nodes, path);
      } on Exception catch (e) {
        throw Exception("Error in parsing $pathData, $e");
      }
      return path;
    }
    return null;
  }

  static List<PathDataNode> createNodesFromPathData(String pathData) {
    if (pathData == null) return null;
    int start = 0;
    int end = 1;

    List<PathDataNode> list = List<PathDataNode>();
    while (end < pathData.length) {
      end = nextStart(pathData, end);
      String s = pathData.substring(start, end).trim();
      if (s.length > 0) {
        List<double> val = _getDoubles(s);
        _addNode(list, String.fromCharCode(s.codeUnitAt(0)), val);
      }

      start = end;
      end++;
    }
    if ((end - start) == 1 && start < pathData.length) {
      _addNode(list, String.fromCharCode(pathData.codeUnitAt(start)), [0]);
    }
    var result = List<PathDataNode>();
    list.forEach((element) => result.add(PathDataNode.fromOther(element)));
    return result;
  }

  static List<PathDataNode> deepCopyNodes(List<PathDataNode> source) {
    if (source == null) return null;
    List<PathDataNode> copy = List<PathDataNode>();
    for (int i = 0; i < source.length; i++) copy[i] = PathDataNode.fromOther(source[i]);
    return copy;
  }

  static bool canMorph(List<PathDataNode> nodesFrom, List<PathDataNode> nodesTo) {
    if (nodesFrom == null || nodesTo == null) return false;
    if (nodesFrom.length != nodesTo.length) return false;
    for (int i = 0; i < nodesFrom.length; i++) {
      if (nodesFrom[i].mType != nodesTo[i].mType || nodesFrom[i].mParams.length != nodesTo[i].mParams.length) {
        return false;
      }
    }
    return true;
  }

  static void updateNodes(List<PathDataNode> target, List<PathDataNode> source) {
    for (int i = 0; i < source.length; i++) {
      target[i].mType = source[i].mType;
      for (int j = 0; j < source[i].mParams.length; j++) {
        target[i].mParams[j] = source[i].mParams[j];
      }
    }
  }

  static int nextStart(String s, int end) {
    String c;

    while (end < s.length) {
      int code = s.codeUnitAt(end);
      c = String.fromCharCode(code);
      if ((((code - 'A'.codeUnitAt(0)) * (code - 'Z'.codeUnitAt(0)) <= 0) || ((code - 'a'.codeUnitAt(0)) * (code - 'z'.codeUnitAt(0)) <= 0)) && c != 'e' && c != 'E') {
        return end;
      }
      end++;
    }
    return end;
  }

  static void _addNode(List<PathDataNode> list, String cmd, List<double> val) => list.add(new PathDataNode(cmd, val));

  static List<double> _getDoubles(String s) {
    if (['z', 'Z'].contains(String.fromCharCode(s.codeUnitAt(0)))) return [0];
    try {
      List<double> results = List(s.length);
      int count = 0;
      int startPosition = 1;
      int endPosition = 0;

      _ExtractDoubleResult result = _ExtractDoubleResult();
      int totalLength = s.length;

      // The startPosition should always be the first character of the
      // current number, and endPosition is the character after the current
      // number.
      while (startPosition < totalLength) {
        _extract(s, startPosition, result);
        endPosition = result.mEndPosition;

        if (startPosition < endPosition) results[count++] = double.parse(s.substring(startPosition, endPosition));

        if (result.mEndWithNegOrDot)
          startPosition = endPosition;
        else
          startPosition = endPosition + 1;
      }
      return copyOfRange(results, 0, count);
    } on Exception catch (e) {
      throw Exception("error in parsing \" $s \" $e");
    }
  }

  static void _extract(String s, int start, _ExtractDoubleResult result) {
    int currentIndex = start;
    bool foundSeparator = false;
    result.mEndWithNegOrDot = false;
    bool secondDot = false;
    bool isExponential = false;
    for (; currentIndex < s.length; currentIndex++) {
      bool isPrevExponential = isExponential;
      isExponential = false;
      String currentChar = String.fromCharCode(s.codeUnitAt(currentIndex));
      switch (currentChar) {
        case ' ':
        case ',':
          foundSeparator = true;
          break;
        case '-':
          if (currentIndex != start && !isPrevExponential) {
            foundSeparator = true;
            result.mEndWithNegOrDot = true;
          }
          break;
        case '.':
          if (!secondDot) {
            secondDot = true;
          } else {
            foundSeparator = true;
            result.mEndWithNegOrDot = true;
          }
          break;
        case 'e':
        case 'E':
          isExponential = true;
          break;
      }
      if (foundSeparator) break;
    }
    result.mEndPosition = currentIndex;
  }

  static bool interpolatePathDataNodes(List<PathDataNode> target, List<PathDataNode> from, List<PathDataNode> to, double fraction) {
    if (target == null || from == null || to == null) throw Exception("The nodes to be interpolated and resulting nodes cannot be null");

    if (target.length != from.length || from.length != to.length) throw Exception("The nodes to be interpolated and resulting nodes must have the same length");

    if (!canMorph(from, to)) return false;

    for (int i = 0; i < target.length; i++) target[i].interpolatePathDataNode(from[i], to[i], fraction);
    return true;
  }
}

class _ExtractDoubleResult {
  int mEndPosition;
  bool mEndWithNegOrDot;

  _ExtractDoubleResult({this.mEndPosition, this.mEndWithNegOrDot});
}

class PathDataNode {
  String mType;

  List<double> mParams;

  PathDataNode(String type, List<double> params) {
    this.mType = type;
    this.mParams = params;
  }

  PathDataNode.fromOther(PathDataNode n) {
    mType = n.mType;
    mParams = PathParser.copyOfRange(n.mParams, 0, n.mParams.length);
  }

  static void nodesToPath(List<PathDataNode> node, Path path) {
    List<double> current = List(6);
    String previousCommand = 'm';
    for (int i = 0; i < node.length; i++) {
      addCommand(path, current, previousCommand, node[i].mType, node[i].mParams);
      previousCommand = node[i].mType;
    }
  }

  void interpolatePathDataNode(PathDataNode nodeFrom, PathDataNode nodeTo, double fraction) {
    mType = nodeFrom.mType;
    for (int i = 0; i < nodeFrom.mParams.length; i++) mParams[i] = nodeFrom.mParams[i] * (1 - fraction) + nodeTo.mParams[i] * fraction;
  }

  static void addCommand(Path path, List<double> current, String previousCmd, String cmd, List<double> val) {
    int incr = 2;
    double currentX = current[0];
    double currentY = current[1];
    double ctrlPointX = current[2];
    double ctrlPointY = current[3];
    double currentSegmentStartX = current[4];
    double currentSegmentStartY = current[5];
    double reflectiveCtrlPointX;
    double reflectiveCtrlPointY;

    switch (cmd) {
      case 'z':
      case 'Z':
        path.close();
        currentX = currentSegmentStartX;
        currentY = currentSegmentStartY;
        ctrlPointX = currentSegmentStartX;
        ctrlPointY = currentSegmentStartY;
        path.moveTo(currentX, currentY);
        break;
      case 'm':
      case 'M':
      case 'l':
      case 'L':
      case 't':
      case 'T':
        incr = 2;
        break;
      case 'h':
      case 'H':
      case 'v':
      case 'V':
        incr = 1;
        break;
      case 'c':
      case 'C':
        incr = 6;
        break;
      case 's':
      case 'S':
      case 'q':
      case 'Q':
        incr = 4;
        break;
      case 'a':
      case 'A':
        incr = 7;
        break;
    }

    for (int k = 0; k < val.length; k += incr) {
      switch (cmd) {
        case 'm': // moveto - Start a new sub-path (relative)
          currentX += val[k + 0];
          currentY += val[k + 1];
          if (k > 0) {
            // According to the spec, if a moveto is followed by multiple
            // pairs of coordinates, the subsequent pairs are treated as
            // implicit lineto commands.
            path.relativeLineTo(val[k + 0], val[k + 1]);
          } else {
            path.relativeMoveTo(val[k + 0], val[k + 1]);
            currentSegmentStartX = currentX;
            currentSegmentStartY = currentY;
          }
          break;
        case 'M': // moveto - Start a new sub-path
          currentX = val[k + 0];
          currentY = val[k + 1];
          if (k > 0) {
            // According to the spec, if a moveto is followed by multiple
            // pairs of coordinates, the subsequent pairs are treated as
            // implicit lineto commands.
            path.lineTo(val[k + 0], val[k + 1]);
          } else {
            path.moveTo(val[k + 0], val[k + 1]);
            currentSegmentStartX = currentX;
            currentSegmentStartY = currentY;
          }
          break;
        case 'l': // lineto - Draw a line from the current point (relative)
          path.relativeLineTo(val[k + 0], val[k + 1]);
          currentX += val[k + 0];
          currentY += val[k + 1];
          break;
        case 'L': // lineto - Draw a line from the current point
          path.lineTo(val[k + 0], val[k + 1]);
          currentX = val[k + 0];
          currentY = val[k + 1];
          break;
        case 'h': // horizontal lineto - Draws a horizontal line (relative)
          path.relativeLineTo(val[k + 0], 0);
          currentX += val[k + 0];
          break;
        case 'H': // horizontal lineto - Draws a horizontal line
          path.lineTo(val[k + 0], currentY);
          currentX = val[k + 0];
          break;
        case 'v': // vertical lineto - Draws a vertical line from the current point (r)
          path.relativeLineTo(0, val[k + 0]);
          currentY += val[k + 0];
          break;
        case 'V': // vertical lineto - Draws a vertical line from the current point
          path.lineTo(currentX, val[k + 0]);
          currentY = val[k + 0];
          break;
        case 'c': // curveto - Draws a cubic Bézier curve (relative)
          path.relativeCubicTo(val[k + 0], val[k + 1], val[k + 2], val[k + 3], val[k + 4], val[k + 5]);

          ctrlPointX = currentX + val[k + 2];
          ctrlPointY = currentY + val[k + 3];
          currentX += val[k + 4];
          currentY += val[k + 5];

          break;
        case 'C': // curveto - Draws a cubic Bézier curve
          path.cubicTo(val[k + 0], val[k + 1], val[k + 2], val[k + 3], val[k + 4], val[k + 5]);
          currentX = val[k + 4];
          currentY = val[k + 5];
          ctrlPointX = val[k + 2];
          ctrlPointY = val[k + 3];
          break;
        case 's': // smooth curveto - Draws a cubic Bézier curve (reflective cp)
          reflectiveCtrlPointX = 0;
          reflectiveCtrlPointY = 0;
          if (previousCmd == 'c' || previousCmd == 's' || previousCmd == 'C' || previousCmd == 'S') {
            reflectiveCtrlPointX = currentX - ctrlPointX;
            reflectiveCtrlPointY = currentY - ctrlPointY;
          }
          path.relativeCubicTo(reflectiveCtrlPointX, reflectiveCtrlPointY, val[k + 0], val[k + 1], val[k + 2], val[k + 3]);

          ctrlPointX = currentX + val[k + 0];
          ctrlPointY = currentY + val[k + 1];
          currentX += val[k + 2];
          currentY += val[k + 3];
          break;
        case 'S': // shorthand/smooth curveto Draws a cubic Bézier curve(reflective cp)
          reflectiveCtrlPointX = currentX;
          reflectiveCtrlPointY = currentY;
          if (previousCmd == 'c' || previousCmd == 's' || previousCmd == 'C' || previousCmd == 'S') {
            reflectiveCtrlPointX = 2 * currentX - ctrlPointX;
            reflectiveCtrlPointY = 2 * currentY - ctrlPointY;
          }
          path.cubicTo(reflectiveCtrlPointX, reflectiveCtrlPointY, val[k + 0], val[k + 1], val[k + 2], val[k + 3]);
          ctrlPointX = val[k + 0];
          ctrlPointY = val[k + 1];
          currentX = val[k + 2];
          currentY = val[k + 3];
          break;
        case 'q': // Draws a quadratic Bézier (relative)
          path.relativeQuadraticBezierTo(val[k + 0], val[k + 1], val[k + 2], val[k + 3]);
          ctrlPointX = currentX + val[k + 0];
          ctrlPointY = currentY + val[k + 1];
          currentX += val[k + 2];
          currentY += val[k + 3];
          break;
        case 'Q': // Draws a quadratic Bézier
          path.quadraticBezierTo(val[k + 0], val[k + 1], val[k + 2], val[k + 3]);
          ctrlPointX = val[k + 0];
          ctrlPointY = val[k + 1];
          currentX = val[k + 2];
          currentY = val[k + 3];
          break;
        case 't': // Draws a quadratic Bézier curve(reflective control point)(relative)
          reflectiveCtrlPointX = 0;
          reflectiveCtrlPointY = 0;
          if (previousCmd == 'q' || previousCmd == 't' || previousCmd == 'Q' || previousCmd == 'T') {
            reflectiveCtrlPointX = currentX - ctrlPointX;
            reflectiveCtrlPointY = currentY - ctrlPointY;
          }
          path.relativeQuadraticBezierTo(reflectiveCtrlPointX, reflectiveCtrlPointY, val[k + 0], val[k + 1]);
          ctrlPointX = currentX + reflectiveCtrlPointX;
          ctrlPointY = currentY + reflectiveCtrlPointY;
          currentX += val[k + 0];
          currentY += val[k + 1];
          break;
        case 'T': // Draws a quadratic Bézier curve (reflective control point)
          reflectiveCtrlPointX = currentX;
          reflectiveCtrlPointY = currentY;
          if (previousCmd == 'q' || previousCmd == 't' || previousCmd == 'Q' || previousCmd == 'T') {
            reflectiveCtrlPointX = 2 * currentX - ctrlPointX;
            reflectiveCtrlPointY = 2 * currentY - ctrlPointY;
          }
          path.quadraticBezierTo(reflectiveCtrlPointX, reflectiveCtrlPointY, val[k + 0], val[k + 1]);
          ctrlPointX = reflectiveCtrlPointX;
          ctrlPointY = reflectiveCtrlPointY;
          currentX = val[k + 0];
          currentY = val[k + 1];
          break;
        case 'a': // Draws an elliptical arc
          // (rx ry x-axis-rotation large-arc-flag sweep-flag x y)
          drawArc(path, currentX, currentY, val[k + 5] + currentX, val[k + 6] + currentY, val[k + 0], val[k + 1], val[k + 2], val[k + 3] != 0, val[k + 4] != 0);
          currentX += val[k + 5];
          currentY += val[k + 6];
          ctrlPointX = currentX;
          ctrlPointY = currentY;
          break;
        case 'A': // Draws an elliptical arc
          drawArc(path, currentX, currentY, val[k + 5], val[k + 6], val[k + 0], val[k + 1], val[k + 2], val[k + 3] != 0, val[k + 4] != 0);
          currentX = val[k + 5];
          currentY = val[k + 6];
          ctrlPointX = currentX;
          ctrlPointY = currentY;
          break;
      }
      previousCmd = cmd;
    }
    current[0] = currentX;
    current[1] = currentY;
    current[2] = ctrlPointX;
    current[3] = ctrlPointY;
    current[4] = currentSegmentStartX;
    current[5] = currentSegmentStartY;
  }

  static void drawArc(Path p, double x0, double y0, double x1, double y1, double a, double b, double theta, bool isMoreThanHalf, bool isPositiveArc) {
    /* Convert rotation angle from degrees to radians */
    double thetaD = theta / 180.0 * Math.pi;
    /* Pre-compute rotation matrix entries */
    double cosTheta = Math.cos(thetaD);
    double sinTheta = Math.sin(thetaD);
    /* Transform (x0, y0) and (x1, y1) into unit space */
    /* using (inverse) rotation, followed by (inverse) scale */
    double x0p = (x0 * cosTheta + y0 * sinTheta) / a;
    double y0p = (-x0 * sinTheta + y0 * cosTheta) / b;
    double x1p = (x1 * cosTheta + y1 * sinTheta) / a;
    double y1p = (-x1 * sinTheta + y1 * cosTheta) / b;

    /* Compute differences and averages */
    double dx = x0p - x1p;
    double dy = y0p - y1p;
    double xm = (x0p + x1p) / 2;
    double ym = (y0p + y1p) / 2;
    /* Solve for intersecting unit circles */
    double dsq = dx * dx + dy * dy;
    if (dsq == 0.0) {
      debugPrint('$_LOGTAG: Points are coincident');
      return; /* Points are coincident */
    }
    double disc = 1.0 / dsq - 1.0 / 4.0;
    if (disc < 0.0) {
      debugPrint('$_LOGTAG: Points are too far apart $dsq');
      double adjust = Math.sqrt(dsq) / 1.99999;
      drawArc(p, x0, y0, x1, y1, a * adjust, b * adjust, theta, isMoreThanHalf, isPositiveArc);
      return; /* Points are too far apart */
    }
    double s = Math.sqrt(disc);
    double sdx = s * dx;
    double sdy = s * dy;
    double cx;
    double cy;
    if (isMoreThanHalf == isPositiveArc) {
      cx = xm - sdy;
      cy = ym + sdx;
    } else {
      cx = xm + sdy;
      cy = ym - sdx;
    }

    double eta0 = Math.atan2((y0p - cy), (x0p - cx));

    double eta1 = Math.atan2((y1p - cy), (x1p - cx));

    double sweep = (eta1 - eta0);
    if (isPositiveArc != (sweep >= 0)) {
      if (sweep > 0) {
        sweep -= 2 * Math.pi;
      } else {
        sweep += 2 * Math.pi;
      }
    }

    cx *= a;
    cy *= b;
    double tcx = cx;
    cx = cx * cosTheta - cy * sinTheta;
    cy = tcx * sinTheta + cy * cosTheta;

    arcToBezier(p, cx, cy, a, b, x0, y0, thetaD, eta0, sweep);
  }

  static void arcToBezier(Path p, double cx, double cy, double a, double b, double e1x, double e1y, double theta, double start, double sweep) {
    // Taken from equations at: http://spaceroots.org/documents/ellipse/node8.html
    // and http://www.spaceroots.org/documents/ellipse/node22.html

    // Maximum of 45 degrees per cubic Bezier segment
    int numSegments = (sweep * 4 / Math.pi).abs().ceil();

    double eta1 = start;
    double cosTheta = Math.cos(theta);
    double sinTheta = Math.sin(theta);
    double cosEta1 = Math.cos(eta1);
    double sinEta1 = Math.sin(eta1);
    double ep1x = (-a * cosTheta * sinEta1) - (b * sinTheta * cosEta1);
    double ep1y = (-a * sinTheta * sinEta1) + (b * cosTheta * cosEta1);

    double anglePerSegment = sweep / numSegments;
    for (int i = 0; i < numSegments; i++) {
      double eta2 = eta1 + anglePerSegment;
      double sinEta2 = Math.sin(eta2);
      double cosEta2 = Math.cos(eta2);
      double e2x = cx + (a * cosTheta * cosEta2) - (b * sinTheta * sinEta2);
      double e2y = cy + (a * sinTheta * cosEta2) + (b * cosTheta * sinEta2);
      double ep2x = -a * cosTheta * sinEta2 - b * sinTheta * cosEta2;
      double ep2y = -a * sinTheta * sinEta2 + b * cosTheta * cosEta2;
      double tanDiff2 = Math.tan((eta2 - eta1) / 2);
      double alpha = Math.sin(eta2 - eta1) * (Math.sqrt(4 + (3 * tanDiff2 * tanDiff2)) - 1) / 3;
      double q1x = e1x + alpha * ep1x;
      double q1y = e1y + alpha * ep1y;
      double q2x = e2x - alpha * ep2x;
      double q2y = e2y - alpha * ep2y;

      // Adding this no-op call to workaround a proguard related issue.
      p.relativeLineTo(0, 0);

      p.cubicTo(q1x, q1y, q2x, q2y, e2x, e2y);
      eta1 = eta2;
      e1x = e2x;
      e1y = e2y;
      ep1x = ep2x;
      ep1y = ep2y;
    }
  }
}
