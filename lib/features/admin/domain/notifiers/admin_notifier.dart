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

  /// Constructor
  const AdminState({
    this.isLoading = false,
    this.errorMessage,
    this.pendingUsers = const [],
  });

  /// Creates a copy of this AdminState with the given fields replaced
  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? pendingUsers,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingUsers: pendingUsers ?? this.pendingUsers,
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

  /// Approve a user
  Future<void> approveUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final success = await _authRepository.updateUserStatus(
        userId, 
        AppConstants.statusActive,
      );
      
      if (success) {
        // Remove the approved user from the list
        final updatedUsers = [...state.pendingUsers];
        updatedUsers.removeWhere((user) => user.id == userId);
        
        state = state.copyWith(
          isLoading: false,
          pendingUsers: updatedUsers,
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
}

/// Provider for AdminState
final adminStateProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AdminNotifier(authRepository: authRepository);
});
