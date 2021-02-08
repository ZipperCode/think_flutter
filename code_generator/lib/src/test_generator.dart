import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'anno/test_meta_data.dart';

class TestGenerator extends GeneratorForAnnotation<TestMetaData> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return 'class CustomClass{}';
  }
}
