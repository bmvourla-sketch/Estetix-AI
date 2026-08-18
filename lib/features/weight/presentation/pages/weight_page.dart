import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';

/// Diet progress: log weight and see the trend.
class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  List<WeightEntry> _entries = const <WeightEntry>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final List<WeightEntry> entries =
        await getIt<WeightRepository>().list(userId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final TextEditingController controller = TextEditingController();
    final double? kg = await showDialog<double>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Kilo Ekle'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Kilo (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx)
                .pop(double.tryParse(controller.text.replaceAll(',', '.'))),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (kg == null || kg <= 0) return;
    await getIt<WeightRepository>().add(userId, kg);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> weights = _entries
        .map((WeightEntry e) => e.weightKg)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kilo Takibi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Kilo Ekle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('Henüz kilo kaydı yok'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomPaint(
                        painter: _LineChartPainter(weights),
                        size: Size.infinite,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final WeightEntry e in _entries.reversed)
                      ListTile(
                        leading: const Icon(Icons.monitor_weight_outlined),
                        title: Text('${e.weightKg.toStringAsFixed(1)} kg'),
                        subtitle: Text(
                          '${e.createdAt.day}.${e.createdAt.month}.${e.createdAt.year}',
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.weights);

  final List<double> weights;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;
    final Paint line = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final double min = weights.reduce(math.min);
    final double max = weights.reduce(math.max);
    final double range = (max - min).abs() < 0.01 ? 1.0 : max - min;
    final Path path = Path();
    for (int i = 0; i < weights.length; i++) {
      final double dx = i / (weights.length - 1) * size.width;
      final double dy =
          size.height - ((weights[i] - min) / range) * (size.height - 20) - 10;
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
