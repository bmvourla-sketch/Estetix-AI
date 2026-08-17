import 'package:state_notifier/state_notifier.dart';

import '../../domain/entities/transformation_result.dart';
import '../../domain/exceptions/ai_transform_failure.dart';
import '../../domain/repositories/ai_transform_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import 'ai_transform_state.dart';

/// Drives the transform flow: pick -> (token check) -> upload -> process.
class AiTransformNotifier extends StateNotifier<AiTransformState> {
  AiTransformNotifier({
    required this.aiRepository,
    required this.walletRepository,
    required this.userId,
  }) : super(const AiTransformState());

  final AiTransformRepository aiRepository;
  final WalletRepository walletRepository;
  final String userId;

  Future<void> pickImage(PickSource source) async {
    try {
      final PickedImage? image = await aiRepository.pickImage(source);
      if (image != null) {
        state = state.copyWith(pickedImage: image, clearError: true);
      }
    } catch (e) {
      state = state.copyWith(errorCode: 'pick_failed');
    }
  }

  void selectModule(TransformModule module) =>
      state = state.copyWith(module: module, clearError: true);

  void selectStyle(TransformStyle style) =>
      state = state.copyWith(style: style, clearError: true);

  void setPremium(bool value) => state = state.copyWith(isPremium: value);

  /// Uploads the picked photo and calls the transform-engine function.
  Future<void> start() async {
    final PickedImage? picked = state.pickedImage;
    final TransformModule? module = state.module;
    final TransformStyle? style = state.style;
    final bool isPremium = state.isPremium;
    if (picked == null || module == null || style == null) return;
    final int cost = state.tokenCost;

    state = state.copyWith(
      status: AiTransformStatus.uploading,
      clearError: true,
    );

    // Pre-flight token check (best-effort; the Edge Function enforces it).
    try {
      final wallet = await walletRepository.getWallet(userId);
      if (wallet != null) {
        if (wallet.tokenBalance < cost) {
          state = state.copyWith(
            status: AiTransformStatus.error,
            errorCode: 'insufficient_tokens',
            remainingTokens: wallet.tokenBalance,
          );
          return;
        }
        state = state.copyWith(remainingTokens: wallet.tokenBalance);
      }
    } catch (_) {
      // Continue; the server-side check is authoritative.
    }

    try {
      final String imageUrl = await aiRepository.uploadInputImage(picked);
      state = state.copyWith(
        status: AiTransformStatus.processing,
        inputImageUrl: imageUrl,
      );
      final TransformationResult result = await aiRepository.transform(
        imageUrl: imageUrl,
        module: module,
        style: style,
        isPremium: isPremium,
      );
      state = state.copyWith(
        status: AiTransformStatus.success,
        result: result,
      );
    } catch (e) {
      final bool insufficientTokens = e is AiTransformFailure &&
          e.code == AiTransformFailureCode.insufficientTokens;
      state = state.copyWith(
        status: AiTransformStatus.error,
        errorCode:
            insufficientTokens ? 'insufficient_tokens' : 'transform_failed',
      );
    }
  }

  /// Restarts the flow with a clean slate.
  void reset() => state = const AiTransformState();
}
