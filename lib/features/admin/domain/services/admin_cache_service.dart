import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Service for caching and optimizing admin API calls
class AdminCacheService {
  /// Cache for pending users
  List<UserModel>? _pendingUsersCache;
  
  /// Cache for approved users
  List<UserModel>? _approvedUsersCache;
  
  /// Timestamp for pending users cache
  DateTime? _pendingUsersCacheTime;
  
  /// Timestamp for approved users cache
  DateTime? _approvedUsersCacheTime;
  
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

  /// Clear all caches
  void clearCache() {
    _pendingUsersCache = null;
    _approvedUsersCache = null;
    _pendingUsersCacheTime = null;
    _approvedUsersCacheTime = null;
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
