import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../health_profile/domain/entities/health_profile.dart';
import '../../../health_profile/domain/repositories/health_profile_repository.dart';
import '../../../health_profile/presentation/widgets/health_profile_dialog.dart';
import '../../../monetization/presentation/widgets/token_out_prompt.dart';
import '../../domain/entities/transformation_result.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import 'result_page.dart';

/// Diet & recipe panel: photograph fridge/counter ingredients, choose a mode
/// (diet / normal), set a health profile (age/height/weight/conditions/goal),
/// and let the AI return a personalized recipe.
class DietFlowPage extends StatefulWidget {
  const DietFlowPage({super.key});

  @override
  State<DietFlowPage> createState() => _DietFlowPageState();
}

class _DietFlowPageState extends State<DietFlowPage> {
  String _mode = 'diet';
  HealthProfile _profile = const HealthProfile();
  final TextEditingController _healthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = context.read<AiTransformNotifier>();
      notifier.selectModule(TransformModule.diet);
      notifier.selectStyle(TransformStyle.budget);
      final String? userId = context.read<AuthUiState>().user?.id;
      if (userId != null) {
        final HealthProfile? profile =
            await getIt<HealthProfileRepository>().getProfile(userId);
        if (profile != null && mounted) {
          setState(() => _profile = profile);
        }
      }
    });
  }

  @override
  void dispose() {
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _editProfile() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final HealthProfile? result = await showDialog<HealthProfile>(
      context: context,
      builder: (_) => HealthProfileDialog(userId: userId, initial: _profile),
    );
    if (result != null && mounted) setState(() => _profile = result);
  }

  Future<void> _generate() async {
    final String notes = _healthController.text.trim();
    final String profile = _profile.toPrompt();
    final String combined = <String>[
      if (profile.isNotEmpty) profile,
      if (notes.isNotEmpty) notes,
    ].join('. ');
    await context.read<AiTransformNotifier>().start(
          mode: _mode,
          healthNotes: combined.isEmpty ? null : combined,
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
          const Text('Sağlık Profili',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.monitor_heart_outlined),
              title: Text(
                _profile.isEmpty
                    ? 'Profilini oluştur (yaş, boy, kilo, rahatsızlık)'
                    : _profile.toPrompt(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _editProfile,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Ek notlar (opsiyonel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _healthController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Alerji, sevmediğin besinler vb.',
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
