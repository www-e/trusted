import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/features/admin/domain/models/blacklist_model.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';
import 'package:trusted/features/auth/data/services/auth_service.dart';
import 'package:trusted/features/auth/domain/models/enhanced_signup_form_model.dart';
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
  
  /// Sign in with username and password
  Future<UserCredential> signInWithUsername(String username, String password) async {
    return await _authService.signInWithUsername(username, password);
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
  Future<UserModel?> createUser(EnhancedSignupFormModel formData) async {
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

  /// Update user data
  Future<bool> updateUserData(UserModel user) async {
    return await _authService.updateUserData(user);
  }
  
  /// Get blacklist entries
  Future<List<BlacklistModel>> getBlacklistEntries() async {
    return await _authService.getBlacklistEntries();
  }
  
  /// Get primitive phone blocks
  Future<List<PrimitivePhoneBlockModel>> getPrimitivePhoneBlocks() async {
    return await _authService.getPrimitivePhoneBlocks();
  }
  
  /// Add to blacklist
  Future<String> addToBlacklist({
    String? userId,
    String? email,
    String? phoneNumber,
    String? deviceId,
    required String reason,
  }) async {
    return await _authService.addToBlacklist(
      userId: userId,
      email: email,
      phoneNumber: phoneNumber,
      deviceId: deviceId,
      reason: reason,
    );
  }
  
  /// Remove from blacklist
  Future<bool> removeFromBlacklist(String blacklistId) async {
    return await _authService.removeFromBlacklist(blacklistId);
  }
  
  /// Primitive block phone
  Future<bool> primitiveBlockPhone(String phoneNumber, String reason) async {
    return await _authService.primitiveBlockPhone(phoneNumber, reason);
  }
  
  /// Primitive unblock phone
  Future<bool> primitiveUnblockPhone(String phoneNumber) async {
    return await _authService.primitiveUnblockPhone(phoneNumber);
  }
  
  /// Check if phone is primitive blocked
  Future<bool> isPrimitiveBlocked(String phoneNumber) async {
    return await _authService.isPrimitiveBlocked(phoneNumber);
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = Supabase.instance.client;
  final authService = AuthService(supabaseClient: supabase);
  return AuthRepository(authService: authService);
});
