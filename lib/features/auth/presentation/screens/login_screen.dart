import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';

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
  bool _isAdminLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    
                    // App logo or icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // App name
                    Text(
                      'Trusted',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // App description
                    Text(
                      'منصة آمنة للتجارة والوساطة',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: size.height * 0.06),                    
                    // Google Sign-In button for all users (including admin)
                    ElevatedButton.icon(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              await ref.read(authStateProvider.notifier)
                                  .signInWithGoogle();
                                  
                              final currentAuthState = ref.read(authStateProvider);
                                  
                              if (currentAuthState.errorMessage == null) {
                                if (currentAuthState.userExists) {
                                  final user = currentAuthState.user;
                                  
                                  // Check if this is the admin email
                                  final isAdmin = user?.isAdmin ?? 
                                      (currentAuthState.user?.email == AppConstants.adminEmail || 
                                       ref.read(authStateProvider.notifier).currentUser?.email == AppConstants.adminEmail);
                                  
                                  if (isAdmin) {
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context, 
                                        '/admin/dashboard',
                                      );
                                    }
                                  } else if (user != null) {
                                    if (user.isActive) {
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
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
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
                    
                    SizedBox(height: size.height * 0.08),
                    
                    // App version
                    Text(
                      'الإصدار 1.0.0',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
