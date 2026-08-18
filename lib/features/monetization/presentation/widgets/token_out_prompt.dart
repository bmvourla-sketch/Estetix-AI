import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../pages/paywall_page.dart';
import '../providers/monetization_notifier.dart';

/// Shown when a transform fails because the user is out of tokens: offers
/// "watch video (+2)" or "buy premium" instead of a bare error text.
class TokenOutPrompt extends StatelessWidget {
  const TokenOutPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Token bakiyen yetersiz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _watchAd(context),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Video izle (+2)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PaywallPage()),
                ),
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Premium al'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _watchAd(BuildContext context) async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final bool earned =
        await context.read<MonetizationNotifier>().watchAd(userId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(earned ? '+2 token eklendi!' : 'Video tamamlanmadı'),
      ),
    );
  }
}
