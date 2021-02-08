import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'path_parser.dart';
import 'draw_board.dart';

class XmlUtils {
  static const PATH_NAME = "path";

  /// 路径信息属性
  static const PATH_ATTR_D = "d";

  ///
  static const PATH_ATTR_P_ID = "";

  /// 填充颜色属性
  static const PATH_ATTR_FILL = "fill";

  static List<DrawStroke> parsePath(String xmlContent, Size drawBoxSize) {
    List<DrawStroke> list = [];

    final document = XmlDocument.parse(xmlContent);

    var svgElement = document.findElements("svg");
    var first = svgElement.first;
    double scaleX = 1;
    double scaleY = 1;
    if (first != null) {
      var attribute = first.getAttribute("viewBox").split(" ");
      Size size = Size(double.parse(attribute[2]), double.parse(attribute[3]));
      scaleX = drawBoxSize.width / size.width;
      scaleY = drawBoxSize.height / size.height;
    }

    /// 获取所有path
    var pathElements = document.findAllElements(PATH_NAME);

    for (var pathElement in pathElements) {
      var pathData = pathElement.getAttribute(PATH_ATTR_D);

      var fillColor = pathElement.getAttribute(PATH_ATTR_FILL);
      // 解析出path
      Path path = PathParser.createPathFromPathData(pathData);

      List<PathDataNode> createNodesFromPathData = PathParser.createNodesFromPathData(pathData);
      Path scalePath;
      try {
        List<PathDataNode> newData = [];
        for (PathDataNode node in createNodesFromPathData) {
          newData.add(PathDataNode(
              node.mType,
              node.mParams.map((param) {
                return param * scaleY;
              }).toList()));
        }
        scalePath = Path();
        PathDataNode.nodesToPath(newData, scalePath);
      } on Exception catch (e) {
        throw Exception("Error in parsing $pathData, $e");
      }

      list.add(DrawStroke(scalePath ?? path, getColor(fillColor)));
    }
    return list;
  }

  static Color getColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
