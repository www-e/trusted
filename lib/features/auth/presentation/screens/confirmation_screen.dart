import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/features/auth/domain/notifiers/signup_form_notifier.dart';
import 'package:trusted/features/auth/presentation/widgets/progress_bar.dart';

/// Screen for confirming user information during the sign-up process
class ConfirmationScreen extends ConsumerWidget {
  /// Constructor
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Get user data from route arguments
    final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
    
    // Create a provider instance with user data
    final provider = signupFormProvider(userData ?? (name: '', email: ''));
    
    // Watch the provider state
    final signupFormState = ref.watch(provider);
    final formData = signupFormState.formData;
    final authState = ref.watch(authStateProvider);
    
    // Get role name in Arabic
    String roleArabic;
    switch (formData.role) {
      case AppConstants.roleBuyerSeller:
        roleArabic = AppConstants.roleBuyerSellerArabic;
        break;
      case AppConstants.roleMerchant:
        roleArabic = AppConstants.roleMerchantArabic;
        break;
      case AppConstants.roleMediator:
        roleArabic = AppConstants.roleMediatorArabic;
        break;
      default:
        roleArabic = '';
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد المعلومات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(provider.notifier).goToPreviousStep();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressBar(
                currentStep: 3,
                totalSteps: 3,
                stepLabels: const [
                  'اختيار الدور',
                  'المعلومات',
                  'التأكيد',
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'تأكيد المعلومات',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى مراجعة المعلومات قبل الإرسال',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.brightness == Brightness.light
                            ? AppColors.lightBorder
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'المعلومات الأساسية'),
                          const SizedBox(height: 16),
                          _buildInfoRow(context, 'الدور', roleArabic),
                          _buildInfoRow(context, 'الاسم الكامل', formData.name),
                          _buildInfoRow(context, 'البريد الإلكتروني', formData.email),
                          _buildInfoRow(context, 'رقم الهاتف', formData.phoneNumber),
                          if (formData.secondaryPhoneNumber != null && 
                              formData.secondaryPhoneNumber!.isNotEmpty)
                            _buildInfoRow(context, 'رقم الهاتف الثانوي', 
                                formData.secondaryPhoneNumber!),
                          _buildInfoRow(context, 'اللقب', formData.nickname),
                          _buildInfoRow(context, 'البلد', formData.country),
                          
                          // Merchant-specific information
                          if (formData.role == AppConstants.roleMerchant) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle(context, 'معلومات التاجر'),
                            const SizedBox(height: 16),
                            _buildInfoRow(context, 'اسم النشاط التجاري', 
                                formData.businessName ?? ''),
                            _buildInfoRow(context, 'وصف النشاط التجاري', 
                                formData.businessDescription ?? ''),
                            _buildInfoRow(context, 'يعمل بمفرده', 
                                formData.workingSolo == true ? 'نعم' : 'لا'),
                            if (formData.workingSolo == false)
                              _buildInfoRow(context, 'معرفات الشركاء', 
                                  formData.associateIds ?? ''),
                          ],
                          
                          // Mediator-specific information
                          if (formData.role == AppConstants.roleMediator) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle(context, 'معلومات الوسيط'),
                            const SizedBox(height: 16),
                            _buildInfoRow(context, 'رقم الواتساب', 
                                formData.whatsappNumber ?? ''),
                          ],
                          
                          // Status information
                          const SizedBox(height: 24),
                          _buildSectionTitle(context, 'معلومات الحالة'),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            context, 
                            'الحالة بعد التسجيل', 
                            formData.role == AppConstants.roleBuyerSeller
                                ? 'نشط'
                                : 'قيد المراجعة',
                          ),
                          if (formData.role != AppConstants.roleBuyerSeller)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'سيتم مراجعة حسابك من قبل المسؤول قبل تفعيله.',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(provider.notifier).goToPreviousStep();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              await ref.read(authStateProvider.notifier)
                                  .createUser(formData);
                                  
                              if (ref.read(authStateProvider).errorMessage == null) {
                                if (context.mounted) {
                                  // Check user role to determine where to navigate
                                  final currentUser = ref.read(authStateProvider).user;
                                  if (currentUser != null) {
                                    if (currentUser.role == AppConstants.roleBuyerSeller) {
                                      // Buyer/Seller goes directly to home
                                      Navigator.pushNamedAndRemoveUntil(
                                        context, 
                                        '/home', 
                                        (route) => false,
                                      );
                                    } else {
                                      // Merchant and Mediator go to waiting screen
                                      Navigator.pushNamedAndRemoveUntil(
                                        context, 
                                        '/waiting', 
                                        (route) => false,
                                      );
                                    }
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('إرسال'),
                    ),
                  ),
                ],
              ),
              if (authState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    authState.errorMessage!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.darkText.withOpacity(0.7)
                      : AppColors.lightText.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Divider(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightBorder
                : AppColors.darkBorder,
            height: 1,
          ),
        ],
      ),
    );
  }
}
