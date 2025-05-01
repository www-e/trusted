import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/models/enhanced_signup_form_model.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';
import 'package:trusted/features/auth/domain/repositories/auth_repository.dart';

/// Auth state
class AuthState {
  /// Loading state
  final bool isLoading;
  
  /// Error message
  final String? errorMessage;
  
  /// Current user model
  final UserModel? user;
  
  /// User exists in database
  final bool userExists;
  
  /// Constructor
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
    this.userExists = false,
  });

  /// Creates a copy of this AuthState with the given fields replaced
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    bool? userExists,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
      userExists: userExists ?? this.userExists,
    );
  }
}

/// Auth notifier to manage authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  /// Auth repository
  final AuthRepository _authRepository;

  /// Constructor
  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

  /// Get the current authenticated user
  User? get currentUser => _authRepository.currentUser;

  /// Initialize auth state
  Future<void> initAuthState() async {
    state = state.copyWith(isLoading: true);
    
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      final userData = await _authRepository.getUserData(currentUser.id);
      state = state.copyWith(
        isLoading: false,
        user: userData,
        userExists: userData != null,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final credential = await _authRepository.signInWithGoogle();
      final userExists = await _authRepository.checkUserExists(credential.user.email!);
      
      // Check if this is the admin email
      final isAdmin = credential.user.email == AppConstants.adminEmail;
      
      // Special handling for admin with specific UID
      final isSpecificAdminUID = credential.user.id == 'b5d8fad3-d815-434d-bc90-3b0157317a20';
      
      if (isSpecificAdminUID && isAdmin) {
        // For the specific admin UID, we'll always get the user data
        // The repository has special handling for this UID
        final userData = await _authRepository.getUserData(credential.user.id);
        
        state = state.copyWith(
          isLoading: false,
          user: userData,
          userExists: true,
          errorMessage: null,
        );
      } else if (userExists) {
        final userData = await _authRepository.getUserData(credential.user.id);
        
        // Always set user data if it exists, regardless of status
        state = state.copyWith(
          isLoading: false,
          user: userData,
          userExists: true,
          errorMessage: null,
        );
        
        // If this is the admin email, we don't need to check the user data
        // This allows the admin to sign in even if they don't have a user record yet
        if (isAdmin && userData == null) {
          state = state.copyWith(userExists: true);
        }
      } else if (isAdmin) {
        // For admin, create a user record if it doesn't exist
        state = state.copyWith(
          isLoading: false,
          userExists: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          userExists: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sign in with email (for admin)
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      if (email != AppConstants.adminEmail) {
        throw 'Only admin can sign in with email';
      }
      
      final credential = await _authRepository.signInWithEmail(email, password);
      final userData = await _authRepository.getUserData(credential.user.id);
      
      state = state.copyWith(
        isLoading: false,
        user: userData,
        userExists: userData != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// Sign in with username and password
  Future<void> signInWithUsername(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final credential = await _authRepository.signInWithUsername(username, password);
      final userData = await _authRepository.getUserData(credential.user.id);
      
      if (userData == null) {
        throw 'User data not found';
      }
      
      // Check user status
      if (userData.isRejected) {
        state = state.copyWith(
          isLoading: false,
          user: userData,
          userExists: true,
        );
        return;
      }
      
      if (userData.isPending) {
        state = state.copyWith(
          isLoading: false,
          user: userData,
          userExists: true,
        );
        return;
      }
      
      state = state.copyWith(
        isLoading: false,
        user: userData,
        userExists: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _authRepository.signOut();
      
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create new user
  Future<void> createUser(EnhancedSignupFormModel formData) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final userData = await _authRepository.createUser(formData);
      
      state = state.copyWith(
        isLoading: false,
        user: userData,
        userExists: userData != null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final success = await _authRepository.updateUserStatus(userId, status);
      
      if (success) {
        final userData = await _authRepository.getUserData(userId);
        state = state.copyWith(
          isLoading: false,
          user: userData,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update user status',
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

/// Provider for AuthState
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: authRepository);
});
