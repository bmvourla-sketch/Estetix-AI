import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import '../core/di/service_locator.dart';
import '../core/widgets/banner_ad_slot.dart';
import '../features/ai_transform/domain/entities/transformation_result.dart';
import '../features/ai_transform/domain/repositories/ai_transform_repository.dart';
import '../features/ai_transform/presentation/pages/ai_transform_flow_page.dart';
import '../features/ai_transform/presentation/pages/diet_flow_page.dart';
import '../features/ai_transform/presentation/pages/fashion_flow_page.dart';
import '../features/ai_transform/presentation/providers/ai_transform_notifier.dart';
import '../features/ai_transform/presentation/providers/ai_transform_state.dart';
import '../features/auth/presentation/providers/auth_ui_state.dart';
import '../features/drive/presentation/pages/drive_page.dart';
import '../features/settings/presentation/pages/profile_page.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../l10n/generated/app_localizations.dart';

/// Authenticated 6-panel shell: 4 AI modules + Archive + Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<TransformModule> _modules = <TransformModule>[
    TransformModule.outdoor,
    TransformModule.interior,
    TransformModule.fashion,
    TransformModule.diet,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<Widget> panels = <Widget>[
      for (final TransformModule module in _modules) _ModuleTab(module: module),
      const DrivePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: panels),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const BannerAdSlot(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (int i) => setState(() => _index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.yard_outlined),
                label: l10n.moduleOutdoor,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chair_outlined),
                label: l10n.moduleInterior,
              ),
              NavigationDestination(
                icon: const Icon(Icons.checkroom),
                label: l10n.moduleFashion,
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_outlined),
                label: l10n.moduleDiet,
              ),
              NavigationDestination(
                icon: const Icon(Icons.folder_outlined),
                label: l10n.driveTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                label: l10n.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleTab extends StatelessWidget {
  const _ModuleTab({required this.module});

  final TransformModule module;

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<AiTransformNotifier, AiTransformState>(
      create: (BuildContext ctx) => AiTransformNotifier(
        aiRepository: getIt<AiTransformRepository>(),
        walletRepository: getIt<WalletRepository>(),
        userId: ctx.read<AuthUiState>().user?.id ?? '',
        initialModule: module,
      ),
      child: module == TransformModule.diet
          ? const DietFlowPage()
          : module == TransformModule.fashion
              ? const FashionFlowPage()
              : const AiTransformFlowPage(),
    );
  }
}
