/// A user's stored health profile, used to personalize diet programs.
class HealthProfile {
  const HealthProfile({
    this.age,
    this.heightCm,
    this.weightKg,
    this.conditions = '',
    this.goal = '',
  });

  final int? age;
  final int? heightCm;
  final double? weightKg;
  final String conditions;
  final String goal;

  bool get isEmpty =>
      age == null &&
      heightCm == null &&
      weightKg == null &&
      conditions.isEmpty &&
      goal.isEmpty;

  /// Formats the profile for the diet AI prompt.
  String toPrompt() => <String>[
        if (age != null) 'Yaş: $age',
        if (heightCm != null) 'Boy: $heightCm cm',
        if (weightKg != null) 'Kilo: $weightKg kg',
        if (conditions.isNotEmpty) 'Rahatsızlıklar: $conditions',
        if (goal.isNotEmpty) 'Hedef: $goal',
      ].join('. ');

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
        age: json['age'] as int?,
        heightCm: json['height_cm'] as int?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        conditions: json['health_conditions'] as String? ?? '',
        goal: json['goal'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'health_conditions': conditions,
        'goal': goal,
      };
}
