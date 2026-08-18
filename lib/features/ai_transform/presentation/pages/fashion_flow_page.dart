import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../monetization/presentation/widgets/token_out_prompt.dart';
import '../../../wardrobe/domain/entities/wardrobe_item.dart';
import '../../../wardrobe/domain/repositories/wardrobe_repository.dart';
import '../../../wardrobe/presentation/pages/wardrobe_page.dart';
import '../../domain/entities/transformation_result.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import 'result_page.dart';

/// Fashion panel — "Bugün Ne Giysem?": three modes (wardrobe / new / makeup),
/// plus mood/occasion. In "wardrobe" mode the AI is told what's in the
/// user's photographed wardrobe.
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

  Future<String> _wardrobeSummary() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return '';
    final List<WardrobeItem> items =
        await getIt<WardrobeRepository>().list(userId);
    if (items.isEmpty) return '';
    final Map<String, int> counts = <String, int>{};
    for (final WardrobeItem item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    final List<String> parts = counts.entries
        .map((MapEntry<String, int> e) => '${e.value} ${_categoryLabel(e.key)}')
        .toList();
    return 'Gardıropta: ${parts.join(', ')}.';
  }

  String _categoryLabel(String c) => switch (c) {
        'top' => 'Üst',
        'bottom' => 'Alt',
        'dress' => 'Elbise',
        'shoes' => 'Ayakkabı',
        'accessory' => 'Aksesuar',
        'self' => 'Kendi Foto',
        _ => c,
      };

  Future<void> _generate() async {
    final String mood = _contextController.text.trim();
    String note = mood;
    if (_mode == 'wardrobe') {
      final String summary = await _wardrobeSummary();
      if (summary.isNotEmpty) {
        note = summary + (mood.isNotEmpty ? '. $mood' : '');
      }
    }
    if (!mounted) return;
    await context.read<AiTransformNotifier>().start(
          mode: _mode,
          context: note.isEmpty ? null : note,
        );
  }

  Future<void> _openWardrobe() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WardrobePage()),
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
          const Text('Ne yapalım?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _modeChip('Gardırop', 'wardrobe'),
              _modeChip('Yeni Tasarım', 'new'),
              _modeChip('Makyaj', 'makeup'),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openWardrobe,
              icon: const Icon(Icons.checkroom, size: 18),
              label: const Text('Gardırop\'u düzenle'),
            ),
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
                    Icon(Icons.checkroom, size: 48),
                    SizedBox(height: 8),
                    Text('Kombin / kıyafet / yüz fotoğrafı ekle'),
                  ],
                )
              : Image.memory(picked.bytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
