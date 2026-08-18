import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/transformation_result.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import 'result_page.dart';
import '../../../monetization/presentation/widgets/token_out_prompt.dart';

/// Diet & recipe panel: photograph fridge/counter ingredients, choose a mode
/// (diet / normal), optionally add health notes, and let the AI return a
/// recipe that is saved to the archive.
class DietFlowPage extends StatefulWidget {
  const DietFlowPage({super.key});

  @override
  State<DietFlowPage> createState() => _DietFlowPageState();
}

class _DietFlowPageState extends State<DietFlowPage> {
  String _mode = 'diet';
  final TextEditingController _healthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<AiTransformNotifier>();
      notifier.selectModule(TransformModule.diet);
      notifier.selectStyle(TransformStyle.budget);
    });
  }

  @override
  void dispose() {
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final String health = _healthController.text.trim();
    await context.read<AiTransformNotifier>().start(
          mode: _mode,
          healthNotes: health.isEmpty ? null : health,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AiTransformState state = context.watch<AiTransformState>();

    if (state.status == AiTransformStatus.success && state.options != null) {
      return const ResultPage();
    }

    final bool busy = state.status == AiTransformStatus.uploading ||
        state.status == AiTransformStatus.processing;

    return Scaffold(
      appBar: AppBar(title: const Text('Diyet & Yemek Tarifi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _photoCard(state, busy),
          const SizedBox(height: 20),
          const Text('Ne hazırlayalım?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _modeChip('Diyet Programı', 'diet'),
              const SizedBox(width: 8),
              _modeChip('Normal Yemek', 'normal'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Sağlık notları (opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _healthController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Şeker, tansiyon, alerji, hedef (kilo verme) vb.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: busy ? null : _generate,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.restaurant),
            label: Text(busy ? 'Hazırlanıyor…' : 'Tarif Oluştur'),
          ),
          if (state.errorCode != null) ...<Widget>[
            const SizedBox(height: 16),
            if (state.errorCode == 'insufficient_tokens')
              const TokenOutPrompt()
            else
              Text(state.errorCode!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  Widget _modeChip(String label, String value) {
    final bool selected = _mode == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _mode = value),
    );
  }

  Widget _photoCard(AiTransformState state, bool busy) {
    final PickedImage? picked = state.pickedImage;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy
            ? null
            : () => context
                .read<AiTransformNotifier>()
                .pickImage(PickSource.gallery),
        child: Container(
          height: 180,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: picked == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.kitchen, size: 48),
                    SizedBox(height: 8),
                    Text('Buzdolabı / tezgah fotoğrafı ekle'),
                  ],
                )
              : Image.memory(picked.bytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
