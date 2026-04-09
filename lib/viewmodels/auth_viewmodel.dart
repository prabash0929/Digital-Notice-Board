import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUserData;
  User? _authUser;
  bool _isLoading = false;

  UserModel? get currentUserData => _currentUserData;
  User? get authUser => _authUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUserData?.isAdmin ?? false;
  bool get isAuthenticated => _authUser != null;

  AuthViewModel() {
    _authService.authStateChanges.listen((User? user) async {
      _authUser = user;
      if (user != null) {
        _currentUserData = await _authService.getUserData(user.uid);
      } else {
        _currentUserData = null;
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      if (email == 'admin@smartboard.com') {
         try {
           await _authService.signUp(email, password);
           return;
         } catch (_) {}
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUp(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
