import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/models/enhanced_signup_form_model.dart';
import 'package:trusted/features/auth/domain/services/photo_upload_service.dart';
import 'package:trusted/features/auth/domain/services/storage_service.dart';

/// Service for handling user creation during the multi-step signup process
class UserCreationService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final PhotoUploadService _photoUploadService = PhotoUploadService();
  
  /// Singleton instance
  static final UserCreationService _instance = UserCreationService._internal();
  
  /// Private constructor
  UserCreationService._internal();
  
  /// Factory constructor to return the singleton instance
  factory UserCreationService() => _instance;
  
  /// Create initial user record after contact info step (step 3)
  /// This creates the user in the database with basic information using a secure function
  /// that bypasses constraints for the initial creation
  Future<String> createInitialUserRecord(EnhancedSignupFormModel formData) async {
    try {
      // Get the current user ID from Supabase Auth
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Use the create_initial_user function to create the user record
      // This function handles the constraints properly without needing placeholders
      final result = await _supabaseClient.rpc(
        'create_initial_user',
        params: {
          'user_id': user.id,
          'user_email': formData.email,
          'user_name': formData.name,
          'user_role': formData.role,
          'user_phone_number': formData.phoneNumber,
          'user_whatsapp_number': formData.whatsappNumber,
          'user_vodafone_cash_number': formData.vodafoneCashNumber,
          'user_nickname': formData.nickname,
          'user_country': formData.country,
          'user_username': null, // Will be set in a later step
        },
      );
      
      debugPrint('Initial user record created successfully: ${user.id}');
      return user.id;
      
    } catch (e) {
      debugPrint('Error creating initial user record: $e');
      rethrow;
    }
  }
  
  /// Upload user photos and update the user record (step 4)
  Future<Map<String, String?>> uploadUserPhotos({
    required String userId,
    required File selfiePhoto,
    required File frontIdPhoto,
    required File backIdPhoto,
  }) async {
    try {
      // Initialize the storage service
      await _photoUploadService.initialize();
      
      // Upload the photos
      final photoUrls = await _photoUploadService.uploadUserPhotos(
        userId: userId,
        selfiePhoto: selfiePhoto,
        frontIdPhoto: frontIdPhoto,
        backIdPhoto: backIdPhoto,
      );
      
      // Use the update_user_photos function to update the user record
      // This function handles the constraints properly
      await _supabaseClient.rpc(
        'update_user_photos',
        params: {
          'user_id': userId,
          'selfie_url': photoUrls['selfie_photo_url'],
          'front_id_url': photoUrls['front_id_photo_url'],
          'back_id_url': photoUrls['back_id_photo_url'],
        },
      );
      
      debugPrint('User photos uploaded and record updated: $userId');
      return photoUrls;
      
    } catch (e) {
      debugPrint('Error uploading user photos: $e');
      rethrow;
    }
  }
  
  /// Update user credentials (username and password) (final step)
  Future<void> updateUserCredentials({
    required String userId,
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Starting user credentials update for userId: $userId');
      
      // First, verify the username is not already taken
      final usernameCheck = await _supabaseClient
          .from('users')
          .select('id')
          .eq('username', username)
          .neq('id', userId) // Exclude current user
          .maybeSingle();
      
      if (usernameCheck != null) {
        debugPrint('Username $username is already taken by another user');
        throw Exception('اسم المستخدم مستخدم بالفعل');
      }
      
      debugPrint('Username $username is available, updating user record');
      
      // Update the username in the database
      await _supabaseClient.from('users').update({
        'username': username,
      }).eq('id', userId);
      
      debugPrint('Username updated successfully in database');
      
      // Get the user's email from the database
      final userResponse = await _supabaseClient
          .from('users')
          .select('email')
          .eq('id', userId)
          .single();
      
      final email = userResponse['email'] as String;
      debugPrint('Retrieved email for user: $email');
      
      // Update the password in Supabase Auth
      // This is necessary because the password needs to be associated with the auth account
      final updateResponse = await _supabaseClient.auth.updateUser(
        UserAttributes(password: password),
      );
      
      if (updateResponse.user != null) {
        debugPrint('Password updated successfully in Supabase Auth');
      } else {
        debugPrint('Warning: Password update may have failed, no user returned');
      }
      
      // Verify the username was saved correctly
      final verifyUpdate = await _supabaseClient
          .from('users')
          .select('username')
          .eq('id', userId)
          .single();
      
      final savedUsername = verifyUpdate['username'] as String?;
      if (savedUsername != username) {
        debugPrint('Warning: Username verification failed. Expected: $username, Got: $savedUsername');
      } else {
        debugPrint('Username verification successful: $savedUsername');
      }
      
      debugPrint('User credentials updated successfully: $userId');
      
    } catch (e) {
      debugPrint('Error updating user credentials: $e');
      rethrow;
    }
  }
  
  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
  
  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final user = await getUserById(userId);
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
