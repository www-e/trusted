import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/features/admin/domain/models/blacklist_model.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Service for caching and optimizing admin API calls
class AdminCacheService {
  /// Cache for pending users
  List<UserModel>? _pendingUsersCache;
  
  /// Cache for approved users
  List<UserModel>? _approvedUsersCache;
  
  /// Cache for blacklist entries
  List<BlacklistModel>? _blacklistEntriesCache;
  
  /// Cache for primitive phone blocks
  List<PrimitivePhoneBlockModel>? _primitivePhoneBlocksCache;
  
  /// Timestamp for pending users cache
  DateTime? _pendingUsersCacheTime;
  
  /// Timestamp for approved users cache
  DateTime? _approvedUsersCacheTime;
  
  /// Timestamp for blacklist entries cache
  DateTime? _blacklistEntriesCacheTime;
  
  /// Timestamp for primitive phone blocks cache
  DateTime? _primitivePhoneBlocksCacheTime;
  
  /// Cache expiration duration (5 minutes)
  final Duration _cacheDuration = const Duration(minutes: 5);
  
  /// Debounce timers for API calls
  final Map<String, Timer> _debounceTimers = {};
  
  /// Debounce duration
  final Duration _debounceDuration = const Duration(milliseconds: 300);

  /// Get pending users from cache if available and not expired
  List<UserModel>? getCachedPendingUsers() {
    if (_pendingUsersCache != null && _pendingUsersCacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_pendingUsersCacheTime!) < _cacheDuration) {
        return _pendingUsersCache;
      }
    }
    return null;
  }

  /// Get approved users from cache if available and not expired
  List<UserModel>? getCachedApprovedUsers() {
    if (_approvedUsersCache != null && _approvedUsersCacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_approvedUsersCacheTime!) < _cacheDuration) {
        return _approvedUsersCache;
      }
    }
    return null;
  }

  /// Update pending users cache
  void updatePendingUsersCache(List<UserModel> users) {
    _pendingUsersCache = users;
    _pendingUsersCacheTime = DateTime.now();
  }

  /// Update approved users cache
  void updateApprovedUsersCache(List<UserModel> users) {
    _approvedUsersCache = users;
    _approvedUsersCacheTime = DateTime.now();
  }

  /// Get blacklist entries from cache if available and not expired
  List<BlacklistModel>? getCachedBlacklistEntries() {
    if (_blacklistEntriesCache != null && _blacklistEntriesCacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_blacklistEntriesCacheTime!) < _cacheDuration) {
        return _blacklistEntriesCache;
      }
    }
    return null;
  }

  /// Get primitive phone blocks from cache if available and not expired
  List<PrimitivePhoneBlockModel>? getCachedPrimitivePhoneBlocks() {
    if (_primitivePhoneBlocksCache != null && _primitivePhoneBlocksCacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_primitivePhoneBlocksCacheTime!) < _cacheDuration) {
        return _primitivePhoneBlocksCache;
      }
    }
    return null;
  }

  /// Update blacklist entries cache
  void updateBlacklistEntriesCache(List<BlacklistModel> entries) {
    _blacklistEntriesCache = entries;
    _blacklistEntriesCacheTime = DateTime.now();
  }

  /// Update primitive phone blocks cache
  void updatePrimitivePhoneBlocksCache(List<PrimitivePhoneBlockModel> blocks) {
    _primitivePhoneBlocksCache = blocks;
    _primitivePhoneBlocksCacheTime = DateTime.now();
  }

  /// Clear all caches
  void clearCache() {
    _pendingUsersCache = null;
    _approvedUsersCache = null;
    _blacklistEntriesCache = null;
    _primitivePhoneBlocksCache = null;
    _pendingUsersCacheTime = null;
    _approvedUsersCacheTime = null;
    _blacklistEntriesCacheTime = null;
    _primitivePhoneBlocksCacheTime = null;
  }

  /// Invalidate pending users cache
  void invalidatePendingUsersCache() {
    _pendingUsersCache = null;
    _pendingUsersCacheTime = null;
  }

  /// Invalidate approved users cache
  void invalidateApprovedUsersCache() {
    _approvedUsersCache = null;
    _approvedUsersCacheTime = null;
  }
  
  /// Invalidate blacklist entries cache
  void invalidateBlacklistEntriesCache() {
    _blacklistEntriesCache = null;
    _blacklistEntriesCacheTime = null;
  }
  
  /// Invalidate primitive phone blocks cache
  void invalidatePrimitivePhoneBlocksCache() {
    _primitivePhoneBlocksCache = null;
    _primitivePhoneBlocksCacheTime = null;
  }

  /// Execute a function with debounce
  /// This prevents rapid API calls when user interacts with UI elements
  void debounce(String key, VoidCallback callback) {
    if (_debounceTimers.containsKey(key)) {
      _debounceTimers[key]?.cancel();
    }
    
    _debounceTimers[key] = Timer(_debounceDuration, callback);
  }
  
  /// Cancel all debounce timers
  void cancelDebounce() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }
  
  /// Dispose all resources
  void dispose() {
    cancelDebounce();
    clearCache();
  }
}

/// Provider for the AdminCacheService
final adminCacheServiceProvider = Provider<AdminCacheService>((ref) {
  final service = AdminCacheService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
