import 'package:state_notifier/state_notifier.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/pdf_report_data.dart';
import '../../domain/exceptions/drive_failure.dart';
import '../../domain/repositories/drive_repository.dart';
import 'drive_state.dart';

/// Reactive state for Estetix Drive: loading/saving projects and surfacing
/// storage-quota failures to the UI.
class DriveNotifier extends StateNotifier<DriveState> {
  DriveNotifier(this._repository) : super(const DriveState());

  final DriveRepository _repository;

  /// Lists the projects under [category], newest first.
  Future<void> loadProjects(String userId, DriveCategory category) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final projects =
          await _repository.listProjects(userId: userId, category: category);
      state = state.copyWith(isLoading: false, projects: projects);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorCode: 'load_failed');
    }
  }

  /// Generates + uploads the report. Returns `null` on success, or the error
  /// code (`storage_full` / `save_failed`) on failure.
  Future<String?> save({
    required String userId,
    required DriveCategory category,
    required PdfReportData data,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final project = await _repository.saveProject(
        userId: userId,
        category: category,
        data: data,
      );
      state = state.copyWith(isSaving: false, savedProject: project);
      return null;
    } catch (e) {
      final String code = _saveErrorCode(e);
      state = state.copyWith(isSaving: false, errorCode: code);
      return code;
    }
  }

  String _saveErrorCode(Object e) {
    if (e is DriveFailure && e.code == DriveFailureCode.storageFull) {
      return 'storage_full';
    }
    return 'save_failed';
  }
}
