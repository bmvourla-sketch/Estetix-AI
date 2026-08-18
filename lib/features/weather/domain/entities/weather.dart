/// Current weather for the user's location.
class Weather {
  const Weather({required this.tempC, required this.condition});

  final double tempC;
  final String condition;

  String get summary => '$condition, ${tempC.round()}°C';
}
