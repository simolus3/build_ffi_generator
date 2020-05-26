import 'dart:typed_data';

import 'package:charcode/charcode.dart';
import 'package:source_span/source_span.dart';

class Token {
  final FileSpan span;
  final TokenType tokenType;

  Token(this.span, this.tokenType);

  String get lexeme => span.text;
}

class Identifier extends Token {
  final bool wasEscaped;

  Identifier(FileSpan span, {this.wasEscaped = false})
      : super(span, TokenType.identifier);

  String get identifier {
    if (wasEscaped) {
      return lexeme.substring(1, lexeme.length - 1);
    } else {
      return lexeme;
    }
  }
}

enum TokenType {
  asterisk,
  comma,
  equals,
  identifier,
  leftParen,
  opaque,
  rightParen,
  semicolon,
  struct,
  type,
  eof,
}

const _keywords = {
  'type': TokenType.type,
  'opaque': TokenType.opaque,
  'struct': TokenType.struct,
};

class Scanner {
  final SourceFile input;
  final Uint16List _chars;

  /// Start offset of the current token in [_chars].
  int /*?*/ _startOffset;

  /// Next offset in [_chars].
  var _offset = 0;

  final List<ScanningError> _errors = [];
  final List<Token> tokens = [];

  Scanner._(this.input, this._chars);

  factory Scanner(String content, {Uri uri}) {
    final chars = Uint16List.fromList(content.runes.toList());
    final input = SourceFile.decoded(chars, url: uri);

    return Scanner._(input, chars);
  }

  bool get _isAtEnd => _offset >= _chars.length;

  FileSpan get _currentSpan => input.span(_startOffset, _offset);

  SourceLocation get _currentLocation {
    return input.location(_offset);
  }

  void _advance() => _offset++;

  int _nextChar() {
    _advance();
    return _chars[_offset - 1];
  }

  int _peek() {
    if (_isAtEnd) throw StateError('Reached end of source');
    return _chars[_offset];
  }

  void _add(TokenType type) {
    tokens.add(Token(_currentSpan, type));
  }

  void _errorUntilHere(String message) {
    _errors.add(ScanningError.span(message, _currentSpan));
  }

  void _errorHere(String message) {
    _errors.add(ScanningError.location(message, _currentLocation));
  }

  void scan() {
    while (!_isAtEnd) {
      _startOffset = _offset;
      _scanToken();
    }

    final endSpan = input.span(input.length);
    tokens.add(Token(endSpan, TokenType.eof));

    if (_errors.isNotEmpty) {
      throw ScanningException(_errors);
    }
  }

  void _scanToken() {
    final char = _nextChar();

    switch (char) {
      case $comma:
        _add(TokenType.comma);
        break;
      case $equal:
        _add(TokenType.equals);
        break;
      case $lparen:
        _add(TokenType.leftParen);
        break;
      case $rparen:
        _add(TokenType.rightParen);
        break;
      case $asterisk:
        _add(TokenType.asterisk);
        break;
      case $backquote:
        _escapedKeyword();
        break;
      case $semicolon:
        _add(TokenType.semicolon);
        break;
      case $hash:
        _lineComment();
        break;
      case $space:
      case $cr:
      case $tab:
      case $lf:
        // ignore whitespace
        break;
      default:
        if (char.startsIdentifier) {
          _identifierOrKeyword();
        } else {
          _errorHere('Unknown character');
        }
    }
  }

  void _escapedKeyword() {
    // find the closing backquote
    while (!_isAtEnd && _peek() != $backquote) {
      _advance();
    }

    if (_isAtEnd) {
      _errorUntilHere('Unterminated backquote');
    }
    tokens.add(Identifier(_currentSpan, wasEscaped: true));
  }

  void _identifierOrKeyword() {
    while (!_isAtEnd && _peek().continuesIdentifier) {
      _advance();
    }

    final matchingKeyword = _keywords[_currentSpan.text];
    if (matchingKeyword != null) {
      _add(matchingKeyword);
    } else {
      tokens.add(Identifier(_currentSpan));
    }
  }

  void _lineComment() {
    while (!_isAtEnd && _peek() != $lf) {
      _advance();
    }
  }
}

abstract class ScanningError {
  String get message;

  factory ScanningError.location(String message, SourceLocation location) =
      ScanningErrorLocation;

  factory ScanningError.span(String message, SourceSpan span) =
      ScanningErrorSpan;
}

class ScanningErrorLocation implements ScanningError {
  @override
  final String message;
  final SourceLocation location;

  ScanningErrorLocation(this.message, this.location);

  @override
  String toString() {
    return '$message at $location';
  }
}

class ScanningErrorSpan implements ScanningError {
  @override
  final String message;
  final SourceSpan span;

  ScanningErrorSpan(this.message, this.span);

  @override
  String toString() {
    return span.message(message);
  }
}

class ScanningException implements Exception {
  final List<ScanningError> errors;

  ScanningException(this.errors);

  @override
  String toString() {
    return 'ScanningExpection: ${errors.join(', ')}';
  }
}

extension on int {
  bool get isDigit => $0 <= this && this <= $9;
  bool get startsIdentifier {
    return this == $_ ||
        ($a <= this && this <= $z) ||
        ($A <= this && this <= $Z);
  }

  bool get continuesIdentifier => startsIdentifier || isDigit;
}

extension TokenUtils on Token {
  bool get isKeyword => _keywords.containsValue(tokenType);
}
