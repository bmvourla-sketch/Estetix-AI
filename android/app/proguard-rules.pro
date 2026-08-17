# -----------------------------------------------------------------------------
# Estetix AI — R8 / ProGuard rules for release builds.
#
# NOTE: Dart code (including the app's data models) is compiled AOT by Flutter
# and is never processed by R8. R8 only shrinks/obfuscates the Java/Kotlin
# plugin code. The native SDKs below ship their own consumer ProGuard rules
# which are merged automatically; the rules here cover the known remaining gaps.
# -----------------------------------------------------------------------------

# Google Mobile Ads SDK (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# RevenueCat (purchases_flutter SDK + its Flutter bridge)
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.purchases_flutter.** { *; }
-dontwarn com.revenuecat.purchases.**

# Supabase Flutter is pure Dart over HTTP/WebSocket (no native models to keep),
# but silence R8's unused-warning noise for its transitive JVM dependencies.
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.slf4j.**

# Keep annotations / signatures used by reflection-based serialization.
-keepattributes *Annotation*, InnerClasses, Signature, EnclosingMethod
