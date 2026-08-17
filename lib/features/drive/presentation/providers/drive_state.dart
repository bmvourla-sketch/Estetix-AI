import '../../domain/entities/drive_project.dart';

/// Immutable presentation state for Estetix Drive.
class DriveState {
  const DriveState({
    this.projects = const <DriveProject>[],
    this.isLoading = false,
    this.isSaving = false,
    this.errorCode,
    this.savedProject,
  });

  final List<DriveProject> projects;
  final bool isLoading;
  final bool isSaving;

  /// `storage_full` | `save_failed` | `load_failed` | null.
  final String? errorCode;

  /// The most recently saved project (used to show a success confirmation).
  final DriveProject? savedProject;

  DriveState copyWith({
    List<DriveProject>? projects,
    bool? isLoading,
    bool? isSaving,
    String? errorCode,
    DriveProject? savedProject,
    bool clearError = false,
  }) {
    return DriveState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      savedProject: savedProject ?? this.savedProject,
    );
  }
}
