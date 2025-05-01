import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gotrue/src/types/types.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/config/env_config.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/admin/domain/models/blacklist_model.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';
import 'package:trusted/features/auth/domain/models/enhanced_signup_form_model.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Authentication provider enum
enum AuthProvider {
  /// Google authentication provider
  google,
  
  /// Email authentication provider
  email,
  
  /// Username authentication provider
  username
}

/// Custom credential class to handle authentication responses
class UserCredential {
  /// The authenticated user
  final User user;
  
  /// The authentication session
  final Session session;
  
  /// The authentication provider used
  final AuthProvider provider;

  /// Constructor
  UserCredential({
    required this.user,
    required this.session,
    required this.provider,
  });
}

/// Service for handling authentication operations
class AuthService {
  /// Logger instance
  final Logger _logger = Logger();
  
  /// Supabase client instance
  final SupabaseClient _supabaseClient;
  
  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn;

  /// Constructor
  AuthService({
    required SupabaseClient supabaseClient,
    GoogleSignIn? googleSignIn,
  }) : _supabaseClient = supabaseClient,
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         // Use the web client ID as serverClientId for Android
         serverClientId: EnvConfig.googleClientIdWeb,
         // For iOS, use clientId
         clientId: Platform.isIOS ? EnvConfig.googleClientIdIos : null,
         scopes: ['email', 'profile'],
       );

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => 
      _supabaseClient.auth.onAuthStateChange;

  /// Current authenticated user
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Clear any previous sign-in state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign-in was cancelled by the user';
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        throw 'Failed to obtain ID token from Google';
      }
      
      // Use the web client ID for Supabase authentication
      final AuthResponse response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (response.session == null) {
        throw 'Failed to sign in with Google';
      }
      
      _logger.i('User signed in with Google: ${response.user?.id}, Email: ${response.user?.email}');
      
      return UserCredential(
        user: response.user!,
        session: response.session!,
        provider: AuthProvider.google,
      );
    } catch (e) {
      _logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  /// Generate a random nonce for OAuth security
  String _generateNonce() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Sign in with email and password (for admin)
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse response = 
          await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw 'Failed to sign in with email';
      }
      
      return UserCredential(
        user: response.user!,
        session: response.session!,
        provider: AuthProvider.email,
      );
    } catch (e) {
      _logger.e('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Sign in with username and password
  Future<UserCredential> signInWithUsername(String username, String password) async {
    try {
      _logger.i('Attempting to sign in with username: $username');
      
      // Find the user's email by username (case-sensitive for production security)
      final response = await _supabaseClient
          .from('users')
          .select('email, id, username')
          .eq('username', username)
          .maybeSingle();
      
      _logger.d('Username lookup response: $response');
      
      if (response == null) {
        _logger.w('No user found with username: $username');
        throw 'اسم المستخدم غير موجود';
      }
      
      final email = response['email'] as String;
      final userId = response['id'] as String;
      final storedUsername = response['username'] as String;
      
      // Double check the username matches exactly (case-sensitive)
      if (storedUsername != username) {
        _logger.w('Username case mismatch: $username vs $storedUsername');
        throw 'اسم المستخدم غير موجود';
      }
      
      _logger.d('Found email for username: $username, userId: $userId');
      
      // Now sign in with the email and password
      _logger.d('Attempting to sign in with email and password');
      final AuthResponse authResponse = 
          await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.session == null) {
        _logger.w('Failed to sign in: session is null');
        throw 'Failed to sign in with username';
      }
      
      _logger.i('Successfully signed in with username: $username');
      return UserCredential(
        user: authResponse.user!,
        session: authResponse.session!,
        provider: AuthProvider.username,
      );
    } catch (e) {
      _logger.e('Error signing in with username: $e');
      if (e is PostgrestException) {
        _logger.e('PostgrestException: ${e.code} - ${e.message}');
        if (e.code == 'PGRST116') {
          throw 'اسم المستخدم غير موجود';
        }
      } else if (e is AuthException) {
        _logger.e('AuthException: ${e.statusCode} - ${e.message}');
        if (e.statusCode == 'invalid_login_credentials') {
          throw 'كلمة المرور غير صحيحة';
        }
      }
      throw e.toString();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
    } catch (e) {
      _logger.e('Error signing out: $e');
      rethrow;
    }
  }

  /// Get user data from Supabase
  Future<UserModel?> getUserData(String userId) async {
    try {
      // Special handling for admin UID
      if (userId == 'b5d8fad3-d815-434d-bc90-3b0157317a20') {
        _logger.i('Admin user detected with specific UID');
        // Check if this user exists in the database
        final adminCheck = await _supabaseClient
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
            
        // If admin user doesn't exist in the database, create it
        if (adminCheck == null) {
          _logger.i('Admin user not found in database, creating admin record');
          try {
            // Create admin user record
            await _supabaseClient.from('users').insert({
              'id': userId,
              'email': AppConstants.adminEmail,
              'name': 'Admin User',
              'role': AppConstants.roleAdmin,
              'phone_number': '+966000000000', // Placeholder
              'nickname': 'Admin',
              'country': 'SA',
              'status': AppConstants.statusActive,
              'created_at': DateTime.now().toIso8601String(),
              'accepted_at': DateTime.now().toIso8601String(),
            });
            _logger.i('Admin user record created successfully');
          } catch (e) {
            _logger.e('Error creating admin user record: $e');
          }
        }
      }
      
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        // Special case for admin email
        if (userId == 'b5d8fad3-d815-434d-bc90-3b0157317a20') {
          _logger.i('Creating admin user model for UID: $userId');
          return UserModel(
            id: userId,
            email: AppConstants.adminEmail,
            name: 'Admin User',
            role: AppConstants.roleAdmin,
            phoneNumber: '+966000000000', // Placeholder
            secondaryPhoneNumber: null,
            nickname: 'Admin',
            country: 'SA',
            status: AppConstants.statusActive,
            businessName: null,
            businessDescription: null,
            workingSolo: null,
            associateIds: null,
            whatsappNumber: null,
            createdAt: DateTime.now(),
            acceptedAt: DateTime.now(),
          );
        }
        return null;
      }
      
      return UserModel(
        id: response['id'],
        email: response['email'],
        name: response['name'],
        role: response['role'],
        phoneNumber: response['phone_number'],
        secondaryPhoneNumber: response['secondary_phone_number'],
        nickname: response['nickname'],
        country: response['country'],
        status: response['status'],
        businessName: response['business_name'],
        businessDescription: response['business_description'],
        workingSolo: response['working_solo'],
        associateIds: response['associate_ids'],
        whatsappNumber: response['whatsapp_number'],
        createdAt: DateTime.parse(response['created_at']),
        acceptedAt: response['accepted_at'] != null 
            ? DateTime.parse(response['accepted_at']) 
            : null,
      );
    } catch (e) {
      _logger.e('Error getting user data: $e');
      return null;
    }
  }

  /// Check if user exists in Supabase
  Future<bool> checkUserExists(String email) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select('email')
          .eq('email', email);
      
      return response.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if user exists: $e');
      return false;
    }
  }

  /// Create new user in Supabase
  Future<UserModel?> createUser(EnhancedSignupFormModel formData) async {
    try {
      if (currentUser == null) {
        throw 'User is not authenticated';
      }
      
      final userData = {
        'id': currentUser!.id,
        ...formData.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _supabaseClient.from('users').insert(userData);
      
      return await getUserData(currentUser!.id);
    } catch (e) {
      _logger.e('Error creating user: $e');
      return null;
    }
  }

  /// Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      final updateData = {'status': status};
      
      // Add acceptedAt timestamp when activating a user
      if (status == AppConstants.statusActive) {
        updateData['accepted_at'] = DateTime.now().toIso8601String();
      }
      
      await _supabaseClient
          .from('users')
          .update(updateData)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      _logger.e('Error updating user status: $e');
      return false;
    }
  }

  /// Update user data
  Future<bool> updateUserData(UserModel user) async {
    try {
      final userData = {
        'name': user.name,
        'phone_number': user.phoneNumber,
        'secondary_phone_number': user.secondaryPhoneNumber,
        'nickname': user.nickname,
        'country': user.country,
        'business_name': user.businessName,
        'business_description': user.businessDescription,
        'whatsapp_number': user.whatsappNumber,
      };
      
      await _supabaseClient
          .from('users')
          .update(userData)
          .eq('id', user.id);
      
      return true;
    } catch (e) {
      _logger.e('Error updating user data: $e');
      return false;
    }
  }

  /// Get all users with pending status
  Future<List<UserModel>> getPendingUsers() async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('status', AppConstants.statusPending);
      
      return (response as List).map((json) => UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        role: json['role'],
        phoneNumber: json['phone_number'],
        secondaryPhoneNumber: json['secondary_phone_number'],
        nickname: json['nickname'],
        country: json['country'],
        status: json['status'],
        businessName: json['business_name'],
        businessDescription: json['business_description'],
        workingSolo: json['working_solo'],
        associateIds: json['associate_ids'],
        whatsappNumber: json['whatsapp_number'],
        createdAt: DateTime.parse(json['created_at']),
        acceptedAt: json['accepted_at'] != null 
            ? DateTime.parse(json['accepted_at']) 
            : null,
      )).toList();
    } catch (e) {
      _logger.e('Error getting pending users: $e');
      return [];
    }
  }

  /// Get all users with active status
  Future<List<UserModel>> getApprovedUsers() async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .or('status.eq.${AppConstants.statusActive},status.eq.${AppConstants.statusRejected}')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        role: json['role'],
        phoneNumber: json['phone_number'],
        secondaryPhoneNumber: json['secondary_phone_number'],
        nickname: json['nickname'],
        country: json['country'],
        status: json['status'],
        businessName: json['business_name'],
        businessDescription: json['business_description'],
        workingSolo: json['working_solo'],
        associateIds: json['associate_ids'],
        whatsappNumber: json['whatsapp_number'],
        createdAt: DateTime.parse(json['created_at']),
        acceptedAt: json['accepted_at'] != null 
            ? DateTime.parse(json['accepted_at']) 
            : null,
      )).toList();
    } catch (e) {
      _logger.e('Error getting approved users: $e');
      return [];
    }
  }
  
  /// Get blacklist entries
  Future<List<BlacklistModel>> getBlacklistEntries() async {
    try {
      final response = await _supabaseClient
          .from('blacklist')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => BlacklistModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting blacklist entries: $e');
      return [];
    }
  }
  
  /// Get primitive phone blocks
  Future<List<PrimitivePhoneBlockModel>> getPrimitivePhoneBlocks() async {
    try {
      final response = await _supabaseClient
          .from('primitive_phone_block')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => PrimitivePhoneBlockModel.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error getting primitive phone blocks: $e');
      return [];
    }
  }
  
  /// Add to blacklist
  Future<String> addToBlacklist({
    String? userId,
    String? email,
    String? phoneNumber,
    String? deviceId,
    required String reason,
  }) async {
    try {
      final response = await _supabaseClient
          .rpc('add_to_blacklist', params: {
            'p_user_id': userId,
            'p_email': email,
            'p_phone_number': phoneNumber,
            'p_device_id': deviceId,
            'p_reason': reason,
          });
      
      return response as String;
    } catch (e) {
      _logger.e('Error adding to blacklist: $e');
      throw 'Failed to add to blacklist: $e';
    }
  }
  
  /// Remove from blacklist
  Future<bool> removeFromBlacklist(String blacklistId) async {
    try {
      final response = await _supabaseClient
          .rpc('remove_from_blacklist', params: {
            'p_blacklist_id': blacklistId,
          });
      
      return response as bool;
    } catch (e) {
      _logger.e('Error removing from blacklist: $e');
      return false;
    }
  }
  
  /// Primitive block phone
  Future<bool> primitiveBlockPhone(String phoneNumber, String reason) async {
    try {
      final response = await _supabaseClient
          .rpc('primitive_block_phone', params: {
            'p_phone_number': phoneNumber,
            'p_reason': reason,
          });
      
      return response as bool;
    } catch (e) {
      _logger.e('Error blocking phone number: $e');
      return false;
    }
  }
  
  /// Primitive unblock phone
  Future<bool> primitiveUnblockPhone(String phoneNumber) async {
    try {
      final response = await _supabaseClient
          .rpc('primitive_unblock_phone', params: {
            'p_phone_number': phoneNumber,
          });
      
      return response as bool;
    } catch (e) {
      _logger.e('Error unblocking phone number: $e');
      return false;
    }
  }
  
  /// Check if phone is primitive blocked
  Future<bool> isPrimitiveBlocked(String phoneNumber) async {
    try {
      final response = await _supabaseClient
          .rpc('is_primitive_blocked', params: {
            'p_phone_number': phoneNumber,
          });
      
      return response as bool;
    } catch (e) {
      _logger.e('Error checking if phone is blocked: $e');
      return false;
    }
  }
}
