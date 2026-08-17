import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/transformation_result.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../../drive/domain/entities/drive_category.dart';
import '../../../drive/domain/entities/pdf_report_data.dart';
import '../../../drive/presentation/providers/drive_notifier.dart';
import '../../../drive/presentation/providers/drive_state.dart';
import '../../../monetization/presentation/pages/paywall_page.dart';
import '../providers/ai_transform_notifier.dart';
import '../providers/ai_transform_state.dart';
import '../widgets/before_after_slider.dart';

/// Shows the render (before/after), analysis, products and DIY steps.
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AiTransformState state = context.watch<AiTransformState>();
    final AiTransformNotifier notifier = context.read<AiTransformNotifier>();
    final DriveState driveState = context.watch<DriveState>();
    final TransformationResult? result = state.result;
    final String? before = state.inputImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        actions: <Widget>[
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
          if (result == null)
            Center(child: Text(l10n.errorGeneric))
          else
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  if (before != null && before.isNotEmpty)
                    BeforeAfterSlider(
                      beforeImageUrl: before,
                      afterImageUrl: result.renderImageUrl,
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        result.renderImageUrl,
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
                        Text(result.analysisSummary),
                      ],
                    ),
                  ),
                  if (result.products.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                            child: Text(
                              l10n.productsLabel,
                              style: textTheme.titleMedium,
                            ),
                          ),
                          for (final AiProduct product in result.products)
                            ListTile(
                              title: Text(product.name),
                              subtitle: Text(product.priceEstimate),
                              trailing: TextButton.icon(
                                onPressed: () =>
                                    _openUrl(context, product.searchUrl),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                ),
                                label: Text(l10n.buyNow),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (result.diySteps.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l10n.diyStepsLabel, style: textTheme.titleMedium),
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
                    ),
                  ],

                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: (state.isBusy || driveState.isSaving)
                        ? null
                        : () => _saveToDrive(context),
                    icon: const Icon(Icons.save_alt),
                    label: Text(
                      driveState.isSaving ? l10n.processing : l10n.saveToDrive,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
        );
      }
    }
  }

  Future<void> _saveToDrive(BuildContext context) async {
    final String? userId = context.read<AuthUiState>().user?.id;
    final AiTransformState state = context.read<AiTransformState>();
    final TransformationResult? result = state.result;
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
              PdfProduct(name: p.name, priceEstimate: p.priceEstimate))
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

  DriveCategory _categoryOf(TransformModule module) => switch (module) {
        TransformModule.space => DriveCategory.space,
        TransformModule.wardrobe => DriveCategory.wardrobe,
        TransformModule.kitchen => DriveCategory.kitchen,
      };

  String _categoryLabel(AppLocalizations l10n, DriveCategory category) =>
      switch (category) {
        DriveCategory.space => l10n.folderSpace,
        DriveCategory.wardrobe => l10n.folderWardrobe,
        DriveCategory.kitchen => l10n.folderKitchen,
      };
}
