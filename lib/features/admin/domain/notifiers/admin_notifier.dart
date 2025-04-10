import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
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

  /// Constructor
  const AdminState({
    this.isLoading = false,
    this.errorMessage,
    this.pendingUsers = const [],
    this.approvedUsers = const [],
    this.approvedTodayCount = 0,
  });

  /// Creates a copy of this AdminState with the given fields replaced
  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? pendingUsers,
    List<UserModel>? approvedUsers,
    int? approvedTodayCount,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      approvedUsers: approvedUsers ?? this.approvedUsers,
      approvedTodayCount: approvedTodayCount ?? this.approvedTodayCount,
    );
  }
}

/// Admin notifier to manage admin functionality
class AdminNotifier extends StateNotifier<AdminState> {
  /// Auth repository
  final AuthRepository _authRepository;

  /// Constructor
  AdminNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AdminState());

  /// Load pending users
  Future<void> loadPendingUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final pendingUsers = await _authRepository.getPendingUsers();
      
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
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final approvedUsers = await _authRepository.getApprovedUsers();
      
      // Calculate how many users were approved today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final approvedToday = approvedUsers.where((user) {
        // Check if the user was approved today
        // In a real app, you would have an 'approved_at' field
        // For now, we'll use createdAt as a proxy
        return user.createdAt.isAfter(startOfDay);
      }).length;
      
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
        
        // Add the approved user to the approved list
        final updatedApprovedUsers = [...state.approvedUsers, approvedUser.copyWith(status: AppConstants.statusActive)];
        
        // Increment the approved today count if the user was approved today
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final approvedTodayCount = state.approvedTodayCount + 
            (approvedUser.createdAt.isAfter(startOfDay) ? 1 : 0);
        
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
        
        // Add the rejected user to the rejected list (we'll show this in the history)
        final updatedApprovedUsers = [...state.approvedUsers, rejectedUser.copyWith(status: AppConstants.statusRejected)];
        
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
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Provider for AdminState
final adminStateProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AdminNotifier(authRepository: authRepository);
});
