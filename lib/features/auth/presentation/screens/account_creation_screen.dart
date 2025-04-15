import 'package:flutter/material.dart';
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

/// Screen for creating username and password during the sign-up process
class AccountCreationScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AccountCreationScreen({super.key});

  @override
  ConsumerState<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends ConsumerState<AccountCreationScreen> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;
  String? _usernameErrorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
  
  /// Check if username is available
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        _isUsernameAvailable = true;
        _usernameErrorMessage = null;
      });
      return;
    }
    
    setState(() {
      _isCheckingUsername = true;
      _usernameErrorMessage = null;
    });
    
    try {
      // Get Supabase client
      final supabase = Supabase.instance.client;
      
      // Check if username exists in the database
      final response = await supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .limit(1)
          .maybeSingle();
      
      // Debounce the UI update to prevent flickering
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = response == null;
          _usernameErrorMessage = !_isUsernameAvailable ? 'اسم المستخدم مستخدم بالفعل' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          // Don't show error on network issues to avoid confusing the user
          _isUsernameAvailable = true;
        });
      }
    }
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
    final isLoading = signupFormState.isLoading;
    final errorMessage = signupFormState.errorMessage;
    
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
    final currentStep = selectedRole == AppConstants.roleBuyerSeller ? 4 : 5;
    
    // Function to handle form submission
    Future<void> _submitForm() async {
      // Perform a final username availability check before submission
      await _checkUsernameAvailability(_usernameController.text);
      
      if (!_isUsernameAvailable) {
        // Show error message and return if username is not available
        setState(() {
          _usernameErrorMessage = 'اسم المستخدم مستخدم بالفعل';
        });
        return;
      }
      
      if (_formKey.currentState?.saveAndValidate() ?? false) {
        // Show loading state immediately
        ref.read(provider.notifier).setLoading(true);
        // Get form values
        final username = _formKey.currentState!.value['username'] as String;
        final password = _passwordController.text;
        
        // Update form data with username and password
        ref.read(provider.notifier).updateUsername(username);
        ref.read(provider.notifier).updatePassword(password);
        
        try {
          // Get Supabase client
          final supabase = Supabase.instance.client;
          final user = supabase.auth.currentUser;
          
          if (user == null) {
            throw Exception('المستخدم غير مصرح له');
          }
          
          // Check if user exists in the database
          final userCreationService = UserCreationService();
          final userExists = await userCreationService.userExists(user.id);
          
          if (!userExists) {
            throw Exception('يجب إكمال الخطوات السابقة أولاً');
          }
          
          // Get photo URLs from form data if merchant or mediator
          final selfiePhotoUrl = selectedRole != AppConstants.roleBuyerSeller ? formData.selfiePhotoUrl : null;
          final frontIdPhotoUrl = selectedRole != AppConstants.roleBuyerSeller ? formData.frontIdPhotoUrl : null;
          final backIdPhotoUrl = selectedRole != AppConstants.roleBuyerSeller ? formData.backIdPhotoUrl : null;
          
          // Verify photos are uploaded for merchant and mediator
          if (selectedRole != AppConstants.roleBuyerSeller && 
              (selfiePhotoUrl == null || frontIdPhotoUrl == null || backIdPhotoUrl == null)) {
            throw Exception('الرجاء التأكد من رفع جميع الصور المطلوبة');
          }
          
          // Update user credentials (username and password)
          await userCreationService.updateUserCredentials(
            userId: user.id,
            username: username,
            password: password,
          );
          
          // Update user creation status to completed
          ref.read(provider.notifier).updateUserCreationStatus(UserCreationStatus.completed);
          
          debugPrint('User credentials updated successfully: ${formData.email}');
          
          // Navigate to the appropriate screen based on user role
          if (mounted) {
            if (formData.role == AppConstants.roleBuyerSeller) {
              // Buyer/seller is active immediately
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              // Merchant and mediator need approval
              Navigator.pushReplacementNamed(context, '/waiting');
            }
          }
        } catch (e) {
          // Set error message
          ref.read(provider.notifier).setErrorMessage(e.toString());
        } finally {
          // Clear loading state
          ref.read(provider.notifier).setLoading(false);
        }
      }
    }
    
    return SignupStepContainer(
      title: 'إنشاء حساب',
      subtitle: 'أنشئ اسم مستخدم وكلمة مرور للدخول إلى حسابك',
      currentStep: currentStep,
      totalSteps: totalSteps,
      stepLabels: getStepLabels(),
      isNextEnabled: true, // Will be validated on button press
      isLoading: isLoading,
      nextButtonText: 'إنشاء الحساب',
      onNext: () {
        // Use PerformanceUtils to run the form submission asynchronously
        PerformanceUtils.runAsync(() => _submitForm());
      },
      onBack: () {
        ref.read(provider.notifier).goToPreviousStep();
        Navigator.pop(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error message if any
          if (errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled, // Changed to manual validation to improve performance
            child: Column(
              children: [
                // Username field with availability check
                PerformanceUtils.optimizedFormField(
                  FormBuilderTextField(
                    name: 'username',
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person),
                      hintText: 'أدخل اسم المستخدم الذي تريده',
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _usernameController.text.isNotEmpty
                              ? Icon(
                                  _isUsernameAvailable ? Icons.check_circle : Icons.error,
                                  color: _isUsernameAvailable ? AppColors.success : AppColors.error,
                                )
                              : null,
                      errorText: _usernameErrorMessage,
                    ),
                    validator: (value) {
                      // First check if the username meets the basic requirements
                      final basicValidation = FormValidators.validateUsername(value);
                      if (basicValidation != null) {
                        return basicValidation;
                      }
                      
                      // Then check if the username is available
                      if (!_isUsernameAvailable) {
                        return 'اسم المستخدم مستخدم بالفعل';
                      }
                      
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null) {
                        // Debounce the username availability check to prevent excessive API calls
                        PerformanceUtils.debounce(() {
                          _checkUsernameAvailability(value);
                          ref.read(provider.notifier).updateUsername(value);
                        }, 500)();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field
                PerformanceUtils.optimizedFormField(
                  FormBuilderTextField(
                    name: 'password',
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'أدخل كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: FormValidators.passwordValidator(),
                    onChanged: (value) {
                      if (value != null) {
                        // Debounce the update to prevent excessive rebuilds
                        PerformanceUtils.debounce(() {
                          ref.read(provider.notifier).updatePassword(value);
                          // Trigger validation of confirm password
                          _formKey.currentState?.fields['confirm_password']?.validate();
                        })();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                PerformanceUtils.optimizedFormField(
                  FormBuilderTextField(
                    name: 'confirm_password',
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'أعد إدخال كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      // No need to update state on confirm password changes
                      // but we'll debounce any UI updates
                      PerformanceUtils.debounce(() {
                        setState(() {});
                      })();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Password requirements
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
                      'متطلبات كلمة المرور',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPasswordRequirement(
                  'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
                  _passwordController.text.length >= 8,
                ),
                _buildPasswordRequirement(
                  'يجب أن تحتوي على حرف واحد على الأقل',
                  RegExp(r'[a-zA-Z]').hasMatch(_passwordController.text),
                ),
                _buildPasswordRequirement(
                  'يجب أن تحتوي على رقم واحد على الأقل',
                  RegExp(r'[0-9]').hasMatch(_passwordController.text),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Information about what happens next
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'ماذا يحدث بعد ذلك؟',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  selectedRole == AppConstants.roleBuyerSeller
                      ? 'سيتم تفعيل حسابك مباشرة ويمكنك البدء في استخدام التطبيق.'
                      : 'سيتم مراجعة طلبك من قبل المسؤول وسيتم إعلامك عند الموافقة عليه.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a password requirement item with a check mark
  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
