/// A logged weight measurement.
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.createdAt,
  });

  final String id;
  final double weightKg;
  final DateTime createdAt;

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        id: json['id'] as String? ?? '',
        weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
