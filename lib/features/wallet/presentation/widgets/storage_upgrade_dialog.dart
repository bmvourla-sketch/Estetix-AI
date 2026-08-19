import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Storage upgrade packages (token -> extra MB).
class StorageUpgradeDialog extends StatelessWidget {
  const StorageUpgradeDialog({super.key});

  static const List<({String name, double mb, int cost})> packages =
      <({String name, double mb, int cost})>[
    (name: 'Drive Lite', mb: 500, cost: 20),
    (name: 'Drive Pro', mb: 2048, cost: 50),
    (name: 'Drive Ultra', mb: 10240, cost: 150),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Depo Alanını Yükselt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final p in packages)
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text(p.name),
              subtitle: Text('+${_formatMb(p.mb)}'),
              trailing: FilledButton.tonal(
                onPressed: () => _buy(context, p.mb, p.cost),
                child: Text('${p.cost} token'),
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  Future<void> _buy(BuildContext context, double mb, int cost) async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await getIt<WalletRepository>().upgradeStorage(userId, mb, cost);
      messenger.showSnackBar(
        const SnackBar(content: Text('Depo alanın yükseltildi!')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Yetersiz token bakiyesi.')),
      );
    }
  }

  String _formatMb(double mb) {
    if (mb >= 1024) {
      final double gb = mb / 1024;
      return '${gb.toStringAsFixed(gb == gb.roundToDouble() ? 0 : 1)} GB';
    }
    return '${mb.round()} MB';
  }
}
