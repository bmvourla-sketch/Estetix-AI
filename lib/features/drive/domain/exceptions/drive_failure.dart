/// Failure codes the drive feature can surface to the UI.
enum DriveFailureCode {
  /// Saving would exceed the user's storage quota (`max_storage_mb`).
  storageFull,

  /// Saving a project to Drive failed for any other reason.
  saveFailed,

  /// Listing a category's projects failed.
  loadFailed,
}

/// Domain-level failure thrown by `DriveRepository` implementations.
class DriveFailure implements Exception {
  const DriveFailure(this.code, [this.message]);

  final DriveFailureCode code;
  final String? message;

  @override
  String toString() => message ?? code.name;
}
