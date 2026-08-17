import 'dart:typed_data';

/// Which domain the transformation targets.
enum TransformModule {
  space('space'),
  wardrobe('wardrobe'),
  kitchen('kitchen');

  const TransformModule(this.wire);

  /// Value sent to the transform-engine Edge Function.
  final String wire;
}

/// Styling mode for the transformation (mapped to prompt hints server-side).
enum TransformStyle {
  budget('budget'),
  luxury('luxury'),
  rainy('rainy'),
  cozy('cozy');

  const TransformStyle(this.wire);

  final String wire;
}

/// Where the source photo comes from.
enum PickSource { gallery, camera }

/// A picked photo before upload (kept in memory for preview).
class PickedImage {
  const PickedImage({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// An e-commerce product suggestion returned by the Edge Function.
class AiProduct {
  const AiProduct({
    required this.name,
    required this.priceEstimate,
    required this.searchUrl,
  });

  final String name;
  final String priceEstimate;
  final String searchUrl;

  factory AiProduct.fromJson(Map<String, dynamic> json) => AiProduct(
        name: json['name'] as String? ?? '',
        priceEstimate: json['price_estimate'] as String? ?? '',
        searchUrl: json['search_url'] as String? ?? '',
      );
}

/// Result of an AI transformation (render + analysis + products + DIY steps).
class TransformationResult {
  const TransformationResult({
    required this.renderImageUrl,
    required this.analysisSummary,
    required this.products,
    required this.diySteps,
  });

  final String renderImageUrl;
  final String analysisSummary;
  final List<AiProduct> products;
  final List<String> diySteps;

  factory TransformationResult.fromJson(Map<String, dynamic> json) =>
      TransformationResult(
        renderImageUrl: json['render_image_url'] as String? ?? '',
        analysisSummary: json['analysis_summary'] as String? ?? '',
        products: (json['products'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(AiProduct.fromJson)
            .toList(),
        diySteps: (json['diy_steps'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(),
      );
}
