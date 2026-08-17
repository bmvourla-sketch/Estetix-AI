import '../../domain/entities/transformation_result.dart';

enum AiTransformStatus { idle, uploading, processing, success, error }

/// Immutable state for the AI transform flow.
class AiTransformState {
  const AiTransformState({
    this.status = AiTransformStatus.idle,
    this.module,
    this.style,
    this.isPremium = false,
    this.pickedImage,
    this.inputImageUrl,
    this.result,
    this.remainingTokens,
    this.errorCode,
  });

  final AiTransformStatus status;
  final TransformModule? module;
  final TransformStyle? style;
  final bool isPremium;
  final PickedImage? pickedImage;
  final String? inputImageUrl;
  final TransformationResult? result;
  final int? remainingTokens;
  final String? errorCode;

  bool get isBusy =>
      status == AiTransformStatus.uploading ||
      status == AiTransformStatus.processing;

  int get tokenCost => isPremium ? 3 : 1;

  bool get canTransform =>
      !isBusy && pickedImage != null && module != null && style != null;

  AiTransformState copyWith({
    AiTransformStatus? status,
    TransformModule? module,
    TransformStyle? style,
    bool? isPremium,
    PickedImage? pickedImage,
    String? inputImageUrl,
    TransformationResult? result,
    int? remainingTokens,
    String? errorCode,
    bool clearError = false,
  }) {
    return AiTransformState(
      status: status ?? this.status,
      module: module ?? this.module,
      style: style ?? this.style,
      isPremium: isPremium ?? this.isPremium,
      pickedImage: pickedImage ?? this.pickedImage,
      inputImageUrl: inputImageUrl ?? this.inputImageUrl,
      result: result ?? this.result,
      remainingTokens: remainingTokens ?? this.remainingTokens,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}
