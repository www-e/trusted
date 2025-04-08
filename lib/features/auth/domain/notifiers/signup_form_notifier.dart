import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/features/auth/domain/models/signup_form_model.dart';

/// Sign-up form state
class SignupFormState {
  /// Current step in the sign-up process (1-3)
  final int currentStep;
  
  /// Form data
  final SignupFormModel formData;
  
  /// Constructor
  const SignupFormState({
    this.currentStep = 1,
    required this.formData,
  });

  /// Creates a copy of this SignupFormState with the given fields replaced
  SignupFormState copyWith({
    int? currentStep,
    SignupFormModel? formData,
  }) {
    return SignupFormState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
    );
  }
}

/// Sign-up form notifier to manage the multi-step sign-up process
class SignupFormNotifier extends StateNotifier<SignupFormState> {
  /// Constructor
  SignupFormNotifier({
    required String name,
    required String email,
  }) : super(
          SignupFormState(
            formData: SignupFormModel.initial(
              name: name,
              email: email,
            ),
          ),
        );

  /// Update role
  void updateRole(String role) {
    state = state.copyWith(
      formData: state.formData.copyWith(role: role),
    );
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(phoneNumber: phoneNumber),
    );
  }

  /// Update secondary phone number
  void updateSecondaryPhoneNumber(String? secondaryPhoneNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(
        secondaryPhoneNumber: secondaryPhoneNumber,
      ),
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

  /// Update business name
  void updateBusinessName(String? businessName) {
    state = state.copyWith(
      formData: state.formData.copyWith(businessName: businessName),
    );
  }

  /// Update business description
  void updateBusinessDescription(String? businessDescription) {
    state = state.copyWith(
      formData: state.formData.copyWith(
        businessDescription: businessDescription,
      ),
    );
  }

  /// Update working solo
  void updateWorkingSolo(bool? workingSolo) {
    state = state.copyWith(
      formData: state.formData.copyWith(workingSolo: workingSolo),
    );
  }

  /// Update associate IDs
  void updateAssociateIds(String? associateIds) {
    state = state.copyWith(
      formData: state.formData.copyWith(associateIds: associateIds),
    );
  }

  /// Update WhatsApp number
  void updateWhatsappNumber(String? whatsappNumber) {
    state = state.copyWith(
      formData: state.formData.copyWith(whatsappNumber: whatsappNumber),
    );
  }

  /// Go to next step
  bool goToNextStep() {
    if (state.formData.isValidForStep(state.currentStep)) {
      if (state.currentStep < 3) {
        state = state.copyWith(currentStep: state.currentStep + 1);
        return true;
      }
    }
    return false;
  }

  /// Go to previous step
  bool goToPreviousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      return true;
    }
    return false;
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 1 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Check if current step is valid
  bool isCurrentStepValid() {
    return state.formData.isValidForStep(state.currentStep);
  }
}

/// Provider for SignupFormState
final signupFormProvider = StateNotifierProvider.family<
    SignupFormNotifier, SignupFormState, ({String name, String email})>(
  (ref, userData) => SignupFormNotifier(
    name: userData.name,
    email: userData.email,
  ),
);
