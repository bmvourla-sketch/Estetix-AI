import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/entities/wardrobe_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';

/// The user's photographed wardrobe (clothing + self photos) for the
/// "Gardırop" fashion mode.
class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final List<({String value, String label})> _categories = const <({String value, String label})>[
    (value: 'top', label: 'Üst'),
    (value: 'bottom', label: 'Alt'),
    (value: 'dress', label: 'Elbise'),
    (value: 'shoes', label: 'Ayakkabı'),
    (value: 'accessory', label: 'Aksesuar'),
    (value: 'self', label: 'Kendi Foto (yüz/vücut)'),
  ];

  List<WardrobeItem> _items = const <WardrobeItem>[];
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null) return;
    final List<WardrobeItem> items =
        await getIt<WardrobeRepository>().list(userId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId == null || _adding) return;

    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final String? category = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Kategori seç',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            for (final c in _categories)
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(c.label),
                onTap: () => Navigator.of(ctx).pop(c.value),
              ),
          ],
        ),
      ),
    );
    if (category == null || !mounted) return;

    setState(() => _adding = true);
    final Uint8List bytes = await file.readAsBytes();
    await getIt<WardrobeRepository>().add(userId, category, bytes, file.name);
    if (!mounted) return;
    setState(() => _adding = false);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gardırop')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adding ? null : _add,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Foto Ekle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Henüz foto eklemedin'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final WardrobeItem item = _items[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(item.imageUrl, fit: BoxFit.cover),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Chip(
                              label: Text(_labelOf(item.category)),
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

  String _labelOf(String category) {
    for (final c in _categories) {
      if (c.value == category) return c.label;
    }
    return category;
  }
}
