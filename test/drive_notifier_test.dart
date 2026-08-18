import 'package:flutter_test/flutter_test.dart';

import 'package:estetix_ai/features/drive/domain/entities/drive_category.dart';
import 'package:estetix_ai/features/drive/domain/entities/drive_project.dart';
import 'package:estetix_ai/features/drive/domain/entities/pdf_report_data.dart';
import 'package:estetix_ai/features/drive/domain/exceptions/drive_failure.dart';
import 'package:estetix_ai/features/drive/domain/repositories/drive_repository.dart';
import 'package:estetix_ai/features/drive/presentation/providers/drive_notifier.dart';

class _FakeDriveRepository implements DriveRepository {
  _FakeDriveRepository({this.saveFailure, this.listFailure});

  final DriveFailure? saveFailure;
  final DriveFailure? listFailure;

  @override
  Future<DriveProject> saveProject({
    required String userId,
    required DriveCategory category,
    required PdfReportData data,
  }) async {
    final DriveFailure? failure = saveFailure;
    if (failure != null) throw failure;
    return DriveProject(
      id: '123',
      category: category,
      createdAt: DateTime(2026, 8, 17),
      originalImageUrl: 'https://example.com/original',
      renderImageUrl: 'https://example.com/render',
      pdfUrl: 'https://example.com/report.pdf',
      sizeMb: 1.5,
    );
  }

  @override
  Future<List<DriveProject>> listProjects({
    required String userId,
    required DriveCategory category,
  }) async {
    final DriveFailure? failure = listFailure;
    if (failure != null) throw failure;
    return const <DriveProject>[];
  }
}

PdfReportData _data() => PdfReportData(
      title: 'Estetix AI',
      moduleLabel: 'Mekan & Bahçe',
      date: DateTime(2026, 8, 17),
      originalImageUrl: 'https://example.com/original',
      renderImageUrl: 'https://example.com/render',
      analysisSummary: 'Özet',
      products: const <PdfProduct>[],
      diySteps: const <String>[],
      analysisLabel: 'Analiz',
      productsLabel: 'Ürünler',
      diyStepsLabel: 'Adımlar',
      productColumn: 'Ürün',
      priceColumn: 'Fiyat',
      beforeLabel: 'Önce',
      afterLabel: 'Sonra',
    );

void main() {
  test('save succeeds and returns null', () async {
    final DriveNotifier notifier = DriveNotifier(_FakeDriveRepository());
    final String? code = await notifier.save(
      userId: 'u',
      category: DriveCategory.interior,
      data: _data(),
    );
    expect(code, isNull);
    expect(notifier.state.savedProject, isNotNull);
    expect(notifier.state.isSaving, isFalse);
  });

  test('save maps storageFull to storage_full', () async {
    final DriveNotifier notifier = DriveNotifier(
      _FakeDriveRepository(
        saveFailure: const DriveFailure(DriveFailureCode.storageFull),
      ),
    );
    final String? code = await notifier.save(
      userId: 'u',
      category: DriveCategory.interior,
      data: _data(),
    );
    expect(code, 'storage_full');
    expect(notifier.state.errorCode, 'storage_full');
  });

  test('save maps other failures to save_failed', () async {
    final DriveNotifier notifier = DriveNotifier(
      _FakeDriveRepository(
        saveFailure: const DriveFailure(DriveFailureCode.saveFailed),
      ),
    );
    final String? code = await notifier.save(
      userId: 'u',
      category: DriveCategory.interior,
      data: _data(),
    );
    expect(code, 'save_failed');
  });

  test('loadProjects maps failures to load_failed', () async {
    final DriveNotifier notifier = DriveNotifier(
      _FakeDriveRepository(
        listFailure: const DriveFailure(DriveFailureCode.loadFailed),
      ),
    );
    await notifier.loadProjects('u', DriveCategory.fashion);
    expect(notifier.state.errorCode, 'load_failed');
    expect(notifier.state.isLoading, isFalse);
  });
}
