import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gotrue/src/types/types.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/config/env_config.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/models/signup_form_model.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Authentication provider enum
enum AuthProvider {
  /// Google authentication provider
  google,
  
  /// Email authentication provider
  email
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
         // Use serverClientId instead of clientId for Android
         serverClientId: Platform.isAndroid 
             ? EnvConfig.googleClientIdAndroid 
             : null,
         clientId: Platform.isIOS
             ? EnvConfig.googleClientIdIos
             : null,
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign-in was cancelled by the user';
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final AuthResponse response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (response.session == null) {
        throw 'Failed to sign in with Google';
      }
      
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

  /// Sign in with email and password (for admin)
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse response = 
          await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw 'Failed to sign in with email and password';
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
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      if (response == null) {
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
  Future<UserModel?> createUser(SignupFormModel formData) async {
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
      await _supabaseClient
          .from('users')
          .update({'status': status})
          .eq('id', userId);
      
      return true;
    } catch (e) {
      _logger.e('Error updating user status: $e');
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
      )).toList();
    } catch (e) {
      _logger.e('Error getting pending users: $e');
      return [];
    }
  }
}
