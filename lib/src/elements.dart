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

class OpaqueStruct implements CType {}

class FloatType implements CType {
  const FloatType();
}

class DoubleType implements CType {
  const DoubleType();
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

class IntType implements CType {
  final IntKind kind;

  const IntType(this.kind);
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
