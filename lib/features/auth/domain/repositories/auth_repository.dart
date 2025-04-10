import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/features/auth/data/services/auth_service.dart';
import 'package:trusted/features/auth/domain/models/signup_form_model.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Repository for handling authentication operations
class AuthRepository {
  /// Authentication service
  final AuthService _authService;

  /// Constructor
  AuthRepository({required AuthService authService}) : _authService = authService;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  /// Current authenticated user
  User? get currentUser => _authService.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _authService.isSignedIn;

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  /// Sign in with email and password (for admin)
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Get user data from Supabase
  Future<UserModel?> getUserData(String userId) async {
    return await _authService.getUserData(userId);
  }

  /// Check if user exists in Supabase
  Future<bool> checkUserExists(String email) async {
    return await _authService.checkUserExists(email);
  }

  /// Create new user in Supabase
  Future<UserModel?> createUser(SignupFormModel formData) async {
    return await _authService.createUser(formData);
  }

  /// Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    return await _authService.updateUserStatus(userId, status);
  }

  /// Get all users with pending status
  Future<List<UserModel>> getPendingUsers() async {
    return await _authService.getPendingUsers();
  }
  
  /// Get all users with active status
  Future<List<UserModel>> getApprovedUsers() async {
    return await _authService.getApprovedUsers();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = Supabase.instance.client;
  final authService = AuthService(supabaseClient: supabase);
  return AuthRepository(authService: authService);
});
