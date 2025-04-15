import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    // Optimize keyboard appearance and system UI
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    // Optimize system UI overlay style for better performance
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.lightBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    // Initialize controllers with existing data in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }
  
  void _initializeControllers() {
    if (!_isInitialized && mounted) {
      final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
      if (userData != null) {
        _nameController.text = userData.name;
        _emailController.text = userData.email;
      }
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
        if (_isProcessing) return;
        
        setState(() {
          _isProcessing = true;
        });
        
        // Run validation on a separate isolate to avoid blocking the UI thread
        PerformanceUtils.runAsync(() async {
          try {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              if (ref.read(provider.notifier).goToNextStep()) {
                if (mounted) {
                  await Navigator.pushReplacementNamed(
                    context, 
                    '/signup/contact-info',
                    arguments: (name: formData.name, email: formData.email),
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('Navigation error: $e');
          } finally {
            if (mounted) {
              setState(() {
                _isProcessing = false;
              });
            }
          }
          
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      },
      onBack: () {
        ref.read(provider.notifier).goToPreviousStep();
        Navigator.pop(context);
      },
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled, // Only validate on submit for better performance
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field - with optimized rendering
            RepaintBoundary(
              child: PerformanceUtils.optimizedFormField(
                FormBuilderTextField(
                  name: 'name',
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person, color: AppColors.primary),
                    hintText: 'أدخل اسمك الكامل',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.requiredValidator('الرجاء إدخال الاسم'),
                  onChanged: (value) {
                    if (value != null) {
                      // Debounce the update to prevent excessive rebuilds
                      PerformanceUtils.debounce(() {
                        ref.read(provider.notifier).updateName(value);
                      }, 300)();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email field - with optimized rendering
            RepaintBoundary(
              child: PerformanceUtils.optimizedFormField(
                FormBuilderTextField(
                  name: 'email',
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email, color: AppColors.primary),
                    hintText: 'أدخل بريدك الإلكتروني',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FormBuilderValidators.compose([
                    FormValidators.requiredValidator('الرجاء إدخال البريد الإلكتروني'),
                    FormBuilderValidators.email(errorText: 'الرجاء إدخال بريد إلكتروني صحيح'),
                  ]),
                  onChanged: (value) {
                    if (value != null) {
                      // Debounce the update to prevent excessive rebuilds
                      PerformanceUtils.debounce(() {
                        ref.read(provider.notifier).updateEmail(value);
                      }, 300)();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone number field - optimized with controller
            PerformanceUtils.optimizedFormField(
              FormBuilderTextField(
                name: 'phone_number',
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  hintText: 'أدخل رقم هاتفك مع مفتاح الدولة',
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => FormValidators.validatePhoneNumber(value, context),
                onChanged: (value) {
                  if (value != null) {
                    // Debounce the update to prevent excessive rebuilds
                    PerformanceUtils.debounce(() {
                      ref.read(provider.notifier).updatePhoneNumber(value);
                    }, 300)();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Country field (dropdown) - with optimized rendering
            RepaintBoundary(
              child: PerformanceUtils.optimizedFormField(
                FormBuilderDropdown<String>(
                  name: 'country',
                  decoration: InputDecoration(
                    labelText: 'الدولة',
                    prefixIcon: Icon(Icons.public, color: AppColors.primary),
                    hintText: 'اختر دولتك',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: FormValidators.requiredValidator('الرجاء اختيار الدولة'),
                  initialValue: formData.country,
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
                      PerformanceUtils.debounce(() {
                        ref.read(provider.notifier).updateCountry(value);
                      }, 300)();
                    }
                  },
                ),
              ),
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
