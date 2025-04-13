import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';
import 'package:trusted/features/auth/domain/utils/form_validators.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';
import 'package:trusted/features/auth/presentation/widgets/signup_step_container.dart';

/// Screen for entering basic user information during the sign-up process
class BasicInfoScreen extends ConsumerStatefulWidget {
  /// Constructor
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isInitialized = false;
  
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
    
    // Form key for validation
    final formKey = GlobalKey<FormBuilderState>();
    
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
      title: 'المعلومات الأساسية',
      subtitle: 'يرجى إدخال معلوماتك الشخصية',
      currentStep: 2,
      totalSteps: totalSteps,
      stepLabels: getStepLabels(),
      isNextEnabled: true, // Will be validated on button press
      onNext: () {
        // Run validation on a separate isolate to avoid blocking the UI thread
        PerformanceUtils.runAsync(() {
          if (_formKey.currentState?.saveAndValidate() ?? false) {
            if (ref.read(provider.notifier).goToNextStep()) {
              Navigator.pushReplacementNamed(
                context, 
                '/signup/contact-info',
                arguments: (name: formData.name, email: formData.email),
              );
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
          'name': formData.name,
          'email': formData.email,
          'phone_number': formData.phoneNumber,
          'country': formData.country,
        },
        autovalidateMode: AutovalidateMode.disabled, // Change to manual validation to improve performance
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            PerformanceUtils.optimizedFormField(
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'أدخل اسمك الكامل',
                ),
                validator: FormValidators.requiredValidator('الرجاء إدخال الاسم'),
                onChanged: (value) {
                  if (value != null) {
                    // Debounce the update to prevent excessive rebuilds
                    PerformanceUtils.debounce(() {
                      ref.read(provider.notifier).updateName(value);
                    })();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Email field (pre-filled from Google and disabled)
            PerformanceUtils.optimizedFormField(
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'أدخل بريدك الإلكتروني',
                ),
                enabled: false, // Disabled because it comes from Google
                validator: FormValidators.emailValidator(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone number field
            PerformanceUtils.optimizedFormField(
              FormBuilderTextField(
                name: 'phone_number',
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'أدخل رقم هاتفك مع مفتاح الدولة',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => FormValidators.validatePhoneNumber(value, context),
                onChanged: (value) {
                  if (value != null) {
                    // Debounce the update to prevent excessive rebuilds
                    PerformanceUtils.debounce(() {
                      ref.read(provider.notifier).updatePhoneNumber(value);
                    })();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Country field (dropdown)
            PerformanceUtils.optimizedFormField(
              FormBuilderDropdown<String>(
                name: 'country',
                decoration: const InputDecoration(
                  labelText: 'الدولة',
                  prefixIcon: Icon(Icons.public),
                  hintText: 'اختر دولتك',
                ),
                validator: FormValidators.requiredValidator('الرجاء اختيار الدولة'),
                items: const [
                  DropdownMenuItem(
                    value: 'مصر',
                    child: Text('مصر (+20)'),
                  ),
                  DropdownMenuItem(
                    value: 'السعودية',
                    child: Text('السعودية (+966)'),
                  ),
                  DropdownMenuItem(
                    value: 'الإمارات',
                    child: Text('الإمارات (+971)'),
                  ),
                  DropdownMenuItem(
                    value: 'الكويت',
                    child: Text('الكويت (+965)'),
                  ),
                  DropdownMenuItem(
                    value: 'قطر',
                    child: Text('قطر (+974)'),
                  ),
                  DropdownMenuItem(
                    value: 'البحرين',
                    child: Text('البحرين (+973)'),
                  ),
                  DropdownMenuItem(
                    value: 'عمان',
                    child: Text('عمان (+968)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(provider.notifier).updateCountry(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Information about next steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'معلومات هامة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'في الخطوة التالية، سنطلب منك إدخال معلومات الاتصال الإضافية مثل رقم الواتساب ورقم فودافون كاش.',
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
