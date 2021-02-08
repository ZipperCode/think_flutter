import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'test_generator.dart';

LibraryBuilder testBuilder(BuilderOptions options) => LibraryBuilder(TestGenerator());
