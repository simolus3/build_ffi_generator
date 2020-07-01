import 'package:dart_style/dart_style.dart';

import 'elements.dart';

final _dartfmt = DartFormatter();

String generateForFile(FfiFile file) {
  final into = StringBuffer()
    ..writeln('// auto-generated, DO NOT EDIT')
    ..writeln('// Instead, run pub run build_runner build')
    ..writeln()
    ..writeln("import 'dart:ffi';");

  _writeStructs(file, into);
  _writeTypedefs(file, into);
  _writeBindingsClass(file, into);

  return _dartfmt.format(into.toString());
}

void _writeStructs(FfiFile file, StringBuffer into) {
  for (final type in file.types) {
    if (type.definition is StructType) {
      final name = type.name;
      final definition = type.definition;

      into.writeln('class $name extends Struct {');
      if (definition is Struct) {
        for (final entry in definition.entries) {
          if (entry.type is! PointerType) {
            // Non-pointer types need an annotation
            into.writeln('@${entry.type.nativeTypeName}()');
          }

          into
            ..write(entry.type.dartName)
            ..write(' ')
            ..write(entry.name)
            ..writeln(';');
        }
      }
      into.writeln('}');
    }
  }
}

void _writeTypedefs(FfiFile file, StringBuffer into) {
  for (final function in file.functions) {
    // Write native typedef
    into
      ..write('typedef ${function.nativeTypedefName} = ')
      ..write(function.returnType.nativeTypeName)
      ..write(' Function(');

    var first = true;
    for (final arg in function.arguments) {
      if (!first) {
        into.write(',');
      }

      into.write(arg.type.nativeTypeName);

      first = false;
    }

    into..writeln(');');

    // Write Dart typedef that can be called
    into
      ..write('typedef ${function.dartTypedefName} = ')
      ..write(function.returnType.dartName)
      ..write(' Function(');

    first = true;
    for (final arg in function.arguments) {
      if (!first) {
        into.write(',');
      }

      into..write(arg.type.dartName)..write(' ')..write(arg.name);

      first = false;
    }

    into..writeln(');');
  }
}

void _writeBindingsClass(FfiFile file, StringBuffer into) {
  into..writeln('class Bindings {');

  // Write fields to hold the functions
  for (final function in file.functions) {
    into.writeln('final ${function.dartTypedefName} ${function.name};');
  }

  // Write constructor
  into..writeln('Bindings(DynamicLibrary library): ');
  var first = true;

  for (final function in file.functions) {
    if (!first) {
      into..writeln(', ');
    }

    into
      ..writeln('${function.name} = library.lookupFunction')
      ..writeln('<${function.nativeTypedefName}, ${function.dartTypedefName}>')
      ..writeln("('${function.name}')");

    first = false;
  }

  into.writeln(';\n}');
}

extension on CType {
  String get nativeTypeName {
    if (this is SimpleCType) {
      final typedThis = this as SimpleCType;
      return typedThis.dartNativeType;
    } else if (this is NamedType) {
      final inner = (this as NamedType).type;
      if (inner is StructType) {
        return (this as NamedType).name;
      }
      return inner.nativeTypeName;
    } else if (this is PointerType) {
      return 'Pointer<${(this as PointerType).inner.nativeTypeName}>';
    }

    throw UnsupportedError('Not implemented: $runtimeType');
  }

  String get dartName {
    if (this is SimpleCType) {
      return (this as SimpleCType).dartType;
    }
    if (this is NamedType) {
      final inner = (this as NamedType).type;
      if (inner is! StructType) {
        return inner.dartName;
      }
    }

    return nativeTypeName;
  }
}

extension on CFunction {
  String get nativeTypedefName => '_${name}_native';
  String get dartTypedefName => '${name}_dart';
}
