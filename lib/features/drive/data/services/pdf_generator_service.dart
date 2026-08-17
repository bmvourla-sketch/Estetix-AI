import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/pdf_report_data.dart';

/// Fonts used to render the report.
class PdfFonts {
  const PdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;
}

/// Resolves the fonts for a report generation (injectable for tests).
typedef PdfFontLoader = Future<PdfFonts> Function();

/// Builds the branded "Estetix AI" PDF report.
///
/// Pure function: it receives image *bytes* and pre-localized labels, so it has
/// no network, storage or localization dependency and is trivially testable.
class PdfGeneratorService {
  PdfGeneratorService({PdfFontLoader? fontLoader})
      : _fontLoader = fontLoader ?? _defaultFontLoader;

  final PdfFontLoader _fontLoader;

  static const PdfColor _background = PdfColor.fromInt(0xFF0E0F14);
  static const PdfColor _emerald = PdfColor.fromInt(0xFF10B981);
  static const PdfColor _purple = PdfColor.fromInt(0xFF8B5CF6);
  static const PdfColor _muted = PdfColor.fromInt(0xFF9AA1B2);
  static const PdfColor _divider = PdfColor.fromInt(0xFF2A2C37);

  Future<Uint8List> generateReport({
    required PdfReportData data,
    required Uint8List originalImageBytes,
    required Uint8List renderImageBytes,
  }) async {
    final PdfFonts fonts = await _fontLoader();
    final pw.Document doc = pw.Document(
      title: data.title,
      author: 'Estetix AI',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        footer: (pw.Context context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              'Estetix AI  •  ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ),
        ),
        build: (pw.Context context) => <pw.Widget>[
          _header(data),
          pw.SizedBox(height: 16),
          _imagePair(data, originalImageBytes, renderImageBytes),
          pw.SizedBox(height: 16),
          _section(data.analysisLabel, pw.Text(data.analysisSummary)),
          if (data.products.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 12),
            _section(data.productsLabel, _productsTable(context, data)),
          ],
          if (data.diySteps.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 12),
            _section(data.diyStepsLabel, _diySteps(data)),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _header(PdfReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _background,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Container(width: 5, height: 44, color: _emerald),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  data.title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${data.moduleLabel}   •   ${_formatDate(data.date)}',
                  style: const pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _imagePair(
    PdfReportData data,
    Uint8List original,
    Uint8List render,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Expanded(child: _labeledImage(data.beforeLabel, original)),
        pw.SizedBox(width: 12),
        pw.Expanded(child: _labeledImage(data.afterLabel, render)),
      ],
    );
  }

  pw.Widget _labeledImage(String label, Uint8List bytes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.ClipRRect(
          horizontalRadius: 10,
          verticalRadius: 10,
          child: pw.Image(
            pw.MemoryImage(bytes),
            height: 170,
            fit: pw.BoxFit.cover,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _purple,
          ),
        ),
      ],
    );
  }

  pw.Widget _section(String title, pw.Widget body) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Row(
          children: <pw.Widget>[
            pw.Container(width: 14, height: 3, color: _emerald),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _background,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        body,
      ],
    );
  }

  pw.Widget _productsTable(pw.Context context, PdfReportData data) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: <String>[data.productColumn, data.priceColumn],
      data: data.products
          .map((PdfProduct p) => <String>[p.name, p.priceEstimate])
          .toList(),
      headerDecoration: const pw.BoxDecoration(color: _emerald),
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      cellStyle: const pw.TextStyle(fontSize: 10, color: _background),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _divider, width: 0.5),
        bottom: pw.BorderSide(color: _divider, width: 0.5),
        left: pw.BorderSide(color: _divider, width: 0.5),
        right: pw.BorderSide(color: _divider, width: 0.5),
        top: pw.BorderSide(color: _divider, width: 0.5),
      ),
    );
  }

  pw.Widget _diySteps(PdfReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        for (int i = 0; i < data.diySteps.length; i++)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 18,
                  height: 18,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    color: _purple,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Text(
                    '${i + 1}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(
                    data.diySteps[i],
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Default font loader: bundled Roboto (SIL OFL) loaded from the app asset
/// bundle, so the report renders Turkish and other Unicode glyphs (ı, ₺, •, …)
/// correctly with no network dependency — unlike the previous Google Fonts
/// download that silently fell back to Latin-only Helvetica when offline.
Future<PdfFonts> _defaultFontLoader() async {
  return PdfFonts(
    regular: pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf')),
    bold: pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf')),
  );
}
