import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/di/service_locator.dart';
import '../core/localization/locale_provider.dart';
import '../core/services/device_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../features/auth/presentation/providers/auth_ui_state.dart';
import '../features/drive/domain/repositories/drive_repository.dart';
import '../features/drive/presentation/providers/drive_notifier.dart';
import '../features/drive/presentation/providers/drive_state.dart';
import '../features/home/presentation/providers/home_provider.dart';
import '../features/monetization/domain/repositories/monetization_repository.dart';
import '../features/monetization/presentation/providers/monetization_notifier.dart';
import '../features/monetization/presentation/providers/monetization_state.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../features/wallet/presentation/providers/wallet_notifier.dart';
import '../features/wallet/presentation/providers/wallet_state.dart';
import '../l10n/generated/app_localizations.dart';
import 'auth_gate.dart';
import 'theme/app_theme.dart';

/// Root widget. Wires DI, state management, theme and localization together.
class EstetixApp extends StatelessWidget {
  const EstetixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: getIt<LocaleProvider>(),
      child: ChangeNotifierProvider<HomeProvider>.value(
        value: getIt<HomeProvider>(),
        child: StateNotifierProvider<AuthNotifier, AuthUiState>(
          create: (_) => AuthNotifier(
            getIt<AuthRepository>(),
            getIt<DeviceService>(),
          ),
          child: StateNotifierProvider<WalletNotifier, WalletState>(
            create: (_) => WalletNotifier(getIt<WalletRepository>()),
            child: StateNotifierProvider<DriveNotifier, DriveState>(
              create: (_) => DriveNotifier(getIt<DriveRepository>()),
              child: StateNotifierProvider<MonetizationNotifier,
                  MonetizationState>(
                create: (_) =>
                    MonetizationNotifier(getIt<MonetizationRepository>()),
                child: Consumer<LocaleProvider>(
                  builder: (BuildContext context,
                      LocaleProvider localeProvider, _) {
                    return MaterialApp(
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.auraDark,
                      locale: localeProvider.locale,
                      supportedLocales: localeProvider.supportedLocales,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      home: const AuthGate(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
