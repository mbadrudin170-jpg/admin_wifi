// path: tool/check_test_files.dart
import 'dart:io';

Future<void> main() async {
  final testDir = Directory('test');
  if (!testDir.existsSync()) {
    stderr.writeln('Folder test tidak ditemukan.');
    exit(1);
  }

  final files = testDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart'))
      .toList();

  final invalid = <String>[];
  for (final file in files) {
    final content = file.readAsStringSync();
    if (!content.contains('void main(')) {
      invalid.add(file.path);
    }
  }

  if (invalid.isNotEmpty) {
    stderr.writeln('File test tanpa "void main(":');
    for (final path in invalid) {
      stderr.writeln(' - $path');
    }
    exit(1);
  }

  stdout.writeln('Semua ${files.length} file test memiliki void main(.');
}
