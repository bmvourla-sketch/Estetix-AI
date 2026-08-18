import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/health_profile.dart';
import '../../domain/repositories/health_profile_repository.dart';

/// Form dialog for editing the user's health profile (age, height, weight,
/// conditions, goal). Pops the saved [HealthProfile] on success.
class HealthProfileDialog extends StatefulWidget {
  const HealthProfileDialog({
    super.key,
    required this.userId,
    required this.initial,
  });

  final String userId;
  final HealthProfile initial;

  @override
  State<HealthProfileDialog> createState() => _HealthProfileDialogState();
}

class _HealthProfileDialogState extends State<HealthProfileDialog> {
  late final TextEditingController _age =
      TextEditingController(text: widget.initial.age?.toString() ?? '');
  late final TextEditingController _height =
      TextEditingController(text: widget.initial.heightCm?.toString() ?? '');
  late final TextEditingController _weight =
      TextEditingController(text: widget.initial.weightKg?.toString() ?? '');
  late final TextEditingController _conditions =
      TextEditingController(text: widget.initial.conditions);
  late final TextEditingController _goal =
      TextEditingController(text: widget.initial.goal);

  bool _saving = false;

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _conditions.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final HealthProfile profile = HealthProfile(
      age: int.tryParse(_age.text.trim()),
      heightCm: int.tryParse(_height.text.trim()),
      weightKg: double.tryParse(_weight.text.trim().replaceAll(',', '.')),
      conditions: _conditions.text.trim(),
      goal: _goal.text.trim(),
    );
    setState(() => _saving = true);
    await getIt<HealthProfileRepository>().saveProfile(widget.userId, profile);
    if (!mounted) return;
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sağlık Profili'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _field(_age, 'Yaş', TextInputType.number),
            _field(_height, 'Boy (cm)', TextInputType.number),
            _field(
              _weight,
              'Kilo (kg)',
              const TextInputType.numberWithOptions(decimal: true),
            ),
            _field(_conditions, 'Rahatsızlıklar (şeker, tansiyon…)',
                TextInputType.text, maxLines: 2),
            _field(_goal, 'Hedef (kilo verme, kas kazanma…)',
                TextInputType.text),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputType type, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
