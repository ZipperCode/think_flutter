/// Support for doing something awesome.
///
/// More dartdocs go here.
library code_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/test_generator.dart';
import 'src/code_generator.dart';

export 'src/code_generator_base.dart';

LibraryBuilder testBuilder(BuilderOptions options) => LibraryBuilder(TestGenerator());

LibraryBuilder codeBuilder(BuilderOptions options) => LibraryBuilder(CodeGenerator());
