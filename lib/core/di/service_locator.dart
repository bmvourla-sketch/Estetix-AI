import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/ai_transform/data/services/ai_service.dart';
import '../../features/ai_transform/domain/repositories/ai_transform_repository.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/drive/data/repositories/drive_repository_impl.dart';
import '../../features/drive/data/services/pdf_generator_service.dart';
import '../../features/drive/domain/repositories/drive_repository.dart';
import '../../features/health_profile/data/repositories/health_profile_repository_impl.dart';
import '../../features/health_profile/domain/repositories/health_profile_repository.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_welcome_message.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/looks/data/repositories/saved_looks_repository_impl.dart';
import '../../features/looks/domain/repositories/saved_looks_repository.dart';
import '../../features/monetization/data/repositories/monetization_repository_impl.dart';
import '../../features/monetization/data/services/ad_service.dart';
import '../../features/monetization/data/services/revenuecat_service.dart';
import '../../features/monetization/domain/repositories/monetization_repository.dart';
import '../../features/weather/data/services/weather_service.dart';
import '../../features/weight/data/repositories/weight_repository_impl.dart';
import '../../features/weight/domain/repositories/weight_repository.dart';
import '../../features/wallet/data/services/wallet_service.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import '../../features/wardrobe/domain/repositories/wardrobe_repository.dart';
import '../localization/locale_provider.dart';
import '../services/device_service.dart';

/// App-wide service locator (get_it).
final GetIt getIt = GetIt.instance;

/// Registers every dependency once, at startup.
///
/// The Supabase-backed repositories can be overridden (used by tests to inject
/// fakes) so widget/unit tests never touch the network.
Future<void> initServiceLocator({
  AuthRepository? authRepository,
  WalletRepository? walletRepository,
  DeviceService? deviceService,
  AiTransformRepository? aiTransformRepository,
}) async {
  // App-level
  getIt.registerLazySingleton<LocaleProvider>(() => LocaleProvider());
  getIt.registerLazySingleton<DeviceService>(
    () => deviceService ?? DeviceService(),
  );

  // Home feature (phase-1 demo)
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<GetWelcomeMessage>(
    () => GetWelcomeMessage(getIt<HomeRepository>()),
  );
  getIt.registerLazySingleton<HomeProvider>(
    () => HomeProvider(getIt<GetWelcomeMessage>()),
  );

  // Auth feature
  getIt.registerLazySingleton<AuthRepository>(
    () => authRepository ?? AuthService(getIt<SupabaseClient>()),
  );

  // Wallet feature
  getIt.registerLazySingleton<WalletRepository>(
    () => walletRepository ?? WalletService(getIt<SupabaseClient>()),
  );

  // AI transform feature
  getIt.registerLazySingleton<AiTransformRepository>(
    () => aiTransformRepository ?? AiService(getIt<SupabaseClient>()),
  );

  // Drive feature (PDF report engine + storage counter)
  getIt.registerLazySingleton<PdfGeneratorService>(() => PdfGeneratorService());
  getIt.registerLazySingleton<DriveRepository>(
    () => DriveRepositoryImpl(
      client: getIt<SupabaseClient>(),
      pdfGenerator: getIt<PdfGeneratorService>(),
      walletRepository: getIt<WalletRepository>(),
    ),
  );

  // Health profile (diet personalization)
  getIt.registerLazySingleton<HealthProfileRepository>(
    () => HealthProfileRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Saved looks (liked transformation results)
  getIt.registerLazySingleton<SavedLooksRepository>(
    () => SavedLooksRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Weight log (diet progress tracking)
  getIt.registerLazySingleton<WeightRepository>(
    () => WeightRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Weather (fashion "Bugün Ne Giysem" weather-aware suggestions)
  getIt.registerLazySingleton<WeatherService>(() => WeatherService());

  // Wardrobe (fashion "Gardırop" mode)
  getIt.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Monetization feature (RevenueCat purchases + AdMob ads)
  getIt.registerLazySingleton<RevenueCatService>(() => RevenueCatService());
  getIt.registerLazySingleton<AdService>(() => AdService());
  getIt.registerLazySingleton<MonetizationRepository>(
    () => MonetizationRepositoryImpl(
      client: getIt<SupabaseClient>(),
      revenueCat: getIt<RevenueCatService>(),
      adService: getIt<AdService>(),
    ),
  );
}
