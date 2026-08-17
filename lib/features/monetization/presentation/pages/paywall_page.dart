import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/entities/credit_package.dart';
import '../../domain/entities/pro_plan.dart';
import '../providers/monetization_notifier.dart';
import '../providers/monetization_state.dart';

/// Conversion-focused paywall: pro subscriptions, credit packs, ad reward and
/// purchase restore.
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _loaded = false;
  ProPlan? _selectedPlan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      context.read<MonetizationNotifier>().load();
    }
  }

  String? get _userId => context.read<AuthUiState>().user?.id;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MonetizationState state = context.watch<MonetizationState>();

    final ProPlan? selected =
        _selectedPlan ?? (state.proPlans.isEmpty ? null : state.proPlans.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywallTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.changeNumber,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: <Widget>[
                      Text(
                        l10n.paywallSubtitle,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      if (state.proPlans.isNotEmpty) ...<Widget>[
                        for (final ProPlan plan in state.proPlans) ...<Widget>[
                          _ProPlanCard(
                            plan: plan,
                            selected: plan.id == selected?.id,
                            onTap: () => setState(() => _selectedPlan = plan),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: state.isPurchasing
                              ? null
                              : () => _purchasePro(l10n),
                          icon: const Icon(Icons.workspace_premium),
                          label: Text(
                            '${l10n.purchase} · ${selected?.priceString ?? ''}',
                          ),
                        ),
                      ],
                      if (state.creditPackages.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 24),
                        Text(l10n.creditsLabel, style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            for (final CreditPackage pkg
                                in state.creditPackages)
                              _CreditChip(
                                package: pkg,
                                onTap: state.isPurchasing
                                    ? null
                                    : () => _purchaseCredits(l10n, pkg),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: state.isPurchasing
                            ? null
                            : () => _watchAd(l10n),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(l10n.watchAd),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: state.isPurchasing
                            ? null
                            : () => _restore(l10n),
                        child: Text(l10n.restorePurchases),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePro(AppLocalizations l10n) async {
    final String? userId = _userId;
    final ProPlan? plan =
        _selectedPlan ?? context.read<MonetizationState>().proPlans.firstOrNull;
    if (userId == null || plan == null) return;
    final bool ok = await context
        .read<MonetizationNotifier>()
        .purchasePro(userId, plan);
    _toast(l10n, ok ? l10n.purchased : l10n.errorGeneric);
  }

  Future<void> _purchaseCredits(
    AppLocalizations l10n,
    CreditPackage package,
  ) async {
    final String? userId = _userId;
    if (userId == null) return;
    final bool ok = await context
        .read<MonetizationNotifier>()
        .purchaseCredits(userId, package);
    _toast(l10n, ok ? l10n.purchased : l10n.errorGeneric);
  }

  Future<void> _watchAd(AppLocalizations l10n) async {
    final String? userId = _userId;
    if (userId == null) return;
    final bool earned =
        await context.read<MonetizationNotifier>().watchAd(userId);
    _toast(l10n, earned ? l10n.adWatched : l10n.adUnavailable);
  }

  Future<void> _restore(AppLocalizations l10n) async {
    final String? userId = _userId;
    if (userId == null) return;
    final bool ok =
        await context.read<MonetizationNotifier>().restore(userId);
    _toast(l10n, ok ? l10n.restored : l10n.errorGeneric);
  }

  void _toast(AppLocalizations l10n, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _ProPlanCard extends StatelessWidget {
  const _ProPlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final ProPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GlassCard(
      borderColor: selected ? AppColors.emerald : AppColors.glassBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        plan.isYearly ? l10n.proYearly : l10n.proMonthly,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (plan.isYearly) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.bestValue,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF052E22),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.priceString,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.emerald : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditChip extends StatelessWidget {
  const _CreditChip({required this.package, required this.onTap});

  final CreditPackage package;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: <Widget>[
            Text(
              '${package.credits} ${l10n.creditsLabel}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              package.priceString,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
