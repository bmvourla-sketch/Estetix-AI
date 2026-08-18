import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/entities/saved_look.dart';
import '../../domain/repositories/saved_looks_repository.dart';

/// The user's liked "looks" (saved transformation results).
class LooksPage extends StatefulWidget {
  const LooksPage({super.key});

  @override
  State<LooksPage> createState() => _LooksPageState();
}

class _LooksPageState extends State<LooksPage> {
  List<SavedLook> _looks = const <SavedLook>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final List<SavedLook> looks =
        await getIt<SavedLooksRepository>().list(userId);
    if (!mounted) return;
    setState(() {
      _looks = looks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görünümler')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _looks.isEmpty
              ? const Center(child: Text('Henüz beğendiğin görünüm yok'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _looks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final SavedLook look = _looks[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(look.renderUrl, fit: BoxFit.cover),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Chip(
                              label: Text(_moduleLabel(look.module)),
                              backgroundColor: Colors.black54,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _moduleLabel(String module) => switch (module) {
        'outdoor' => 'Bahçe',
        'interior' => 'İç Mekan',
        'fashion' => 'Moda',
        'diet' => 'Diyet',
        _ => module,
      };
}
