/// A product row rendered inside the PDF report.
///
/// Decoupled from the ai_transform feature's `AiProduct` so the drive feature
/// has no dependency on other features.
class PdfProduct {
  const PdfProduct({required this.name, required this.priceEstimate});

  final String name;
  final String priceEstimate;
}

/// Everything the PDF engine needs to render a branded report.
///
/// Labels are pre-localized by the caller, so the generator stays a pure
/// function with no `BuildContext` or localization dependency.
class PdfReportData {
  const PdfReportData({
    required this.title,
    required this.moduleLabel,
    required this.date,
    required this.originalImageUrl,
    required this.renderImageUrl,
    required this.analysisSummary,
    required this.products,
    required this.diySteps,
    required this.analysisLabel,
    required this.productsLabel,
    required this.diyStepsLabel,
    required this.productColumn,
    required this.priceColumn,
    required this.beforeLabel,
    required this.afterLabel,
  });

  final String title;
  final String moduleLabel;
  final DateTime date;
  final String originalImageUrl;
  final String renderImageUrl;
  final String analysisSummary;
  final List<PdfProduct> products;
  final List<String> diySteps;

  // Localized section labels.
  final String analysisLabel;
  final String productsLabel;
  final String diyStepsLabel;
  final String productColumn;
  final String priceColumn;
  final String beforeLabel;
  final String afterLabel;
}
