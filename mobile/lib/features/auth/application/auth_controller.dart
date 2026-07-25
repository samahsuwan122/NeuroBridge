import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../data/auth_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Holds authentication state for the app and drives login/logout.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  bool _isLoading = false;
  String? _errorCode; // 'invalid' | 'network' | null

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorCode => _errorCode;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Determine the initial auth state from stored tokens (validated via /me).
  Future<void> bootstrap() async {
    try {
      final user = await _repository.currentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      // Network error or expired token: treat as signed out.
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorCode = null;
    notifyListeners();
    try {
      _user = await _repository.login(emailOrPhone, password);
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (e) {
      _errorCode = e.code;
      return false;
    } catch (_) {
      _errorCode = 'invalid';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _errorCode = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
