// auto-generated, DO NOT EDIT
// Instead, run pub run build_runner build

import 'dart:ffi';

class sqlite3 extends Opaque {}

class sqlite3_stmt extends Opaque {}

class Another extends Struct {
  @Int64()
  int foo;
}

class ByteBuffer extends Struct {
  @Int64()
  int len;
  Pointer<Uint8> data;
  Pointer<Another> foo;
}

typedef _sqlite3_open_native = Int32 Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>);
typedef sqlite3_open_dart = int Function(
    Pointer<Uint8> filename, Pointer<Pointer<sqlite3>> ppDb);
typedef _sqlite3_open_v2_native = Int32 Function(
    Pointer<Uint8>, Pointer<Pointer<sqlite3>>, Int32, Pointer<Uint8>);
typedef sqlite3_open_v2_dart = int Function(Pointer<Uint8> filename,
    Pointer<Pointer<sqlite3>> ppDb, int flags, Pointer<Uint8> zVfs);
typedef _sqlite3_column_blob_native = Pointer<Void> Function(
    Pointer<sqlite3_stmt>, Int32);
typedef sqlite3_column_blob_dart = Pointer<Void> Function(
    Pointer<sqlite3_stmt> stmt, int iCol);
typedef _create_buffer_native = Pointer<ByteBuffer> Function(Another);
typedef create_buffer_dart = Pointer<ByteBuffer> Function(Another d);

class Bindings {
  final DynamicLibrary library;
  final sqlite3_open_dart sqlite3_open;
  final sqlite3_open_v2_dart sqlite3_open_v2;
  final sqlite3_column_blob_dart sqlite3_column_blob;
  final create_buffer_dart create_buffer;
  Bindings(this.library)
      : sqlite3_open =
            library.lookupFunction<_sqlite3_open_native, sqlite3_open_dart>(
                'sqlite3_open'),
        sqlite3_open_v2 = library.lookupFunction<_sqlite3_open_v2_native,
            sqlite3_open_v2_dart>('sqlite3_open_v2'),
        sqlite3_column_blob = library.lookupFunction<
            _sqlite3_column_blob_native,
            sqlite3_column_blob_dart>('sqlite3_column_blob'),
        create_buffer =
            library.lookupFunction<_create_buffer_native, create_buffer_dart>(
                'create_buffer');
}
