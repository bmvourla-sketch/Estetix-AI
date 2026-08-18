import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/transformation_result.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import 'result_page.dart';

/// Fashion panel — "Bugün Ne Giysem?": photograph an outfit/self, choose
/// "wardrobe" (existing clothes) or "new" (brand-new pieces), add the mood or
/// occasion, and let the AI propose two looks.
class FashionFlowPage extends StatefulWidget {
  const FashionFlowPage({super.key});

  @override
  State<FashionFlowPage> createState() => _FashionFlowPageState();
}

class _FashionFlowPageState extends State<FashionFlowPage> {
  String _mode = 'wardrobe';
  final TextEditingController _contextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<AiTransformNotifier>();
      notifier.selectModule(TransformModule.fashion);
      notifier.selectStyle(TransformStyle.budget);
    });
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final String ctx = _contextController.text.trim();
    await context.read<AiTransformNotifier>().start(
          mode: _mode,
          context: ctx.isEmpty ? null : ctx,
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
      appBar: AppBar(title: const Text('Bugün Ne Giysem?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _photoCard(state, busy),
          const SizedBox(height: 20),
          const Text('Gardırobundan mı, yeni mi?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _modeChip('Gardırop', 'wardrobe'),
              const SizedBox(width: 8),
              _modeChip('Yeni Tasarım', 'new'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Modun / etkinlik (opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _contextController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Örn: iş toplantısı, yağmurlu, spor, romantik akşam…',
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
                : const Icon(Icons.checkroom),
            label: Text(busy ? 'Hazırlanıyor…' : 'Kombin Oluştur'),
          ),
          if (state.errorCode != null) ...<Widget>[
            const SizedBox(height: 16),
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
                    Icon(Icons.checkroom, size: 48),
                    SizedBox(height: 8),
                    Text('Kombin / kıyafet fotoğrafı ekle'),
                  ],
                )
              : Image.memory(picked.bytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
