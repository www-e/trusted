import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/admin/domain/models/blacklist_model.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';
import 'package:trusted/features/admin/domain/services/admin_cache_service.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';
import 'package:trusted/features/auth/domain/repositories/auth_repository.dart';

/// Admin state
class AdminState {
  /// Loading state
  final bool isLoading;
  
  /// Error message
  final String? errorMessage;
  
  /// List of pending users
  final List<UserModel> pendingUsers;
  
  /// List of approved users (history)
  final List<UserModel> approvedUsers;
  
  /// Count of users approved today
  final int approvedTodayCount;
  
  /// List of blacklist entries
  final List<BlacklistModel> blacklistEntries;
  
  /// List of primitive phone blocks
  final List<PrimitivePhoneBlockModel> primitivePhoneBlocks;
  
  /// Search query for filtering
  final String searchQuery;
  
  /// Is loading blacklist data
  final bool isLoadingBlacklist;

  /// Constructor
  const AdminState({
    this.isLoading = false,
    this.errorMessage,
    this.pendingUsers = const [],
    this.approvedUsers = const [],
    this.approvedTodayCount = 0,
    this.blacklistEntries = const [],
    this.primitivePhoneBlocks = const [],
    this.searchQuery = '',
    this.isLoadingBlacklist = false,
  });

  /// Creates a copy of this AdminState with the given fields replaced
  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? pendingUsers,
    List<UserModel>? approvedUsers,
    int? approvedTodayCount,
    List<BlacklistModel>? blacklistEntries,
    List<PrimitivePhoneBlockModel>? primitivePhoneBlocks,
    String? searchQuery,
    bool? isLoadingBlacklist,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      approvedUsers: approvedUsers ?? this.approvedUsers,
      approvedTodayCount: approvedTodayCount ?? this.approvedTodayCount,
      blacklistEntries: blacklistEntries ?? this.blacklistEntries,
      primitivePhoneBlocks: primitivePhoneBlocks ?? this.primitivePhoneBlocks,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingBlacklist: isLoadingBlacklist ?? this.isLoadingBlacklist,
    );
  }
  
  /// Get filtered blacklist entries based on search query
  List<BlacklistModel> get filteredBlacklistEntries {
    if (searchQuery.isEmpty) {
      return blacklistEntries;
    }
    
    final query = searchQuery.toLowerCase();
    return blacklistEntries.where((entry) {
      return (entry.userId != null && entry.userId!.toLowerCase().contains(query)) ||
             (entry.email != null && entry.email!.toLowerCase().contains(query)) ||
             (entry.phoneNumber != null && entry.phoneNumber!.toLowerCase().contains(query)) ||
             (entry.deviceId != null && entry.deviceId!.toLowerCase().contains(query)) ||
             entry.reason.toLowerCase().contains(query);
    }).toList();
  }
  
  /// Get filtered primitive phone blocks based on search query
  List<PrimitivePhoneBlockModel> get filteredPrimitivePhoneBlocks {
    if (searchQuery.isEmpty) {
      return primitivePhoneBlocks;
    }
    
    final query = searchQuery.toLowerCase();
    return primitivePhoneBlocks.where((block) {
      return block.phoneNumber.toLowerCase().contains(query) ||
             block.reason.toLowerCase().contains(query);
    }).toList();
  }
}

/// Admin notifier to manage admin functionality
class AdminNotifier extends StateNotifier<AdminState> {
  /// Auth repository
  final AuthRepository _authRepository;
  
  /// Cache service
  final AdminCacheService _cacheService;
  
  /// Logger instance
  final _logger = Logger();

  /// Constructor
  AdminNotifier({
    required AuthRepository authRepository,
    required AdminCacheService cacheService,
  })
      : _authRepository = authRepository,
        _cacheService = cacheService,
        super(const AdminState());

  /// Load pending users
  Future<void> loadPendingUsers() async {
    try {
      // Check cache first
      final cachedUsers = _cacheService.getCachedPendingUsers();
      if (cachedUsers != null) {
        state = state.copyWith(
          pendingUsers: cachedUsers,
          isLoading: false,
          errorMessage: null,
        );
        return;
      }
      
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final pendingUsers = await _authRepository.getPendingUsers();
      
      // Update cache
      _cacheService.updatePendingUsersCache(pendingUsers);
      
      state = state.copyWith(
        isLoading: false,
        pendingUsers: pendingUsers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Load approved users (for history)
  Future<void> loadApprovedUsers() async {
    try {
      // Check cache first
      final cachedUsers = _cacheService.getCachedApprovedUsers();
      if (cachedUsers != null) {
        // Calculate how many users were approved today
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        
        final approvedToday = cachedUsers.where((user) {
          return user.acceptedAt?.isAfter(startOfDay) ?? false;
        }).length;
        
        state = state.copyWith(
          approvedUsers: cachedUsers,
          approvedTodayCount: approvedToday,
          isLoading: false,
          errorMessage: null,
        );
        return;
      }
      
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final approvedUsers = await _authRepository.getApprovedUsers();
      
      // Calculate how many users were approved today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final approvedToday = approvedUsers.where((user) {
        // Check if the user was approved today using acceptedAt field
        return user.acceptedAt?.isAfter(startOfDay) ?? false;
      }).length;
      
      // Update cache
      _cacheService.updateApprovedUsersCache(approvedUsers);
      
      state = state.copyWith(
        isLoading: false,
        approvedUsers: approvedUsers,
        approvedTodayCount: approvedToday,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Approve a user
  Future<void> approveUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final success = await _authRepository.updateUserStatus(
        userId, 
        AppConstants.statusActive,
      );
      
      if (success) {
        // Get the user that was approved
        final approvedUser = state.pendingUsers.firstWhere((user) => user.id == userId);
        
        // Remove the approved user from the pending list
        final updatedPendingUsers = [...state.pendingUsers];
        updatedPendingUsers.removeWhere((user) => user.id == userId);
        
        // Add the approved user to the approved list with updated status and acceptedAt
        final now = DateTime.now();
        final updatedApprovedUsers = [...state.approvedUsers, 
          approvedUser.copyWith(
            status: AppConstants.statusActive,
            acceptedAt: now,
          )
        ];
        
        // Increment the approved today count if the user was approved today
        final today = now;
        final startOfDay = DateTime(today.year, today.month, today.day);
        final approvedTodayCount = state.approvedTodayCount + 1; // Always increment since we just approved
        
        // Update caches
        _cacheService.updatePendingUsersCache(updatedPendingUsers);
        _cacheService.updateApprovedUsersCache(updatedApprovedUsers);
        
        state = state.copyWith(
          isLoading: false,
          pendingUsers: updatedPendingUsers,
          approvedUsers: updatedApprovedUsers,
          approvedTodayCount: approvedTodayCount,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحديث حالة المستخدم',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Reject a user
  Future<void> rejectUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final success = await _authRepository.updateUserStatus(
        userId, 
        AppConstants.statusRejected,
      );
      
      if (success) {
        // Get the user that was rejected
        final rejectedUser = state.pendingUsers.firstWhere((user) => user.id == userId);
        
        // Remove the rejected user from the pending list
        final updatedPendingUsers = [...state.pendingUsers];
        updatedPendingUsers.removeWhere((user) => user.id == userId);
        
        // Add the rejected user to the history list with updated status
        final updatedApprovedUsers = [...state.approvedUsers, 
          rejectedUser.copyWith(status: AppConstants.statusRejected)
        ];
        
        // Update caches
        _cacheService.updatePendingUsersCache(updatedPendingUsers);
        _cacheService.updateApprovedUsersCache(updatedApprovedUsers);
        
        state = state.copyWith(
          isLoading: false,
          pendingUsers: updatedPendingUsers,
          approvedUsers: updatedApprovedUsers,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحديث حالة المستخدم',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Initialize admin state
  Future<void> initAdminState() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Load both pending and approved users
      await loadPendingUsers();
      await loadApprovedUsers();
      
      // Load blacklist data
      await loadBlacklistData();
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update user data
  Future<bool> updateUserData(UserModel updatedUser) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final success = await _authRepository.updateUserData(updatedUser);
      
      if (success) {
        // Update user in pending users list if present
        final updatedPendingUsers = state.pendingUsers.map((user) {
          if (user.id == updatedUser.id) {
            return updatedUser;
          }
          return user;
        }).toList();
        
        // Update user in approved users list if present
        final updatedApprovedUsers = state.approvedUsers.map((user) {
          if (user.id == updatedUser.id) {
            return updatedUser;
          }
          return user;
        }).toList();
        
        // Update caches
        _cacheService.updatePendingUsersCache(updatedPendingUsers);
        _cacheService.updateApprovedUsersCache(updatedApprovedUsers);
        
        state = state.copyWith(
          isLoading: false,
          pendingUsers: updatedPendingUsers,
          approvedUsers: updatedApprovedUsers,
        );
        
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحديث بيانات المستخدم',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  
  /// Load blacklist data
  Future<void> loadBlacklistData() async {
    try {
      state = state.copyWith(isLoadingBlacklist: true, errorMessage: null);
      
      // Try to get from cache first
      final cachedBlacklist = _cacheService.getCachedBlacklistEntries();
      final cachedPhoneBlocks = _cacheService.getCachedPrimitivePhoneBlocks();
      
      if ((cachedBlacklist?.isNotEmpty ?? false) || (cachedPhoneBlocks?.isNotEmpty ?? false)) {
        state = state.copyWith(
          blacklistEntries: cachedBlacklist,
          primitivePhoneBlocks: cachedPhoneBlocks,
          isLoadingBlacklist: false,
        );
      }
      
      // Load blacklist entries
      final blacklistEntries = await _authRepository.getBlacklistEntries();
      
      // Load primitive phone blocks
      final primitivePhoneBlocks = await _authRepository.getPrimitivePhoneBlocks();
      
      // Update cache
      _cacheService.updateBlacklistEntriesCache(blacklistEntries);
      _cacheService.updatePrimitivePhoneBlocksCache(primitivePhoneBlocks);
      
      state = state.copyWith(
        blacklistEntries: blacklistEntries,
        primitivePhoneBlocks: primitivePhoneBlocks,
        isLoadingBlacklist: false,
      );
    } catch (e) {
      _logger.e('Error loading blacklist data: $e');
      state = state.copyWith(
        isLoadingBlacklist: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Block a user and their device
  Future<void> blockUser(String userId, String reason) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Get user data to get phone number
      final userData = await _authRepository.getUserData(userId);
      
      if (userData == null) {
        throw 'User data not found';
      }
      
      // Add to blacklist
      await _authRepository.addToBlacklist(
        userId: userId,
        email: userData.email,
        phoneNumber: userData.phoneNumber,
        reason: reason,
      );
      
      // Refresh blacklist data
      await loadBlacklistData();
      
      // Refresh user lists
      await loadPendingUsers();
      await loadApprovedUsers();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _logger.e('Error blocking user: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Block a phone number
  Future<void> blockPhoneNumber(String phoneNumber, String reason) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Add to primitive phone block
      await _authRepository.primitiveBlockPhone(phoneNumber, reason);
      
      // Refresh blacklist data
      await loadBlacklistData();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _logger.e('Error blocking phone number: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Unblock a phone number
  Future<void> unblockPhoneNumber(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Remove from primitive phone block
      await _authRepository.primitiveUnblockPhone(phoneNumber);
      
      // Refresh blacklist data
      await loadBlacklistData();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _logger.e('Error unblocking phone number: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Remove from blacklist
  Future<void> removeFromBlacklist(String blacklistId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Remove from blacklist
      await _authRepository.removeFromBlacklist(blacklistId);
      
      // Refresh blacklist data
      await loadBlacklistData();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _logger.e('Error removing from blacklist: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

/// Provider for AdminState
final adminStateProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final cacheService = ref.watch(adminCacheServiceProvider);
  return AdminNotifier(
    authRepository: authRepository,
    cacheService: cacheService,
  );
});
