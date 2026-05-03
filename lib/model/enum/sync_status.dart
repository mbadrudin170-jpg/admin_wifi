// path: lib/model/enum/sync_status.dart

/// Enum untuk merepresentasikan status sinkronisasi data.
enum SyncStatus {
  /// Data sudah sinkron dengan Firebase.
  synced,

  /// Data baru yang perlu dibuat di Firebase.
  write,

  /// Data diubah secara lokal dan perlu diperbarui di Firebase.
  update,

  /// Data dihapus secara lokal dan perlu dihapus di Firebase.
  deleted,
}
