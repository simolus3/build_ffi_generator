// auto-generated, DO NOT EDIT
// Instead, run pub run build_runner build

import 'dart:ffi';

class sqlite3 extends Struct {}

typedef _sqlite3_open_native = Int32 Function(
    Pointer<Int8>, Pointer<Pointer<sqlite3>>);
typedef sqlite3_open_dart = int Function(
    Pointer<Int8>, Pointer<Pointer<sqlite3>>);

class Bindings {
  final sqlite3_open_dart sqlite3_open;
  Bindings(DynamicLibrary library)
      : sqlite3_open =
            library.lookupFunction<_sqlite3_open_native, sqlite3_open_dart>(
                'sqlite3_open');
}
