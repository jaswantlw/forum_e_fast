import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_service/firebase_service_exports.dart';

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  /// Sign up with email and password
  Future<User> signUp({required String email, required String password}) async {
    try {
      return await _firebaseService.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  Future<User> login({required String email, required String password}) async {
    try {
      return await _firebaseService.login(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _firebaseService.logout();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current logged in user
  User? getCurrentUser() {
    return _firebaseService.getCurrentUser();
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _firebaseService.authStateChanges();
  }
}
