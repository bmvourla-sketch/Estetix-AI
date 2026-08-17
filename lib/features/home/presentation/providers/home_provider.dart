import 'package:flutter/foundation.dart';

import '../../domain/usecases/get_welcome_message.dart';

/// Presentation state for the home screen.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._getWelcomeMessage);

  final GetWelcomeMessage _getWelcomeMessage;

  bool _isLoading = false;
  String _userName = '';
  String? _error;

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userName = await _getWelcomeMessage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
