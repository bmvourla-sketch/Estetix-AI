import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Resolves a stable, anonymized device identifier ("fingerprint").
///
/// The raw platform identifier (Android SSAID / iOS `identifierForVendor`) is
/// hashed to a UUID-shaped string before leaving the device, so the real
/// hardware identifier is never persisted server-side in plain text.
///
/// Android's SSAID is stable across uninstall/reinstall for a given
/// device + signing key, which is what makes the free-credit abuse guard
/// meaningful. iOS's `identifierForVendor` resets when every app from the same
/// vendor is removed — see `supabase/schema.sql` for the server-side
/// `device_uuid` unique constraint that enforces the policy.
class DeviceService {
  DeviceService({DeviceInfoPlugin? deviceInfo})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;

  Future<String> getDeviceUuid() async {
    final String raw;
    if (kIsWeb) {
      final WebBrowserInfo info = await _deviceInfo.webBrowserInfo;
      raw = info.userAgent ?? 'web-unknown';
    } else {
      raw = switch (defaultTargetPlatform) {
        TargetPlatform.android => (await _deviceInfo.androidInfo).id,
        TargetPlatform.iOS =>
          (await _deviceInfo.iosInfo).identifierForVendor ?? 'ios-unknown',
        _ => 'desktop-unknown',
      };
    }
    return _toUuid(raw);
  }

  /// SHA-256 → first 16 bytes formatted as a canonical UUID.
  String _toUuid(String raw) {
    final List<int> digest = sha256.convert(utf8.encode(raw)).bytes;
    final String hex = digest
        .take(16)
        .map((int b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
