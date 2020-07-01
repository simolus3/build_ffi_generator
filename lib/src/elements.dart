abstract class Element {}

/// Interface for elements that define something, like a type or a function.
abstract class Definition implements Element {
  String get name;
}

class FfiFile extends Element {
  final List<Definition> definitions;

  Iterable<TypeDefinition> get types => definitions.whereType();
  Iterable<CFunction> get functions => definitions.whereType();

  FfiFile(this.definitions);
}

class TypeDefinition extends Element implements Definition {
  @override
  final String name;
  final CType definition;

  NamedType _introducedType;
  NamedType get introducedType {
    return _introducedType ??= NamedType(name, definition);
  }

  TypeDefinition(this.name, this.definition);
}

abstract class CType {}

abstract class SimpleCType implements CType {
  String get dartNativeType;
  String get dartType;
}

class PointerType implements CType {
  final bool isConst;
  final CType inner;

  PointerType(this.inner, {this.isConst = false});

  @override
  String toString() {
    return '*$inner';
  }
}

class NamedType implements CType {
  final String name;
  final CType type;

  NamedType(this.name, this.type);
}

abstract class StructType implements CType {}

class OpaqueStruct implements StructType {}

class Struct implements StructType {
  final List<StructEntry> entries;

  Struct(this.entries);
}

class StructEntry {
  final String name;
  final CType type;

  StructEntry(this.name, this.type);
}

class FloatType implements SimpleCType {
  const FloatType();

  @override
  String get dartNativeType => 'Float';
  @override
  String get dartType => 'double';
}

class DoubleType implements SimpleCType {
  const DoubleType();

  @override
  String get dartNativeType => 'Double';
  @override
  String get dartType => 'double';
}

class VoidType implements SimpleCType {
  const VoidType();

  @override
  String get dartNativeType => 'Void';
  @override
  String get dartType => 'void';
}

enum IntKind {
  int8,
  int16,
  int32,
  int64,
  uint8,
  uint16,
  uint32,
  uint64,
  int,
//  char,
}

class IntType implements SimpleCType {
  final IntKind kind;

  const IntType(this.kind);

  @override
  String get dartNativeType {
    switch (kind) {
      case IntKind.int8:
        return 'Int8';
      case IntKind.int16:
        return 'Int16';
      case IntKind.int32:
        return 'Int32';
      case IntKind.int64:
        return 'Int64';
      case IntKind.uint8:
        return 'Uint8';
      case IntKind.uint16:
        return 'Uint16';
      case IntKind.uint32:
        return 'Uint32';
      case IntKind.uint64:
        return 'Uint64';
      case IntKind.int:
        return 'IntPtr';
    }

    throw AssertionError('dead code');
  }

  @override
  String get dartType => 'int';
}

class CFunction implements Definition {
  final CType returnType;
  @override
  final String name;
  final List<Argument> arguments;

  CFunction(this.name, this.returnType, this.arguments);
}

class Argument {
  final String name;
  final CType type;

  Argument(this.name, this.type);
}
