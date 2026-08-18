import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/transformation_result.dart';
import '../../../monetization/presentation/widgets/token_out_prompt.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';

/// Photo upload, module selection, style/mode and premium toggle.
class CameraUploadPage extends StatelessWidget {
  const CameraUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AiTransformState state = context.watch<AiTransformState>();
    final AiTransformNotifier notifier = context.read<AiTransformNotifier>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiTransformTitle)),
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                _PhotoPicker(state: state, notifier: notifier),
                const SizedBox(height: 20),
                Text(l10n.chooseModule, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                _ModuleSelector(state: state, notifier: notifier),
                const SizedBox(height: 20),
                Text(l10n.chooseStyle, style: textTheme.titleMedium),
                const SizedBox(height: 12),
                _StyleSelector(state: state, notifier: notifier),
                const SizedBox(height: 20),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: SwitchListTile(
                    value: state.isPremium,
                    onChanged: state.isBusy ? null : notifier.setPremium,
                    secondary: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.purple,
                    ),
                    title: Text(l10n.premiumMode),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.canTransform
                      ? () => _transform(context)
                      : null,
                  child: Text(l10n.transform),
                ),
                if (state.isBusy) ...<Widget>[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        state.status == AiTransformStatus.uploading
                            ? l10n.uploading
                            : l10n.processing,
                      ),
                    ],
                  ),
                ],
                if (state.errorCode != null) ...<Widget>[
                  const SizedBox(height: 16),
                  if (state.errorCode == 'insufficient_tokens')
                    const TokenOutPrompt()
                  else
                    Text(
                      _errorText(l10n, state.errorCode),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFF87171)),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _errorText(AppLocalizations l10n, String? code) =>
      code == 'insufficient_tokens'
          ? l10n.errorInsufficientTokens
          : l10n.errorGeneric;

  Future<void> _transform(BuildContext context) async {
    await context.read<AiTransformNotifier>().start();
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.state, required this.notifier});

  final AiTransformState state;
  final AiTransformNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PickedImage? picked = state.pickedImage;

    return GlassCard(
      child: Column(
        children: <Widget>[
          if (picked != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                picked.bytes,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isBusy
                      ? null
                      : () => notifier.pickImage(PickSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.selectPhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isBusy
                      ? null
                      : () => notifier.pickImage(PickSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.takePhoto),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleSelector extends StatelessWidget {
  const _ModuleSelector({required this.state, required this.notifier});

  final AiTransformState state;
  final AiTransformNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<TransformModule> modules = TransformModule.values;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < modules.length; i++) ...<Widget>[
          Expanded(
            child: _ModuleCard(
              label: _moduleLabel(l10n, modules[i]),
              icon: _moduleIcon(modules[i]),
              selected: state.module == modules[i],
              onTap: state.isBusy
                  ? null
                  : () => notifier.selectModule(modules[i]),
            ),
          ),
          if (i < modules.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.emerald.withValues(alpha: 0.18)
              : AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.emerald : AppColors.glassBorder,
            width: 1.4,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: selected ? AppColors.emerald : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.state, required this.notifier});

  final AiTransformState state;
  final AiTransformNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final TransformStyle style in TransformStyle.values)
          ChoiceChip(
            label: Text(_styleLabel(l10n, style)),
            selected: state.style == style,
            onSelected: state.isBusy
                ? null
                : (bool _) => notifier.selectStyle(style),
            selectedColor: AppColors.purple.withValues(alpha: 0.35),
            backgroundColor: AppColors.surfaceElevated,
            checkmarkColor: AppColors.textPrimary,
            labelStyle: TextStyle(
              color: state.style == style
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: state.style == style
                  ? AppColors.purple
                  : AppColors.glassBorder,
            ),
          ),
      ],
    );
  }
}

String _moduleLabel(AppLocalizations l10n, TransformModule module) =>
    switch (module) {
      TransformModule.outdoor => l10n.moduleOutdoor,
      TransformModule.interior => l10n.moduleInterior,
      TransformModule.fashion => l10n.moduleFashion,
      TransformModule.diet => l10n.moduleDiet,
    };

IconData _moduleIcon(TransformModule module) => switch (module) {
      TransformModule.outdoor => Icons.yard_outlined,
      TransformModule.interior => Icons.chair_outlined,
      TransformModule.fashion => Icons.checkroom,
      TransformModule.diet => Icons.restaurant_outlined,
    };

String _styleLabel(AppLocalizations l10n, TransformStyle style) =>
    switch (style) {
      TransformStyle.budget => l10n.styleBudget,
      TransformStyle.luxury => l10n.styleLuxury,
      TransformStyle.rainy => l10n.styleRainy,
      TransformStyle.cozy => l10n.styleCozy,
    };
