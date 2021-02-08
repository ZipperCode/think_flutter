import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

///
/// [className]  think_flutter
/// [author]     Administrator
/// [date]       2021/1/21
class CodeGenerator extends Generator {
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    print(library);
    print(library.runtimeType.toString());
    print(buildStep);
    print(buildStep.runtimeType.toString());

    return '''
    class AAA{
    }
    ''';
  }
}
