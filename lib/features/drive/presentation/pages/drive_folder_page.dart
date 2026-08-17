import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/aura_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_ui_state.dart';
import '../../domain/entities/drive_category.dart';
import '../../domain/entities/drive_project.dart';
import '../providers/drive_notifier.dart';
import '../providers/drive_state.dart';

/// Lists the saved projects inside a single Drive category folder.
class DriveFolderPage extends StatefulWidget {
  const DriveFolderPage({super.key, required this.category});

  final DriveCategory category;

  @override
  State<DriveFolderPage> createState() => _DriveFolderPageState();
}

class _DriveFolderPageState extends State<DriveFolderPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  void _load() {
    final String? userId = context.read<AuthUiState>().user?.id;
    if (userId != null) {
      context.read<DriveNotifier>().loadProjects(userId, widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DriveState state = context.watch<DriveState>();

    return Scaffold(
      appBar: AppBar(title: Text(_label(l10n, widget.category))),
      body: Stack(
        children: <Widget>[
          const AuraBackground(),
          SafeArea(child: _body(context, l10n, state)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, DriveState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorCode == 'load_failed' && state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.errorGeneric,
                style: const TextStyle(color: Color(0xFFF87171))),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: Text(l10n.getStarted)),
          ],
        ),
      );
    }
    if (state.projects.isEmpty) {
      return Center(child: Text(l10n.emptyFolder));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.projects.length,
      separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext _, int i) =>
          _ProjectCard(project: state.projects[i]),
    );
  }

  String _label(AppLocalizations l10n, DriveCategory c) => switch (c) {
        DriveCategory.space => l10n.folderSpace,
        DriveCategory.wardrobe => l10n.folderWardrobe,
        DriveCategory.kitchen => l10n.folderKitchen,
      };
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final DriveProject project;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              project.renderImageUrl,
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                  Container(
                width: 76,
                height: 76,
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _formatDate(project.createdAt),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: l10n.downloadPdf,
            onPressed: () => _openPdf(context, project.pdfUrl),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.sharePdf,
            onPressed: () => _sharePdf(context, project.pdfUrl),
          ),
        ],
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      _toast(context, AppLocalizations.of(context).errorGeneric);
    }
  }

  Future<void> _sharePdf(BuildContext context, String url) async {
    try {
      final http.Response res = await http.get(Uri.parse(url));
      if (!context.mounted) return;
      if (res.statusCode != 200) {
        _toast(context, AppLocalizations.of(context).errorGeneric);
        return;
      }
      await Printing.sharePdf(
        bytes: res.bodyBytes,
        filename: 'estetix-report.pdf',
      );
    } catch (_) {
      if (!context.mounted) return;
      _toast(context, AppLocalizations.of(context).errorGeneric);
    }
  }

  void _toast(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}
