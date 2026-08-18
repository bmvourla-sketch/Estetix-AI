import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/transformation_result.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../drive/domain/entities/drive_category.dart';
import '../../../drive/domain/entities/pdf_report_data.dart';
import '../../../drive/presentation/providers/drive_notifier.dart';
import '../../../drive/presentation/providers/drive_state.dart';
import '../../../looks/domain/repositories/saved_looks_repository.dart';
import '../../../monetization/presentation/pages/paywall_page.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import '../widgets/before_after_slider.dart';

/// Shows two AI options, lets the user pick one, then displays the render
/// (before/after), analysis, products (price + affiliate link) and DIY steps.
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AiTransformState state = context.watch<AiTransformState>();
    final AiTransformNotifier notifier = context.read<AiTransformNotifier>();
    final DriveState driveState = context.watch<DriveState>();
    final List<TransformationResult>? options = state.options;
    final TransformationResult? selected = state.selectedResult;
    final String? before = state.inputImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => _saveLook(context),
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Görünüm olarak kaydet',
          ),
          IconButton(
            onPressed: notifier.reset,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.aiTransformTitle,
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          if (options == null || options.isEmpty)
            Center(child: Text(l10n.errorGeneric))
          else if (selected == null)
            _OptionPicker(
              options: options,
              onPick: notifier.selectOption,
            )
          else
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  _OptionSwitcher(
                    options: options,
                    selectedIndex: state.selectedIndex,
                    onSelect: notifier.selectOption,
                  ),
                  const SizedBox(height: 16),
                  if (before != null && before.isNotEmpty)
                    BeforeAfterSlider(
                      beforeImageUrl: before,
                      afterImageUrl: selected.renderImageUrl,
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        selected.renderImageUrl,
                        height: 420,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.analysisLabel, style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(selected.analysisSummary),
                      ],
                    ),
                  ),
                  if (selected.products.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    _ProductsCard(result: selected, l10n: l10n),
                  ],
                  if (selected.diySteps.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    _DiyCard(result: selected, l10n: l10n),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: (state.isBusy || driveState.isSaving)
                        ? null
                        : () => _saveToDrive(context),
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(l10n.saveToDrive),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveToDrive(BuildContext context) async {
    final String? userId = context.read<AuthUiState>().user?.id;
    final AiTransformState state = context.read<AiTransformState>();
    final TransformationResult? result = state.selectedResult;
    final TransformModule? module = state.module;
    if (userId == null || result == null || module == null) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final DriveCategory category = _categoryOf(module);
    final PdfReportData data = PdfReportData(
      title: l10n.appTitle,
      moduleLabel: _categoryLabel(l10n, category),
      date: DateTime.now(),
      originalImageUrl: state.inputImageUrl ?? '',
      renderImageUrl: result.renderImageUrl,
      analysisSummary: result.analysisSummary,
      products: result.products
          .map((AiProduct p) =>
              PdfProduct(name: p.name, priceEstimate: p.price))
          .toList(),
      diySteps: result.diySteps,
      analysisLabel: l10n.analysisLabel,
      productsLabel: l10n.productsLabel,
      diyStepsLabel: l10n.diyStepsLabel,
      productColumn: l10n.productName,
      priceColumn: l10n.productPrice,
      beforeLabel: l10n.beforeLabel,
      afterLabel: l10n.afterLabel,
    );

    final String? errorCode = await context.read<DriveNotifier>().save(
          userId: userId,
          category: category,
          data: data,
        );
    if (!context.mounted) return;
    if (errorCode == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.savedToDrive)));
    } else if (errorCode == 'storage_full') {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PaywallPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  Future<void> _saveLook(BuildContext context) async {
    final String? userId = context.read<AuthUiState>().user?.id;
    final AiTransformState state = context.read<AiTransformState>();
    final TransformationResult? result = state.selectedResult;
    if (userId == null || result == null) return;
    await getIt<SavedLooksRepository>().save(
      userId,
      state.module?.wire ?? '',
      result.renderImageUrl,
      result.analysisSummary,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Görünüm olarak kaydedildi!')),
    );
  }

  DriveCategory _categoryOf(TransformModule module) => switch (module) {
        TransformModule.outdoor => DriveCategory.outdoor,
        TransformModule.interior => DriveCategory.interior,
        TransformModule.fashion => DriveCategory.fashion,
        TransformModule.diet => DriveCategory.diet,
      };

  String _categoryLabel(AppLocalizations l10n, DriveCategory category) =>
      switch (category) {
        DriveCategory.outdoor => l10n.folderOutdoor,
        DriveCategory.interior => l10n.folderInterior,
        DriveCategory.fashion => l10n.folderFashion,
        DriveCategory.diet => l10n.folderDiet,
      };
}

/// Two full-bleed option cards shown before the user makes a choice.
class _OptionPicker extends StatelessWidget {
  const _OptionPicker({required this.options, required this.onPick});

  final List<TransformationResult> options;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(
            'İki seçenek hazır — birini seç',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < options.length; i++)
            _OptionCard(
              index: i,
              result: options[i],
              onTap: () => onPick(i),
            ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.index,
    required this.result,
    required this.onTap,
  });

  final int index;
  final TransformationResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  result.renderImageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Seçenek ${String.fromCharCode(65 + index)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (result.totalCost.isNotEmpty)
                      Text(
                        result.totalCost,
                        style: const TextStyle(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact thumbnail switcher once an option is selected.
class _OptionSwitcher extends StatelessWidget {
  const _OptionSwitcher({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<TransformationResult> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Opacity(
                opacity: i == selectedIndex ? 1 : 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == selectedIndex
                          ? AppColors.emerald
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      options[i].renderImageUrl,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (i < options.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

/// Products with line-item price, affiliate link and total cost.
class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.result, required this.l10n});

  final TransformationResult result;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(l10n.productsLabel, style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final AiProduct product in result.products)
            ListTile(
              title: Text(product.name),
              subtitle: Text(product.price.isNotEmpty
                  ? product.price
                  : product.priceEstimate),
              trailing: TextButton.icon(
                onPressed: () => _launch(context, product),
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(l10n.buyNow),
              ),
            ),
          if (result.totalCost.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Toplam Maliyet',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    result.totalCost,
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _launch(BuildContext context, AiProduct product) {
    final String url = product.affiliateUrl.isNotEmpty
        ? product.affiliateUrl
        : product.searchUrl;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// DIY / recipe steps.
class _DiyCard extends StatelessWidget {
  const _DiyCard({required this.result, required this.l10n});

  final TransformationResult result;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.diyStepsLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (int i = 0; i < result.diySteps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.diySteps[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
