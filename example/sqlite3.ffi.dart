// auto-generated, DO NOT EDIT
// Instead, run pub run build_runner build

import 'dart:ffi';

class sqlite3 extends Struct {}

class sqlite3_stmt extends Struct {}

typedef _sqlite3_open_native = Int32 Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>);
typedef sqlite3_open_dart = int Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>);
typedef _sqlite3_open_v2_native = Int32 Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>, Int32, Pointer<Uint8>);
typedef sqlite3_open_v2_dart = int Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>, int, Pointer<Uint8>);
typedef _sqlite3_column_blob_native = Pointer<Void> Function(
    Pointer<sqlite3_stmt>, IntPtr);
typedef sqlite3_column_blob_dart = Pointer<Void> Function(
    Pointer<sqlite3_stmt>, int);

class Bindings {
  final sqlite3_open_dart sqlite3_open;
  final sqlite3_open_v2_dart sqlite3_open_v2;
  final sqlite3_column_blob_dart sqlite3_column_blob;
  Bindings(DynamicLibrary library)
      : sqlite3_open =
            library.lookupFunction<_sqlite3_open_native, sqlite3_open_dart>(
                'sqlite3_open'),
        sqlite3_open_v2 = library.lookupFunction<_sqlite3_open_v2_native,
            sqlite3_open_v2_dart>('sqlite3_open_v2'),
        sqlite3_column_blob = library.lookupFunction<
            _sqlite3_column_blob_native,
            sqlite3_column_blob_dart>('sqlite3_column_blob');
}
