import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_project.dart';
import '../../domain/entities/pdf_report_data.dart';
import '../../domain/exceptions/drive_failure.dart';
import '../../domain/repositories/drive_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../services/pdf_generator_service.dart';

/// Concrete [DriveRepository]: generates the PDF, uploads the report plus its
/// preview images to `user-drive`, and keeps the storage counter in sync.
class DriveRepositoryImpl implements DriveRepository {
  DriveRepositoryImpl({
    required this.client,
    required this.pdfGenerator,
    required this.walletRepository,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final SupabaseClient client;
  final PdfGeneratorService pdfGenerator;
  final WalletRepository walletRepository;
  final http.Client _http;

  static const String _bucket = 'user-drive';
  static const double _bytesPerMb = 1024 * 1024;
  static const int _signedUrlExpirySeconds = 86400; // 24 hours

  @override
  Future<DriveProject> saveProject({
    required String userId,
    required DriveCategory category,
    required PdfReportData data,
  }) async {
    final Uint8List original = await _fetchBytes(data.originalImageUrl);
    final Uint8List render = await _fetchBytes(data.renderImageUrl);
    final Uint8List pdf = await pdfGenerator.generateReport(
      data: data,
      originalImageBytes: original,
      renderImageBytes: render,
    );

    final double newSizeMb =
        (original.length + render.length + pdf.length) / _bytesPerMb;

    // Limit check before writing anything.
    final wallet = await walletRepository.getWallet(userId);
    if (wallet != null &&
        wallet.usedStorageMb + newSizeMb > wallet.maxStorageMb) {
      throw const DriveFailure(DriveFailureCode.storageFull);
    }

    final String projectId = DateTime.now().microsecondsSinceEpoch.toString();
    final String prefix = '$userId/${category.wire}/$projectId';

    try {
      await _upload(
        '$prefix/original',
        original,
        _contentTypeOf(data.originalImageUrl),
      );
      await _upload('$prefix/render', render, 'image/png');
      await _upload('$prefix/report.pdf', pdf, 'application/pdf');
    } catch (e) {
      throw DriveFailure(DriveFailureCode.saveFailed, e.toString());
    }

    // New total = previously used + the size of the files just saved.
    final double newTotal = (wallet?.usedStorageMb ?? 0) + newSizeMb;
    await walletRepository.updateStorageUsage(userId, newTotal);

    return DriveProject(
      id: projectId,
      category: category,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(int.parse(projectId)),
      originalImageUrl: await _signedUrl('$prefix/original'),
      renderImageUrl: await _signedUrl('$prefix/render'),
      pdfUrl: await _signedUrl('$prefix/report.pdf'),
      sizeMb: newSizeMb,
    );
  }

  @override
  Future<List<DriveProject>> listProjects({
    required String userId,
    required DriveCategory category,
  }) async {
    final String path = '$userId/${category.wire}';
    final List<FileObject> entries =
        await client.storage.from(_bucket).list(path: path);

    final List<DriveProject> projects = <DriveProject>[];
    for (final FileObject entry in entries) {
      // Supabase Storage represents folders as entries with a null id.
      if (entry.id != null) continue;
      final String projectId = entry.name;
      projects.add(
        DriveProject(
          id: projectId,
          category: category,
          createdAt: _parseProjectDate(projectId, entry.createdAt),
          originalImageUrl: await _signedUrl('$path/$projectId/original'),
          renderImageUrl: await _signedUrl('$path/$projectId/render'),
          pdfUrl: await _signedUrl('$path/$projectId/report.pdf'),
          sizeMb: 0,
        ),
      );
    }

    projects.sort((DriveProject a, DriveProject b) =>
        b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  Future<Uint8List> _fetchBytes(String url) async {
    final http.Response res = await _http.get(Uri.parse(url));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw DriveFailure(
        DriveFailureCode.saveFailed,
        'Image fetch failed (${res.statusCode})',
      );
    }
    return res.bodyBytes;
  }

  Future<void> _upload(
    String path,
    Uint8List bytes,
    String contentType,
  ) async {
    await client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
  }

  Future<String> _signedUrl(String path) async {
    return client.storage
        .from(_bucket)
        .createSignedUrl(path, _signedUrlExpirySeconds);
  }

  String _contentTypeOf(String url) {
    final String lower = url.split('?').first.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  DateTime _parseProjectDate(String projectId, String? createdAt) {
    final int? micros = int.tryParse(projectId);
    if (micros != null) return DateTime.fromMicrosecondsSinceEpoch(micros);
    return DateTime.tryParse(createdAt ?? '') ?? DateTime.now();
  }
}
