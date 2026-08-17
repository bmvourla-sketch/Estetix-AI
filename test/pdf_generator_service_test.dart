import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:estetix_ai/features/drive/data/services/pdf_generator_service.dart';
import 'package:estetix_ai/features/drive/domain/entities/pdf_report_data.dart';

/// Offline fonts loaded from the bundled asset (no network, full Unicode).
Future<PdfFonts> _offlineFonts() async => PdfFonts(
      regular: pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      ),
      bold: pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      ),
    );

/// A valid 1x1 transparent PNG (decoded to bytes).
Uint8List _png() => base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
      'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates a non-empty PDF with the %PDF magic header', () async {
    final PdfGeneratorService service =
        PdfGeneratorService(fontLoader: _offlineFonts);

    final PdfReportData data = PdfReportData(
      title: 'Estetix AI',
      moduleLabel: 'Mekan & Bahçe',
      date: DateTime(2026, 8, 17, 20, 30),
      originalImageUrl: 'https://example.com/original.png',
      renderImageUrl: 'https://example.com/render.png',
      analysisSummary: 'Analiz özeti',
      products: const <PdfProduct>[
        PdfProduct(name: 'Masa lambası', priceEstimate: '₺499'),
        PdfProduct(name: 'Halı', priceEstimate: '₺899'),
      ],
      diySteps: const <String>['Adım 1', 'Adım 2', 'Adım 3'],
      analysisLabel: 'Analiz',
      productsLabel: 'Ürünler',
      diyStepsLabel: 'Uygulama Adımları',
      productColumn: 'Ürün',
      priceColumn: 'Fiyat',
      beforeLabel: 'Önce',
      afterLabel: 'Sonra',
    );

    final Uint8List bytes = await service.generateReport(
      data: data,
      originalImageBytes: _png(),
      renderImageBytes: _png(),
    );

    expect(bytes.length, greaterThan(200));
    expect(bytes[0], 0x25); // '%'
    expect(bytes[1], 0x50); // 'P'
    expect(bytes[2], 0x44); // 'D'
    expect(bytes[3], 0x46); // 'F'
  });
}
