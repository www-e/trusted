import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Enhanced sign-up form notifier to manage the multi-step sign-up process
class EnhancedSignupNotifier extends StateNotifier<EnhancedSignupFormState> {
  /// Constructor
  EnhancedSignupNotifier({
    required String name,
    required String email,
  }) : super(
          EnhancedSignupFormState(
            formData: EnhancedSignupFormModel.initial(
              name: name,
              email: email,
            ),
          ),
        ) {
    // Load cached form data when initializing
    _loadCachedFormData();
  }
  
  /// Cache the current form data to SharedPreferences
  Future<void> cacheFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final formDataJson = jsonEncode(state.formData.toJson());
      await prefs.setString('cached_signup_form', formDataJson);
      await prefs.setInt('cached_signup_step', state.currentStep);
      await prefs.setString('cached_user_creation_status', state.userCreationStatus.toString());
    } catch (e) {
      // Silently handle caching errors
      debugPrint('Error caching form data: $e');
    }
  }
  
  /// Load cached form data from SharedPreferences
  Future<void> _loadCachedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_signup_form');
      final cachedStep = prefs.getInt('cached_signup_step');
      final cachedStatusString = prefs.getString('cached_user_creation_status');
      
      UserCreationStatus cachedStatus = UserCreationStatus.notStarted;
      if (cachedStatusString != null) {
        try {
          cachedStatus = UserCreationStatus.values.firstWhere(
            (e) => e.toString() == cachedStatusString,
            orElse: () => UserCreationStatus.notStarted,
          );
        } catch (_) {
          // Ignore parsing errors
        }
      }
      
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = jsonDecode(cachedData);
        // Only use cached data if email matches to prevent using wrong data
        if (jsonData['email'] == state.formData.email) {
          state = state.copyWith(
            formData: EnhancedSignupFormModel.fromJson(jsonData),
            currentStep: cachedStep ?? 1,
            userCreationStatus: cachedStatus,
          );
        }
      }
    } catch (e) {
      // Silently handle loading errors
      debugPrint('Error loading cached form data: $e');
    }
  }
  
  /// Clear cached form data
  Future<void> clearCachedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_signup_form');
      await prefs.remove('cached_signup_step');
      await prefs.remove('cached_user_creation_status');
    } catch (e) {
      // Silently handle errors
      debugPrint('Error clearing cached form data: $e');
    }
  }

  /// Update role
  void updateRole(String role) {
    state = state.copyWith(
      formData: state.formData.copyWith(role: role),
    );
    cacheFormData();
  }

  /// Update name
  void updateName(String name) {
    state = state.copyWith(
      formData: state.formData.copyWith(name: name),
    );
  }

  /// Update email
  void updateEmail(String email) {
    state = state.copyWith(
      formData: state.formData.copyWith(email: email),
    );
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(phoneNumber: phoneNumber),
    );
  }

  /// Update WhatsApp number
  void updateWhatsappNumber(String whatsappNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(whatsappNumber: whatsappNumber),
    );
  }

  /// Update Vodafone Cash number
  void updateVodafoneCashNumber(String vodafoneCashNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(vodafoneCashNumber: vodafoneCashNumber),
    );
  }

  /// Update nickname
  void updateNickname(String nickname) {
    state = state.copyWith(
      formData: state.formData.copyWith(nickname: nickname),
    );
  }

  /// Update country
  void updateCountry(String country) {
    state = state.copyWith(
      formData: state.formData.copyWith(country: country),
    );
  }

  /// Update selfie photo URL
  void updateSelfiePhotoUrl(String url) {
    state = state.copyWith(
      formData: state.formData.copyWith(selfiePhotoUrl: url),
    );
  }

  /// Update front ID photo URL
  void updateFrontIdPhotoUrl(String url) {
    state = state.copyWith(
      formData: state.formData.copyWith(frontIdPhotoUrl: url),
    );
  }

  /// Update back ID photo URL
  void updateBackIdPhotoUrl(String url) {
    state = state.copyWith(
      formData: state.formData.copyWith(backIdPhotoUrl: url),
    );
  }

  /// Update username
  void updateUsername(String username) {
    state = state.copyWith(
      formData: state.formData.copyWith(username: username),
    );
  }

  /// Update password
  void updatePassword(String password) {
    state = state.copyWith(
      formData: state.formData.copyWith(password: password),
    );
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error message
  void setErrorMessage(String? message) {
    state = state.copyWith(errorMessage: message);
  }
  
  /// Update user creation status
  void updateUserCreationStatus(UserCreationStatus status) {
    state = state.copyWith(userCreationStatus: status);
    cacheFormData();
  }
  
  /// Check if initial user record has been created
  bool isInitialUserRecordCreated() {
    return state.userCreationStatus != UserCreationStatus.notStarted;
  }
  
  /// Check if user photos have been uploaded
  bool areUserPhotosUploaded() {
    return state.userCreationStatus == UserCreationStatus.photosUploaded || 
           state.userCreationStatus == UserCreationStatus.completed;
  }

  /// Go to next step
  bool goToNextStep() {
    if (state.formData.isValidForStep(state.currentStep)) {
      final totalSteps = state.formData.getTotalSteps();
      if (state.currentStep < totalSteps) {
        state = state.copyWith(
          currentStep: state.currentStep + 1,
          errorMessage: null,
        );
        cacheFormData();
        return true;
      }
    }
    return false;
  }

  /// Go to previous step
  bool goToPreviousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null,
      );
      cacheFormData();
      return true;
    }
    return false;
  }

  /// Go to specific step
  void goToStep(int step) {
    final totalSteps = state.formData.getTotalSteps();
    if (step >= 1 && step <= totalSteps) {
      state = state.copyWith(
        currentStep: step,
        errorMessage: null,
      );
      cacheFormData();
    }
  }

  /// Check if current step is valid
  bool isCurrentStepValid() {
    return state.formData.isValidForStep(state.currentStep);
  }
}

/// Provider for EnhancedSignupFormState
final enhancedSignupFormProvider = StateNotifierProvider.family<
    EnhancedSignupNotifier, EnhancedSignupFormState, ({String name, String email})>(
  (ref, userData) => EnhancedSignupNotifier(
    name: userData.name,
    email: userData.email,
  ),
);
