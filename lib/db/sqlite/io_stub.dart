// path: lib/db/sqlite/io_stub.dart

/// Stub untuk target Web, tempat `dart:io` tidak tersedia.
class Platform {
  static Map<String, String> get environment => <String, String>{};
}

class Directory {
  final String path;
  Directory(this.path);
}

class File {
  File(String path);
}
