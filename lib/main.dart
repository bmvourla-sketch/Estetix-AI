import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'core/di/service_locator.dart';
import 'core/localization/locale_provider.dart';
import 'features/monetization/data/services/ad_service.dart';
import 'features/monetization/data/services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  await initServiceLocator();
  await getIt<LocaleProvider>().init();

  // Monetization SDKs (RevenueCat purchases + AdMob ads) are mobile-only.
  // Skip them on web so the app still boots for browser previews.
  if (!kIsWeb) {
    await getIt<RevenueCatService>().init();
    await getIt<AdService>().init();
  }

  runApp(const EstetixApp());
}
