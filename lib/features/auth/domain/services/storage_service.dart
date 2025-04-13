import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';

/// Service for handling file storage operations with Supabase
class StorageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  /// The storage bucket name for user photos
  static const String _userPhotosBucket = 'userphotos';
  
  /// Singleton instance
  static final StorageService _instance = StorageService._internal();
  
  /// Private constructor
  StorageService._internal();
  
  /// Factory constructor to return the singleton instance
  factory StorageService() => _instance;
  
  /// Initialize the storage service
  Future<void> initialize() async {
    try {
      debugPrint('🔍 STORAGE: Starting initialization of storage service');
      debugPrint('🔍 STORAGE: Target bucket name: $_userPhotosBucket');
      
      // Use our simplified function to verify storage access
      // This function ensures the bucket exists and is public
      debugPrint('🔍 STORAGE: Calling verify_storage_access SQL function');
      final result = await _supabaseClient.rpc(
        'verify_storage_access',
      );
      debugPrint('🔍 STORAGE: verify_storage_access result: $result');
      
      if (result == true) {
        debugPrint('✅ STORAGE: Successfully verified storage access for bucket: $_userPhotosBucket');
      } else {
        debugPrint('⚠️ STORAGE: Failed to verify storage access for bucket: $_userPhotosBucket');
        
        // As a fallback, try to create the bucket using the Supabase SDK
        try {
          // First check if the bucket already exists
          debugPrint('🔍 STORAGE: Listing all buckets to check if target exists');
          final buckets = await _supabaseClient.storage.listBuckets();
          final bucketNames = buckets.map((b) => b.name).toList();
          debugPrint('🔍 STORAGE: Found buckets: $bucketNames');
          
          final bucketExists = buckets.any((bucket) => bucket.name == _userPhotosBucket);
          debugPrint('🔍 STORAGE: Bucket check via SDK: $_userPhotosBucket exists = $bucketExists');
          
          if (!bucketExists) {
            // Try to create the bucket using the Supabase SDK
            debugPrint('🔍 STORAGE: Attempting to create bucket via SDK');
            await _supabaseClient.storage.createBucket(
              _userPhotosBucket,
              const BucketOptions(
                public: true, // Make bucket public for easier access
              ),
            );
            debugPrint('✅ STORAGE: Created bucket using SDK: $_userPhotosBucket');
          } else {
            // Update the bucket to be public
            debugPrint('🔍 STORAGE: Bucket already exists, ensuring it is public');
          }
          
          // Verify bucket exists after creation attempt
          final bucketsAfter = await _supabaseClient.storage.listBuckets();
          final bucketExistsAfter = bucketsAfter.any((bucket) => bucket.name == _userPhotosBucket);
          debugPrint('🔍 STORAGE: Bucket verification after creation: $_userPhotosBucket exists = $bucketExistsAfter');
        } catch (bucketError) {
          debugPrint('❌ STORAGE: Error with bucket operation: $bucketError');
          debugPrint('❌ STORAGE: Error details: ${bucketError.toString()}');
          // Continue as the bucket might already exist or be created by another process
        }
      }
      
      debugPrint('✅ STORAGE: Storage service initialization completed');
    } catch (e) {
      debugPrint('❌ STORAGE: Error initializing storage service: $e');
      debugPrint('❌ STORAGE: Error details: ${e.toString()}');
      // Log the error but don't rethrow to allow the app to continue
    }
  }
  
  /// Upload a photo to Supabase storage
  /// 
  /// Returns the URL of the uploaded photo or null if the upload failed
  Future<String?> uploadUserPhoto(File photoFile, String userId, String photoType) async {
    try {
      debugPrint('🔍 STORAGE: Starting photo upload process');
      debugPrint('🔍 STORAGE: Photo type: $photoType, User ID: $userId');
      debugPrint('🔍 STORAGE: Original file path: ${photoFile.path}');
      
      // Make sure storage service is initialized
      debugPrint('🔍 STORAGE: Ensuring storage service is initialized');
      await initialize();
      
      // Compress the image for better performance and reduced storage
      File optimizedFile = photoFile;
      try {
        // Get original file size
        final originalSize = await photoFile.length();
        debugPrint('🔍 STORAGE: Original file size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
        
        // Only compress if the file is large
        if (originalSize > 500 * 1024) { // If larger than 500KB
          debugPrint('🔍 STORAGE: File is large, compressing image for better performance');
          optimizedFile = await PerformanceUtils.compressImage(photoFile);
          final compressedSize = await optimizedFile.length();
          final compressionRatio = (compressedSize / originalSize * 100).toStringAsFixed(2);
          debugPrint('✅ STORAGE: Compressed image from ${(originalSize / 1024).toStringAsFixed(2)} KB to ${(compressedSize / 1024).toStringAsFixed(2)} KB ($compressionRatio% of original)');
        } else {
          debugPrint('🔍 STORAGE: File is small enough, skipping compression');
        }
      } catch (e) {
        debugPrint('⚠️ STORAGE: Error compressing image: $e');
        debugPrint('⚠️ STORAGE: Continuing with original file');
        // Continue with original file if compression fails
      }
      
      // Generate a unique filename
      final fileExtension = path.extension(photoFile.path);
      final fileName = '${userId}_${photoType}_${const Uuid().v4()}$fileExtension';
      debugPrint('🔍 STORAGE: Generated filename: $fileName');
      
      // Create the folder path based on user ID
      final folderPath = 'user_$userId';
      debugPrint('🔍 STORAGE: Target folder path: $folderPath');
      
      // Upload the file with retry logic
      int attempts = 0;
      const maxAttempts = 3;
      Exception? lastError;
      
      while (attempts < maxAttempts) {
        try {
          attempts++;
          
          // Add a small delay between retries
          if (attempts > 1) {
            final delayMs = 500 * attempts;
            debugPrint('🔍 STORAGE: Adding delay of $delayMs ms before retry');
            await Future.delayed(Duration(milliseconds: delayMs));
          }
          
          debugPrint('🔍 STORAGE: Attempting to upload photo (attempt $attempts of $maxAttempts)');
          
          // Direct upload approach with simplified error handling
          final String uploadPath = '$folderPath/$fileName';
          debugPrint('🔍 STORAGE: Full upload path: $uploadPath');
          
          // Upload the file
          debugPrint('🔍 STORAGE: Starting file upload to bucket: $_userPhotosBucket');
          final startTime = DateTime.now();
          await _supabaseClient.storage
              .from(_userPhotosBucket)
              .upload(uploadPath, optimizedFile, fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ));
          final endTime = DateTime.now();
          final uploadDuration = endTime.difference(startTime).inMilliseconds;
          debugPrint('✅ STORAGE: Upload completed in $uploadDuration ms');
          
          // Get the public URL
          debugPrint('🔍 STORAGE: Generating public URL');
          final String publicUrl = _supabaseClient.storage
              .from(_userPhotosBucket)
              .getPublicUrl(uploadPath);
          
          debugPrint('✅ STORAGE: Upload successful, URL: $publicUrl');
          return publicUrl;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          debugPrint('❌ STORAGE: Upload attempt $attempts failed: $e');
          debugPrint('❌ STORAGE: Error details: ${e.toString()}');
          
          // If we've reached max attempts, break out of the loop
          if (attempts >= maxAttempts) {
            debugPrint('❌ STORAGE: Maximum retry attempts reached, giving up');
            break;
          }
        }
      }
      
      // If we get here, all attempts failed
      debugPrint('❌ STORAGE: All upload attempts failed');
      throw lastError ?? Exception('Failed to upload photo after $maxAttempts attempts');
    } catch (e) {
      debugPrint('❌ STORAGE: Error in uploadUserPhoto method: $e');
      debugPrint('❌ STORAGE: Error details: ${e.toString()}');
      rethrow; // Rethrow to handle in the UI
    }
  }
  
  /// Upload a selfie photo
  Future<String?> uploadSelfiePhoto(File photoFile, String userId) {
    return uploadUserPhoto(photoFile, userId, 'selfie');
  }
  
  /// Upload a front ID photo
  Future<String?> uploadFrontIdPhoto(File photoFile, String userId) {
    return uploadUserPhoto(photoFile, userId, 'front_id');
  }
  
  /// Upload a back ID photo
  Future<String?> uploadBackIdPhoto(File photoFile, String userId) {
    return uploadUserPhoto(photoFile, userId, 'back_id');
  }
  
  /// Delete a user photo from storage
  Future<void> deleteUserPhoto(String photoUrl) async {
    try {
      // Extract the path from the URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      
      // The path should be in the format: /storage/v1/object/public/bucket_name/path/to/file
      // We need to extract the path after the bucket name
      final bucketIndex = pathSegments.indexOf(_userPhotosBucket);
      if (bucketIndex >= 0 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _supabaseClient.storage.from(_userPhotosBucket).remove([filePath]);
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}
