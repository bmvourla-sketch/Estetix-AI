import '../entities/drive_category.dart';
import '../entities/drive_project.dart';
import '../entities/pdf_report_data.dart';

/// Abstract contract for Estetix Drive persistence.
abstract interface class DriveRepository {
  /// Generates the PDF report, uploads it (plus preview images) to Supabase
  /// Storage under `user-drive/{userId}/{category}/{projectId}/`, updates the
  /// user's `used_storage_mb` and returns the saved project.
  ///
  /// Throws `DriveFailure` (`storageFull`) when the new project would exceed
  /// the user's storage quota.
  Future<DriveProject> saveProject({
    required String userId,
    required DriveCategory category,
    required PdfReportData data,
  });

  /// Lists the projects saved under a category, newest first.
  Future<List<DriveProject>> listProjects({
    required String userId,
    required DriveCategory category,
  });
}
