import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'base_viewmodel.dart';

/// ViewModel for authentication screens (login / register).
///
/// Exposes authentication state to the UI and delegates business logic to the
/// [AuthRepository]. Notifies listeners whenever loading or error state
/// changes so the UI can rebuild.
class AuthViewModel extends BaseViewModel {
  /// Creates an [AuthViewModel] backed by [authRepository].
  AuthViewModel(this._authRepository);

  /// Repository used to perform registration, login, and session management.
  final AuthRepository _authRepository;

  /// The currently logged-in user, if cached locally.
  UserModel? get user => _authRepository.currentUser;

  /// Whether a valid session token is currently stored.
  bool get isLoggedIn => _authRepository.isLoggedIn;

  /// The stored JWT token, if any.
  String? get token => _authRepository.token;

  /// Registers a new user with the given [name], [email], and [password].
  ///
  /// Sets [isLoading] to true during the request and captures any error via
  /// [setError]. Returns `true` on success, `false` on failure.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    setBusy(true);
    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Logs in a user with the given [email] and [password].
  ///
  /// Sets [isLoading] to true during the request and captures any error via
  /// [setError]. Returns `true` on success, `false` on failure.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    setBusy(true);
    try {
      await _authRepository.login(
        email: email,
        password: password,
      );
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Refreshes the user profile from the server.
  ///
  /// Sets [isLoading] to true during the request and captures any error via
  /// [setError]. Returns `true` on success, `false` on failure.
  Future<bool> refreshProfile() async {
    setBusy(true);
    try {
      await _authRepository.getMe();
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  /// Logs out: clears the stored session and notifies listeners.
  Future<void> logout() async {
    await _authRepository.logout();
    clearError();
    notifyListeners();
  }

  /// Updates the logged-in user's [name] and/or [email].
  ///
  /// Sets [isLoading] to true during the request and captures any error via
  /// [setError]. Returns `true` on success, `false` on failure.
  Future<bool> updateProfile({String? name, String? email}) async {
    setBusy(true);
    try {
      await _authRepository.updateProfile(name: name, email: email);
      setBusy(false);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }
}
