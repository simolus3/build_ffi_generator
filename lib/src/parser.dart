import 'package:meta/meta.dart';

import 'elements.dart';
import 'scanner.dart';

class Parser {
  final List<Token> tokens;
  int _offset = 0;

  final Map<String, NamedType> _scope = {};
  final List<ParsingError> _errors = [];

  Parser(this.tokens);

  Token get _previous => tokens[_offset - 1];
  Token get _peek => tokens[_offset];

  bool get _isAtEnd => _offset >= tokens.length;

  @alwaysThrows
  Null /*Never*/ _error(String message) {
    final error = ParsingError(message, _previous);
    _errors.add(error);
    throw error;
  }

  bool _check(TokenType type) {
    return !_isAtEnd && _peek.tokenType == type;
  }

  void _advance() {
    _offset++;
  }

  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }
    return false;
  }

  Token _consume(TokenType type) {
    if (_match(type)) {
      return _previous;
    }

    _error('Expected $type here');
  }

  String _consumeIdentifier() {
    if (_match(TokenType.identifier)) {
      return (_previous as Identifier).identifier;
    }

    if (_peek.isKeyword) {
      _error('Expected an identifier. Note: This is a reserved keyword, you '
          'can escape it in backticks.');
    }
    _error('Expected an identifier');
  }

  FfiFile parseFile() {
    final definitions = <Definition>[];
    while (!_isAtEnd && !_match(TokenType.eof)) {
      try {
        definitions.add(_definition());
      } on ParsingError {
        // Synchronize to the next semicolon, then try again
        while (!_isAtEnd && !_check(TokenType.semicolon)) {
          _advance();
        }

        _advance(); // Skip the semicolon, actually
      }
    }

    if (_errors.isNotEmpty) {
      throw CombinedParsingError(_errors);
    }

    return FfiFile(definitions);
  }

  Definition _definition() {
    if (_check(TokenType.type)) {
      return _typeDefinition();
    } else {
      return _function();
    }
  }

  TypeDefinition _typeDefinition() {
    _consume(TokenType.type);
    final name = _consumeIdentifier();

    if (_scope.containsKey(name)) {
      _error('Type with name $name already defined above.');
    }

    _consume(TokenType.equals);
    final type = _cType();
    _consume(TokenType.semicolon);

    final definition = TypeDefinition(name, type);
    _scope[name] = definition.introducedType;
    return definition;
  }

  CFunction _function() {
    final returnType = _cType();
    final name = _consumeIdentifier();

    _consume(TokenType.leftParen);
    final args = <Argument>[];
    if (!_match(TokenType.rightParen)) {
      do {
        final type = _cType();
        final name = _consumeIdentifier();

        args.add(Argument(name, type));
      } while (_match(TokenType.comma));
      _consume(TokenType.rightParen);
    }

    _consume(TokenType.semicolon);
    return CFunction(name, returnType, args);
  }

  CType _cType() => _pointer();

  CType _pointer() {
    var type = _primaryType();

    while (_match(TokenType.asterisk)) {
      type = PointerType(type);
    }
    return type;
  }

  CType _primaryType() {
    if (_match(TokenType.opaque)) {
      _consume(TokenType.struct);
      return OpaqueStruct();
    } else if (_check(TokenType.struct)) {
      return _struct();
    }

    final name = _consumeIdentifier();
    switch (name) {
      case 'int8':
        return const IntType(IntKind.int8);
      case 'int16':
        return const IntType(IntKind.int16);
      case 'int':
      case 'int32':
        return const IntType(IntKind.int32);
      case 'int64':
        return const IntType(IntKind.int64);
      case 'uint8':
        return const IntType(IntKind.uint8);
      case 'uint16':
        return const IntType(IntKind.uint16);
      case 'uint32':
        return const IntType(IntKind.uint32);
      case 'uint64':
        return const IntType(IntKind.uint64);
      case 'size_t':
        return const IntType(IntKind.int);
      case 'float':
        return const FloatType();
      case 'double':
        return const DoubleType();
      case 'void':
        return const VoidType();
//      case 'char':
//        return const IntType(IntKind.char);
      default:
        final type = _scope[name];
        if (type == null) {
          _error('Unknown type: $type');
        }
        return type;
    }
  }

  CType _struct() {
    _consume(TokenType.struct);
    _consume(TokenType.leftBrace);

    final entries = <StructEntry>[];
    do {
      final type = _cType();
      final name = _consumeIdentifier();

      entries.add(StructEntry(name, type));
      _consume(TokenType.semicolon);
    } while (!_check(TokenType.rightBrace));

    _consume(TokenType.rightBrace);
    return Struct(entries);
  }
}

class ParsingError implements Exception {
  final String message;
  final Token at;

  ParsingError(this.message, this.at);

  @override
  String toString() {
    return at.span.message(message);
  }
}

class CombinedParsingError implements Exception {
  final List<ParsingError> errors;

  CombinedParsingError(this.errors);

  @override
  String toString() {
    return errors.join('\n');
  }
}
