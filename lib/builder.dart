import 'dart:async';

import 'package:build/build.dart';

import 'src/parser.dart';
import 'src/generator.dart';
import 'src/scanner.dart';

Builder create(BuilderOptions _) => FfiBuilder();

class FfiBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final content = await buildStep.readAsString(buildStep.inputId);

    final scanner = Scanner(content, uri: buildStep.inputId.uri)..scan();

    final file = Parser(scanner.tokens).parseFile();
    final output = generateForFile(file);

    final outputId = buildStep.inputId.changeExtension('.dart');
    await buildStep.writeAsString(outputId, output);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.ffi.txt': ['.ffi.dart'],
      };
}
