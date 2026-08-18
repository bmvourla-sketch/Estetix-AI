import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/weather.dart';

/// Fetches current weather from the free Open-Meteo API (no API key), locating
/// the user via IP-based geolocation with an Istanbul fallback.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Weather?> current() async {
    try {
      double lat = 41.0082;
      double lon = 28.9784;
      try {
        final http.Response locRes = await _client
            .get(Uri.parse('https://ipapi.co/json/'))
            .timeout(const Duration(seconds: 5));
        if (locRes.statusCode == 200) {
          final Map<String, dynamic> loc =
              jsonDecode(locRes.body) as Map<String, dynamic>;
          final double? la = (loc['latitude'] as num?)?.toDouble();
          final double? lo = (loc['longitude'] as num?)?.toDouble();
          if (la != null && lo != null) {
            lat = la;
            lon = lo;
          }
        }
      } catch (_) {
        // fall back to Istanbul
      }

      final http.Response res = await _client
          .get(Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
          ))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;
      final Map<String, dynamic>? cw =
          body['current_weather'] as Map<String, dynamic>?;
      if (cw == null) return null;

      final double tempC = (cw['temperature'] as num?)?.toDouble() ?? 0;
      final int code = (cw['weathercode'] as num?)?.toInt() ?? 0;
      return Weather(tempC: tempC, condition: _condition(code));
    } catch (_) {
      return null;
    }
  }

  String _condition(int code) {
    if (code == 0) return 'Açık';
    if (code <= 3) return 'Parçalı bulutlu';
    if (code == 45 || code == 48) return 'Sisli';
    if (code >= 51 && code <= 67) return 'Yağmurlu';
    if (code >= 71 && code <= 77) return 'Karlı';
    if (code >= 80 && code <= 82) return 'Sağanak yağışlı';
    if (code >= 95) return 'Fırtınalı';
    return 'Bulutlu';
  }
}
