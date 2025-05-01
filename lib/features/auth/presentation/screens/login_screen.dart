import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';

/// Login screen for the application
class LoginScreen extends ConsumerStatefulWidget {
  /// Constructor
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isAdminLogin = false;
  bool _obscurePassword = true;
  bool _showEmailPasswordFields = false;
  bool _isEmailPasswordLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Get a more user-friendly error message based on the error code
  String _getDetailedErrorMessage(String errorMessage) {
    if (errorMessage.contains('Invalid login credentials')) {
      return 'اسم المستخدم أو كلمة المرور غير صحيحة. يرجى التحقق والمحاولة مرة أخرى.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'لم يتم تأكيد البريد الإلكتروني بعد. يرجى التحقق من بريدك الإلكتروني وتأكيد حسابك.';
    } else if (errorMessage.contains('User not found')) {
      return 'لم يتم العثور على المستخدم. يرجى التأكد من اسم المستخدم أو التسجيل أولاً.';
    } else if (errorMessage.contains('Too many requests')) {
      return 'تم تجاوز عدد محاولات تسجيل الدخول المسموح بها. يرجى المحاولة مرة أخرى لاحقاً.';
    } else if (errorMessage.contains('network')) {
      return 'حدث خطأ في الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }
    return errorMessage;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;
    
    // Optimize system UI overlay style for better performance
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.lightBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      
                      // App logo with modern design
                      Center(
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.03),
                      
                      // App name with modern typography
                      Text(
                        'Trusted',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // App description
                      Text(
                        'منصة آمنة للتجارة والوساطة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.darkText.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: size.height * 0.05),
                      
                      // Email/Password login section
                      if (_showEmailPasswordFields) ...[                        
                        // Username/Email field
                        PerformanceUtils.optimizedFormField(
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'اسم المستخدم أو البريد الإلكتروني',
                              prefixIcon: Icon(Icons.person, color: AppColors.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال اسم المستخدم أو البريد الإلكتروني';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        PerformanceUtils.optimizedFormField(
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.primary.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login button
                        ElevatedButton(
                          onPressed: _isEmailPasswordLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    setState(() {
                                      _isEmailPasswordLoading = true;
                                    });
                                    
                                    try {
                                      // Get username and password from controllers
                                      final username = _usernameController.text.trim();
                                      final password = _passwordController.text.trim();
                                      
                                      // Sign in with username and password
                                      await ref.read(authStateProvider.notifier)
                                          .signInWithUsername(username, password);
                                      
                                      // Check authentication result
                                      final currentAuthState = ref.read(authStateProvider);
                                      
                                      if (currentAuthState.errorMessage == null) {
                                        final user = currentAuthState.user;
                                        
                                        if (user != null) {
                                          if (user.isAdmin && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context, 
                                              '/admin',
                                            );
                                          } else if (user.isActive && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context, 
                                              '/home',
                                            );
                                          } else if (user.isPending && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context, 
                                              '/waiting',
                                            );
                                          } else if (user.isRejected && mounted) {
                                            Navigator.pushReplacementNamed(
                                              context, 
                                              '/rejected',
                                            );
                                          }
                                        }
                                      }
                                    } catch (e) {
                                      // Error will be handled by the auth notifier
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isEmailPasswordLoading = false;
                                        });
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                          ),
                          child: _isEmailPasswordLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('تسجيل الدخول'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Back to options button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showEmailPasswordFields = false;
                            });
                          },
                          child: Text(
                            'العودة إلى خيارات تسجيل الدخول',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ] else ...[                        
                        // Login options section
                        // Google Sign-In button with modern design
                        ElevatedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  // Use PerformanceUtils to optimize the sign-in process
                                  PerformanceUtils.runAsync(() async {
                                    await ref.read(authStateProvider.notifier)
                                        .signInWithGoogle();
                                        
                                    final currentAuthState = ref.read(authStateProvider);
                                        
                                    if (currentAuthState.errorMessage == null) {
                                      if (currentAuthState.userExists) {
                                        final user = currentAuthState.user;
                                        
                                        if (user != null) {
                                          if (user.isAdmin) {
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(
                                                context, 
                                                '/admin/dashboard',
                                              );
                                            }
                                          } else if (user.isActive) {
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(
                                                context, 
                                                '/home',
                                              );
                                            }
                                          } else if (user.isPending) {
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(
                                                context, 
                                                '/waiting',
                                              );
                                            }
                                          } else if (user.isRejected) {
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(
                                                context, 
                                                '/rejected',
                                              );
                                            }
                                          }
                                        }
                                      } else {
                                        // User doesn't exist, start enhanced sign-up flow
                                        final googleUser = ref.read(authStateProvider.notifier)
                                            .currentUser;
                                            
                                        if (googleUser != null && context.mounted) {
                                          // Navigate to role selection with user data
                                          Navigator.pushReplacementNamed(
                                            context, 
                                            '/signup/role',
                                            arguments: (
                                              name: googleUser.userMetadata?['full_name'] ?? '',
                                              email: googleUser.email ?? ''
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Image.asset(
                            'assets/icons/google_logo.png',
                            width: 24,
                            height: 24,
                          ),
                          label: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'تسجيل الدخول باستخدام Google',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Username/Password login option
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showEmailPasswordFields = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.person),
                          label: const Text(
                            'تسجيل الدخول باستخدام اسم المستخدم',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],  // This was missing - closes the else [...] statement
                      
                      if (authState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getDetailedErrorMessage(authState.errorMessage!),
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      SizedBox(height: size.height * 0.08),
                      
                      // App version with subtle styling
                      Text(
                        'الإصدار 1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.darkText.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],  // This closes the children: [] list
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
