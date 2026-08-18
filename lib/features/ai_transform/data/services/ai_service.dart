import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/transformation_result.dart';
import '../../domain/exceptions/ai_transform_failure.dart';
import '../../domain/repositories/ai_transform_repository.dart';

/// Concrete [AiTransformRepository]: image picking, Storage upload and the
/// transform-engine Edge Function call.
class AiService implements AiTransformRepository {
  AiService(this._client, {ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final SupabaseClient _client;
  final ImagePicker _picker;

  static const String _inputBucket = 'input-images';
  static const String _functionName = 'transform-engine';

  @override
  Future<PickedImage?> pickImage(PickSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source == PickSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (file == null) return null;
    final Uint8List bytes = await file.readAsBytes();
    return PickedImage(bytes: bytes, fileName: file.name);
  }

  @override
  Future<String> uploadInputImage(PickedImage image) async {
    final String ext = _extensionOf(image.fileName);
    final String path = 'inputs/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _client.storage.from(_inputBucket).uploadBinary(
          path,
          image.bytes,
          fileOptions: FileOptions(contentType: _mimeOf(ext)),
        );
    return _client.storage.from(_inputBucket).getPublicUrl(path);
  }

  @override
  Future<List<TransformationResult>> transform({
    required String imageUrl,
    required TransformModule module,
    required TransformStyle style,
    required bool isPremium,
    String? mode,
    String? healthNotes,
  }) async {
    final FunctionResponse response = await _client.functions.invoke(
      _functionName,
      body: <String, dynamic>{
        'image_url': imageUrl,
        'module_type': module.wire,
        'style': style.wire,
        'is_premium': isPremium,
        'mode': mode,
        'health_notes': healthNotes,
      },
    );

    if (response.status < 200 || response.status >= 300) {
      final Object? payload = response.data;
      final String message = payload is Map
          ? (payload['error'] as String? ?? 'transform failed')
          : 'transform failed';
      final AiTransformFailureCode code = message.contains(
        'INSUFFICIENT_TOKEN_BALANCE',
      )
          ? AiTransformFailureCode.insufficientTokens
          : AiTransformFailureCode.transformFailed;
      throw AiTransformFailure(code, message);
    }

    final Object? payload = response.data;
    if (payload is! Map) {
      throw const AiTransformFailure(AiTransformFailureCode.unexpectedPayload);
    }
    final Object? rawOptions = payload['options'];
    if (rawOptions is! List) {
      throw const AiTransformFailure(AiTransformFailureCode.unexpectedPayload);
    }
    final List<TransformationResult> options = <TransformationResult>[];
    for (final Object? e in rawOptions) {
      if (e is Map) {
        options.add(
          TransformationResult.fromJson(Map<String, dynamic>.from(e)),
        );
      }
    }
    return options;
  }

  String _extensionOf(String fileName) {
    final int index = fileName.lastIndexOf('.');
    if (index < 0) return 'jpg';
    final String ext = fileName.substring(index + 1).toLowerCase();
    return ext.isEmpty ? 'jpg' : ext;
  }

  String _mimeOf(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        _ => 'image/jpeg',
      };
}
