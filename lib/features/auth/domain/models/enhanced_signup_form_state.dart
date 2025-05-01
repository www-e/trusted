import 'package:flutter/foundation.dart';
import 'package:trusted/features/auth/domain/models/enhanced_signup_form_model.dart';

/// Enum to track the user creation status during the multi-step signup process
enum UserCreationStatus {
  /// User record has not been created yet
  notStarted,
  
  /// Initial user record created after contact info step
  initialRecordCreated,
  
  /// Photos uploaded and user record updated
  photosUploaded,
  
  /// Username and password set, signup complete
  completed
}

/// Enhanced sign-up form state
class EnhancedSignupFormState {
  /// Current step in the sign-up process
  final int currentStep;
  
  /// Form data
  final EnhancedSignupFormModel formData;
  
  /// Loading state for async operations
  final bool isLoading;
  
  /// Error message if any
  final String? errorMessage;
  
  /// User creation status
  final UserCreationStatus userCreationStatus;
  
  /// Constructor
  const EnhancedSignupFormState({
    this.currentStep = 1,
    required this.formData,
    this.isLoading = false,
    this.errorMessage,
    this.userCreationStatus = UserCreationStatus.notStarted,
  });

  /// Creates a copy of this EnhancedSignupFormState with the given fields replaced
  EnhancedSignupFormState copyWith({
    int? currentStep,
    EnhancedSignupFormModel? formData,
    bool? isLoading,
    String? errorMessage,
    UserCreationStatus? userCreationStatus,
  }) {
    return EnhancedSignupFormState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userCreationStatus: userCreationStatus ?? this.userCreationStatus,
    );
  }
}
