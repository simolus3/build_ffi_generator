import 'package:build_ffi_generator/src/parser.dart';
import 'package:build_ffi_generator/src/scanner.dart';
import 'package:test/test.dart';

void main() {
  test('runs parser', () {
    const input = '''
type sqlite3 = opaque struct;

type ByteBuffer = struct {
  int64 len;
  uint8 *data;
};

int32 sqlite3_open(int8 *filename, sqlite3 **ppDb);
    ''';

    final scanner = Scanner(input)..scan();
    final file = Parser(scanner.tokens).parseFile();

    expect(file.functions, isNotEmpty);
  });
}
