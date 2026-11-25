// path: lib/db/sqlite/sqflite_ffi_stub.dart

/// Stub untuk target Web, tempat `sqflite_common_ffi` tidak tersedia.
/// Simbol ini tidak dipakai pada jalur Web (kIsWeb mengembalikan lebih awal),
/// tetapi perlu ada agar berkas dapat dikompilasi.
void sqfliteFfiInit() {}

dynamic databaseFactoryFfi;
