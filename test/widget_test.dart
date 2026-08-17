import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:estetix_ai/app/app.dart';
import 'package:estetix_ai/core/di/service_locator.dart';
import 'package:estetix_ai/core/localization/locale_provider.dart';
import 'package:estetix_ai/core/services/device_service.dart';
import 'package:estetix_ai/features/auth/domain/entities/app_user.dart';
import 'package:estetix_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:estetix_ai/features/wallet/domain/entities/wallet.dart';
import 'package:estetix_ai/features/wallet/domain/repositories/wallet_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> get authStateChanges => const Stream<AppUser?>.empty();

  @override
  Future<void> signInWithPhone(String phoneNumber) async {}

  @override
  Future<AppUser> verifyOtp({
    required String phone,
    required String token,
    required String deviceUuid,
  }) async {
    return AppUser(id: 'user-1', phoneNumber: phone);
  }

  @override
  Future<void> signOut() async {}
}

class _FakeWalletRepository implements WalletRepository {
  @override
  Future<Wallet?> getWallet(String userId) async =>
      const Wallet(tokenBalance: 1, usedStorageMb: 12, maxStorageMb: 50);

  @override
  Stream<Wallet?> watchWallet(String userId) => Stream<Wallet?>.value(
        const Wallet(tokenBalance: 1, usedStorageMb: 12, maxStorageMb: 50),
      );

  @override
  Future<Wallet> deductToken(String userId, int amount) async =>
      const Wallet(tokenBalance: 0, usedStorageMb: 12, maxStorageMb: 50);

  @override
  Future<Wallet> addToken(String userId, int amount) async =>
      const Wallet(tokenBalance: 2, usedStorageMb: 12, maxStorageMb: 50);

  @override
  Future<Wallet> updateStorageUsage(String userId, double usedStorageMb) async =>
      Wallet(tokenBalance: 1, usedStorageMb: usedStorageMb, maxStorageMb: 50);
}

class _FakeDeviceService extends DeviceService {
  @override
  Future<String> getDeviceUuid() async =>
      '00000000-0000-0000-0000-000000000000';
}

void main() {
  setUp(() async {
    // Avoid network font fetching during widget tests.
    GoogleFonts.config.allowRuntimeFetching = false;
    GetIt.instance.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await initServiceLocator(
      authRepository: _FakeAuthRepository(),
      walletRepository: _FakeWalletRepository(),
      deviceService: _FakeDeviceService(),
    );
    await GetIt.instance<LocaleProvider>().init();
  });

  testWidgets('shows the phone login screen when unauthenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EstetixApp());
    await tester.pumpAndSettle();

    expect(find.text('Estetix AI'), findsWidgets);
    // Default locale is Turkish.
    expect(find.text('Giriş yap'), findsOneWidget);
    expect(find.text('Kod gönder'), findsOneWidget);
  });

  testWidgets('switches to RTL when Arabic is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EstetixApp());
    await tester.pumpAndSettle();

    final LocaleProvider localeProvider = GetIt.instance<LocaleProvider>();
    await localeProvider.setLocale(const Locale('ar'));
    await tester.pumpAndSettle();

    final BuildContext scaffoldContext =
        tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(scaffoldContext), TextDirection.rtl);
    expect(localeProvider.isRTL, isTrue);
  });
}
