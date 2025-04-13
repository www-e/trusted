import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';
import 'package:trusted/features/auth/presentation/widgets/signup_step_container.dart';
import 'package:trusted/features/auth/presentation/widgets/role_card.dart';

/// Screen for selecting a role during the sign-up process
class RoleSelectionScreen extends ConsumerWidget {
  /// Constructor
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get user data from route arguments
    final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
    
    // Create a provider instance with user data
    final provider = enhancedSignupFormProvider(userData ?? (name: '', email: ''));
    
    // Watch the provider state
    final signupFormState = ref.watch(provider);
    final selectedRole = signupFormState.formData.role;
    
    // Define step labels based on the selected role
    List<String> getStepLabels() {
      if (selectedRole == AppConstants.roleBuyerSeller) {
        return const [
          'اختيار الدور',
          'المعلومات الأساسية',
          'معلومات الاتصال',
          'إنشاء حساب',
        ];
      } else {
        return const [
          'اختيار الدور',
          'المعلومات الأساسية',
          'معلومات الاتصال',
          'الصور الشخصية',
          'إنشاء حساب',
        ];
      }
    }
    
    // Get total steps based on role
    final totalSteps = selectedRole == AppConstants.roleBuyerSeller ? 4 : 5;
    
    return SignupStepContainer(
      title: 'اختر دورك',
      subtitle: 'يرجى اختيار الدور الذي يناسبك',
      currentStep: 1,
      totalSteps: totalSteps,
      stepLabels: getStepLabels(),
      showBackButton: false,
      isNextEnabled: selectedRole.isNotEmpty,
      onNext: () {
        if (ref.read(provider.notifier).goToNextStep()) {
          Navigator.pushReplacementNamed(
            context, 
            '/signup/basic-info',
            arguments: (name: signupFormState.formData.name, email: signupFormState.formData.email),
          );
        }
      },
      child: Column(
        children: [
          RoleCard(
            title: AppConstants.roleBuyerSellerArabic,
            description: 'يمكنك شراء وبيع المنتجات',
            icon: Icons.shopping_cart,
            isSelected: selectedRole == AppConstants.roleBuyerSeller,
            onTap: () => ref
                .read(provider.notifier)
                .updateRole(AppConstants.roleBuyerSeller),
          ),
          RoleCard(
            title: AppConstants.roleMerchantArabic,
            description: 'يمكنك إدارة متجرك الخاص',
            icon: Icons.store,
            isSelected: selectedRole == AppConstants.roleMerchant,
            onTap: () => ref
                .read(provider.notifier)
                .updateRole(AppConstants.roleMerchant),
          ),
          RoleCard(
            title: AppConstants.roleMediatorArabic,
            description: 'يمكنك التوسط بين البائعين والمشترين',
            icon: Icons.handshake,
            isSelected: selectedRole == AppConstants.roleMediator,
            onTap: () => ref
                .read(provider.notifier)
                .updateRole(AppConstants.roleMediator),
          ),
        ],
      ),
    );
  }
}
