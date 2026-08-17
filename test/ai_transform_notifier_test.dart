import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:estetix_ai/features/ai_transform/domain/entities/transformation_result.dart';
import 'package:estetix_ai/features/ai_transform/domain/exceptions/ai_transform_failure.dart';
import 'package:estetix_ai/features/ai_transform/domain/repositories/ai_transform_repository.dart';
import 'package:estetix_ai/features/ai_transform/presentation/providers/ai_transform_notifier.dart';
import 'package:estetix_ai/features/ai_transform/presentation/providers/ai_transform_state.dart';
import 'package:estetix_ai/features/wallet/domain/entities/wallet.dart';
import 'package:estetix_ai/features/wallet/domain/repositories/wallet_repository.dart';

class _FakeAiRepository implements AiTransformRepository {
  @override
  Future<PickedImage?> pickImage(PickSource source) async => PickedImage(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        fileName: 'photo.jpg',
      );

  @override
  Future<String> uploadInputImage(PickedImage image) async =>
      'https://example.com/storage/input.png';

  @override
  Future<TransformationResult> transform({
    required String imageUrl,
    required TransformModule module,
    required TransformStyle style,
    required bool isPremium,
  }) async {
    return TransformationResult(
      renderImageUrl: 'https://example.com/storage/render.png',
      analysisSummary: 'Analysis ok',
      products: const <AiProduct>[
        AiProduct(
          name: 'Masa lambası',
          priceEstimate: '₺499',
          searchUrl: 'https://example.com/search?q=lamp',
        ),
      ],
      diySteps: const <String>['Adım 1', 'Adım 2'],
    );
  }
}

class _FakeWalletRepository implements WalletRepository {
  _FakeWalletRepository(this.balance);

  final int balance;

  @override
  Future<Wallet?> getWallet(String userId) async =>
      Wallet(tokenBalance: balance, usedStorageMb: 12, maxStorageMb: 50);

  @override
  Stream<Wallet?> watchWallet(String userId) => const Stream<Wallet?>.empty();

  @override
  Future<Wallet> deductToken(String userId, int amount) async => Wallet(
        tokenBalance: balance - amount,
        usedStorageMb: 12,
        maxStorageMb: 50,
      );

  @override
  Future<Wallet> addToken(String userId, int amount) async => Wallet(
        tokenBalance: balance + amount,
        usedStorageMb: 12,
        maxStorageMb: 50,
      );

  @override
  Future<Wallet> updateStorageUsage(String userId, double usedStorageMb) async =>
      Wallet(tokenBalance: balance, usedStorageMb: usedStorageMb, maxStorageMb: 50);
}

class _FailingAiRepository implements AiTransformRepository {
  _FailingAiRepository(this.failure);

  final AiTransformFailure failure;

  @override
  Future<PickedImage?> pickImage(PickSource source) async => PickedImage(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        fileName: 'photo.jpg',
      );

  @override
  Future<String> uploadInputImage(PickedImage image) async =>
      'https://example.com/storage/input.png';

  @override
  Future<TransformationResult> transform({
    required String imageUrl,
    required TransformModule module,
    required TransformStyle style,
    required bool isPremium,
  }) async {
    throw failure;
  }
}

void main() {
  test('blocks the transform when token balance is insufficient', () async {
    final notifier = AiTransformNotifier(
      aiRepository: _FakeAiRepository(),
      walletRepository: _FakeWalletRepository(0),
      userId: 'user-1',
    );

    await notifier.pickImage(PickSource.gallery);
    notifier
      ..selectModule(TransformModule.space)
      ..selectStyle(TransformStyle.budget);

    await notifier.start();

    expect(notifier.state.status, AiTransformStatus.error);
    expect(notifier.state.errorCode, 'insufficient_tokens');
  });

  test('completes the transform and exposes the result', () async {
    final notifier = AiTransformNotifier(
      aiRepository: _FakeAiRepository(),
      walletRepository: _FakeWalletRepository(5),
      userId: 'user-1',
    );

    await notifier.pickImage(PickSource.camera);
    notifier
      ..selectModule(TransformModule.wardrobe)
      ..selectStyle(TransformStyle.luxury)
      ..setPremium(true);

    await notifier.start();

    expect(notifier.state.status, AiTransformStatus.success);
    expect(
      notifier.state.result?.renderImageUrl,
      'https://example.com/storage/render.png',
    );
    expect(notifier.state.result?.products, hasLength(1));
    expect(notifier.state.result?.diySteps, hasLength(2));
    expect(notifier.state.tokenCost, 3);
  });

  test('stays idle when no image or module/style is selected', () async {
    final notifier = AiTransformNotifier(
      aiRepository: _FakeAiRepository(),
      walletRepository: _FakeWalletRepository(5),
      userId: 'user-1',
    );

    await notifier.start();
    expect(notifier.state.status, AiTransformStatus.idle);
  });

  test('maps a server-side insufficient-token rejection to the right error',
      () async {
    final notifier = AiTransformNotifier(
      aiRepository: _FailingAiRepository(
        const AiTransformFailure(
          AiTransformFailureCode.insufficientTokens,
          'INSUFFICIENT_TOKEN_BALANCE',
        ),
      ),
      walletRepository: _FakeWalletRepository(5),
      userId: 'user-1',
    );

    await notifier.pickImage(PickSource.gallery);
    notifier
      ..selectModule(TransformModule.kitchen)
      ..selectStyle(TransformStyle.cozy);

    await notifier.start();

    expect(notifier.state.status, AiTransformStatus.error);
    expect(notifier.state.errorCode, 'insufficient_tokens');
  });

  test('maps other transform failures to a generic error', () async {
    final notifier = AiTransformNotifier(
      aiRepository: _FailingAiRepository(
        const AiTransformFailure(AiTransformFailureCode.transformFailed),
      ),
      walletRepository: _FakeWalletRepository(5),
      userId: 'user-1',
    );

    await notifier.pickImage(PickSource.camera);
    notifier
      ..selectModule(TransformModule.space)
      ..selectStyle(TransformStyle.budget);

    await notifier.start();

    expect(notifier.state.status, AiTransformStatus.error);
    expect(notifier.state.errorCode, 'transform_failed');
  });
}
