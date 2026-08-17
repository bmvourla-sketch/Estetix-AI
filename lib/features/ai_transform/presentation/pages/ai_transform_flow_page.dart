import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ai_transform_state.dart';
import 'camera_upload_page.dart';
import 'result_page.dart';

/// Switches between upload and result based on the transform status.
class AiTransformFlowPage extends StatelessWidget {
  const AiTransformFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AiTransformState state = context.watch<AiTransformState>();
    if (state.status == AiTransformStatus.success && state.result != null) {
      return const ResultPage();
    }
    return const CameraUploadPage();
  }
}
