import 'package:flutter/foundation.dart';

/// Base class for all ViewModels in the MVVM architecture.
///
/// Provides:
/// - [isLoading] flag for UI spinners
/// - [error] string for error messages
/// - [setBusy] / [setError] helpers
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Sets loading state and notifies listeners.
  void setBusy(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  /// Sets an error message and stops loading.
  void setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clears any existing error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
