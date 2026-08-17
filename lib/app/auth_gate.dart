import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/providers/auth_ui_state.dart';
import '../features/auth/presentation/pages/phone_login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/monetization/presentation/providers/monetization_notifier.dart';
import '../features/wallet/presentation/providers/wallet_notifier.dart';

/// Routes between the login flow and the authenticated home screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthUiState authState = context.watch<AuthUiState>();

    if (!authState.isAuthenticated) {
      return const PhoneLoginPage();
    }

    final String? userId = authState.user?.id;
    if (userId != null) {
      // Idempotent: `watch` no-ops when already subscribed to this user.
      context.read<WalletNotifier>().watch(userId);
      // Tie the RevenueCat app-user-id to the Supabase user id (webhook map).
      context.read<MonetizationNotifier>().logIn(userId);
    }
    return const HomePage();
  }
}
