import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/features/auth/domain/services/storage_service.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';

/// Service for handling photo uploads during the signup process
class PhotoUploadService {
  final StorageService _storageService = StorageService();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  /// Singleton instance
  static final PhotoUploadService _instance = PhotoUploadService._internal();
  
  /// Private constructor
  PhotoUploadService._internal();
  
  /// Factory constructor to return the singleton instance
  factory PhotoUploadService() => _instance;
  
  /// Initialize the service
  Future<void> initialize() async {
    await _storageService.initialize();
  }
  
  /// Upload all required photos for a user with retry mechanism
  /// 
  /// Returns a map with the URLs of the uploaded photos
  Future<Map<String, String?>> uploadUserPhotos({
    required String userId,
    required File selfiePhoto,
    required File frontIdPhoto,
    required File backIdPhoto,
    int maxRetries = 3,
    Function(String message, double progress)? progressCallback,
  }) async {
    final Map<String, String?> results = {
      'selfie_photo_url': null,
      'front_id_photo_url': null,
      'back_id_photo_url': null,
    };
    
    try {
      // Update progress
      progressCallback?.call('جاري تحميل الصورة الشخصية...', 0.1);
      
      // Upload selfie photo with retry
      results['selfie_photo_url'] = await _uploadPhotoWithRetry(
        photoFile: selfiePhoto,
        userId: userId,
        photoType: 'selfie',
        maxRetries: maxRetries,
      );
      
      // Update progress
      progressCallback?.call('جاري تحميل صورة الهوية (الأمام)...', 0.4);
      
      // Upload front ID photo with retry
      results['front_id_photo_url'] = await _uploadPhotoWithRetry(
        photoFile: frontIdPhoto,
        userId: userId,
        photoType: 'front_id',
        maxRetries: maxRetries,
      );
      
      // Update progress
      progressCallback?.call('جاري تحميل صورة الهوية (الخلف)...', 0.7);
      
      // Upload back ID photo with retry
      results['back_id_photo_url'] = await _uploadPhotoWithRetry(
        photoFile: backIdPhoto,
        userId: userId,
        photoType: 'back_id',
        maxRetries: maxRetries,
      );
      
      // Final progress update
      progressCallback?.call('تم تحميل جميع الصور بنجاح', 1.0);
      
      return results;
    } catch (e) {
      debugPrint('Error uploading user photos: $e');
      // Add error message to results
      results['error'] = e.toString();
      return results;
    }
  }
  
  /// Upload a photo with retry mechanism
  Future<String?> _uploadPhotoWithRetry({
    required File photoFile,
    required String userId,
    required String photoType,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastException;
    
    // Optimize image before upload
    File optimizedFile = photoFile;
    try {
      if (await photoFile.length() > 1024 * 1024) { // If larger than 1MB
        optimizedFile = await compute(PerformanceUtils.compressImageIsolate, photoFile);
      }
    } catch (e) {
      debugPrint('Error optimizing image: $e');
      // Continue with original file if optimization fails
    }
    
    while (attempts < maxRetries) {
      try {
        // Add exponential backoff delay after first attempt
        if (attempts > 0) {
          final backoffMs = 1000 * (attempts * attempts); // Exponential backoff
          await Future.delayed(Duration(milliseconds: backoffMs));
        }
        
        attempts++;
        String? result;
        
        // Call the appropriate upload method based on photo type
        switch (photoType) {
          case 'selfie':
            result = await _storageService.uploadSelfiePhoto(optimizedFile, userId);
            break;
          case 'front_id':
            result = await _storageService.uploadFrontIdPhoto(optimizedFile, userId);
            break;
          case 'back_id':
            result = await _storageService.uploadBackIdPhoto(optimizedFile, userId);
            break;
          default:
            throw Exception('Invalid photo type: $photoType');
        }
        
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('Upload attempt $attempts for $photoType failed: $e');
      }
    }
    
    // All attempts failed
    throw lastException ?? Exception('Failed to upload $photoType photo after $maxRetries attempts');
  }
  
  /// Create a user record in the database with photo URLs
  Future<void> createUserWithPhotos({
    required Map<String, dynamic> userData,
    required Map<String, String?> photoUrls,
  }) async {
    try {
      // Merge user data with photo URLs
      final completeUserData = {
        ...userData,
        'selfie_photo_url': photoUrls['selfie_photo_url'],
        'front_id_photo_url': photoUrls['front_id_photo_url'],
        'back_id_photo_url': photoUrls['back_id_photo_url'],
      };
      
      // Insert user data into the database
      await _supabaseClient.from('users').upsert(completeUserData);
    } catch (e) {
      debugPrint('Error creating user with photos: $e');
      rethrow;
    }
  }
  
  /// Clean up temporary photos if signup fails
  Future<void> cleanupPhotos(Map<String, String?> photoUrls) async {
    try {
      // Delete each photo URL if it exists
      for (final url in photoUrls.values) {
        if (url != null) {
          await _storageService.deleteUserPhoto(url);
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up photos: $e');
      // Don't rethrow, as this is a cleanup operation
    }
  }
}
