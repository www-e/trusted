import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/notifiers/signup_form_notifier.dart';
import 'package:trusted/features/auth/presentation/widgets/progress_bar.dart';
import 'package:trusted/features/auth/presentation/widgets/role_card.dart';

/// Screen for selecting a role during the sign-up process
class RoleSelectionScreen extends ConsumerWidget {
  /// Constructor
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Get user data from route arguments
    final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
    
    // Create a provider instance with user data
    final provider = signupFormProvider(userData ?? (name: '', email: ''));
    
    // Watch the provider state
    final signupFormState = ref.watch(provider);
    final selectedRole = signupFormState.formData.role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الدور'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressBar(
                currentStep: 1,
                totalSteps: 3,
                stepLabels: const [
                  'اختيار الدور',
                  'المعلومات',
                  'التأكيد',
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'اختر دورك',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى اختيار الدور الذي يناسبك',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
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
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedRole.isNotEmpty
                    ? () {
                        if (ref.read(provider.notifier).goToNextStep()) {
                          Navigator.pushReplacementNamed(
                            context, 
                            '/signup/information',
                            arguments: (name: signupFormState.formData.name, email: signupFormState.formData.email),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('التالي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
