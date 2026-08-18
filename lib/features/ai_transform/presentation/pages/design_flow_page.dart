import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/transformation_result.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import 'result_page.dart';
import '../../../monetization/presentation/widgets/token_out_prompt.dart';

/// Design panel (outdoor / interior): photograph the space, choose
/// "new design" or "reuse existing items", add a style note, and let the AI
/// propose two options.
class DesignFlowPage extends StatefulWidget {
  const DesignFlowPage({super.key});

  @override
  State<DesignFlowPage> createState() => _DesignFlowPageState();
}

class _DesignFlowPageState extends State<DesignFlowPage> {
  String _mode = 'new';
  final TextEditingController _styleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<AiTransformNotifier>();
      notifier.selectStyle(TransformStyle.budget);
    });
  }

  @override
  void dispose() {
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final String style = _styleController.text.trim();
    await context.read<AiTransformNotifier>().start(
          mode: _mode,
          context: style.isEmpty ? null : style,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AiTransformState>();

    if (state.status == AiTransformStatus.success && state.options != null) {
      return const ResultPage();
    }

    final bool busy = state.status == AiTransformStatus.uploading ||
        state.status == AiTransformStatus.processing;

    return Scaffold(
      appBar: AppBar(title: const Text('Mekan Tasarımı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _photoCard(state, busy),
          const SizedBox(height: 20),
          const Text('Nasıl tasarlayalım?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _modeChip('Yeni Tasarım', 'new'),
              const SizedBox(width: 8),
              _modeChip('Var Olan Eşyalarla', 'existing'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Stil (opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _styleController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Örn: modern, klasik, rustik, lüks, sıcak…',
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
                : const Icon(Icons.auto_awesome),
            label: Text(busy ? 'Hazırlanıyor…' : 'Tasarım Oluştur'),
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
                    Icon(Icons.add_a_photo_outlined, size: 48),
                    SizedBox(height: 8),
                    Text('Mekan fotoğrafı ekle'),
                  ],
                )
              : Image.memory(picked.bytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
