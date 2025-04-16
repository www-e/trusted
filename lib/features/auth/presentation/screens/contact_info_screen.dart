import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';
import 'package:trusted/features/auth/domain/services/user_creation_service.dart';
import 'package:trusted/features/auth/domain/utils/form_validators.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';
import 'package:trusted/features/auth/presentation/widgets/signup_step_container.dart';

/// Screen for entering contact information during the sign-up process
class ContactInfoScreen extends ConsumerStatefulWidget {
  /// Constructor
  const ContactInfoScreen({super.key});

  @override
  ConsumerState<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends ConsumerState<ContactInfoScreen> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _whatsappController = TextEditingController();
  final _vodafoneCashController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    // Optimize keyboard appearance
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    // Initialize controllers with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final formData = ref.read(enhancedSignupFormProvider((name: '', email: ''))).formData;
        _whatsappController.text = formData.whatsappNumber ?? '';
        _vodafoneCashController.text = formData.vodafoneCashNumber ?? '';
        _nicknameController.text = formData.nickname ?? '';
      }
    });
  }
  
  @override
  void dispose() {
    _whatsappController.dispose();
    _vodafoneCashController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Get user data from route arguments
    final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
    
    // Create a provider instance with user data
    final provider = enhancedSignupFormProvider(userData ?? (name: '', email: ''));
    
    // Watch the provider state
    final signupFormState = ref.watch(provider);
    final formData = signupFormState.formData;
    final selectedRole = formData.role;
    
    // Form key already defined as class member
    
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
    
    // Determine next route based on role
    final nextRoute = selectedRole == AppConstants.roleBuyerSeller
        ? '/signup/account-creation'
        : '/signup/photo-upload';
    
    return SignupStepContainer(
      title: 'معلومات الاتصال',
      subtitle: 'يرجى إدخال معلومات الاتصال الإضافية',
      currentStep: 3,
      totalSteps: totalSteps,
      stepLabels: getStepLabels(),
      isNextEnabled: true, // Will be validated on button press
      onNext: () async {
        if (_isProcessing) return;
        
        setState(() {
          _isProcessing = true;
        });
        
        // Run validation on a separate isolate to avoid blocking the UI thread
        PerformanceUtils.runAsync(() async {
          try {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              if (ref.read(provider.notifier).goToNextStep()) {
                // Create initial user record in the database
                final userCreationService = UserCreationService();
                final userId = await userCreationService.createInitialUserRecord(formData);
                
                debugPrint('User record created with ID: $userId');
                
                // Update user creation status
                ref.read(provider.notifier).updateUserCreationStatus(UserCreationStatus.initialRecordCreated);
                
                // Navigate to the next screen
                if (mounted) {
                  Navigator.pushReplacementNamed(
                    context, 
                    nextRoute,
                    arguments: (name: formData.name, email: formData.email),
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('Error: $e');
          } finally {
            // Reset loading state
            if (mounted) {
              setState(() {
                _isProcessing = false;
              });
            }
          }
        });
      },
      onBack: () {
        ref.read(provider.notifier).goToPreviousStep();
        Navigator.pop(context);
      },
      child: FormBuilder(
        key: _formKey,
        initialValue: {
          'whatsapp_number': formData.whatsappNumber,
          'vodafone_cash_number': formData.vodafoneCashNumber,
          'nickname': formData.nickname,
        },
        autovalidateMode: AutovalidateMode.disabled, // Changed to manual validation to improve performance
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WhatsApp number field - optimized with controller
            FormBuilderTextField(
              name: 'whatsapp_number',
              controller: _whatsappController,
              decoration: InputDecoration(
                labelText: 'رقم الواتساب',
                prefixIcon: Icon(Icons.chat, color: AppColors.primary),
                hintText: 'أدخل رقم الواتساب مع مفتاح الدولة',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) => FormValidators.validatePhoneNumber(value, context),
              onChanged: (value) {
                if (value != null) {
                  ref.read(provider.notifier).updateWhatsappNumber(value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Vodafone Cash number field - optimized with controller
            FormBuilderTextField(
              name: 'vodafone_cash_number',
              controller: _vodafoneCashController,
              decoration: InputDecoration(
                labelText: 'رقم فودافون كاش',
                prefixIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
                hintText: 'أدخل رقم فودافون كاش مع مفتاح الدولة',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) => FormValidators.validatePhoneNumber(value, context),
              onChanged: (value) {
                if (value != null) {
                  ref.read(provider.notifier).updateVodafoneCashNumber(value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Nickname field - optimized with controller
            FormBuilderTextField(
              name: 'nickname',
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'اسم الشهرة',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                hintText: 'أدخل اسم الشهرة الخاص بك',
                filled: true,
                fillColor: Colors.white,
              ),
              textInputAction: TextInputAction.done,
              validator: FormValidators.requiredValidator('الرجاء إدخال اسم الشهرة'),
              onChanged: (value) {
                if (value != null) {
                  ref.read(provider.notifier).updateNickname(value);
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Information about next steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'معلومات هامة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedRole == AppConstants.roleBuyerSeller
                        ? 'في الخطوة التالية، سنطلب منك إنشاء اسم مستخدم وكلمة مرور للدخول إلى حسابك.'
                        : 'في الخطوة التالية، سنطلب منك التقاط صورة شخصية وصور لبطاقة الهوية.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
