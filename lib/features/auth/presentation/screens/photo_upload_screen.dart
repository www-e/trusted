import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/enhanced_signup_notifier.dart';
import 'package:trusted/features/auth/domain/services/user_creation_service.dart';
import 'package:trusted/features/auth/domain/utils/performance_utils.dart';
import 'package:trusted/features/auth/presentation/widgets/photo_upload_widget.dart';
import 'package:trusted/features/auth/presentation/widgets/signup_step_container.dart';

/// Screen for uploading required photos during the sign-up process
/// This screen is only for merchant and mediator roles
class PhotoUploadScreen extends ConsumerStatefulWidget {
  /// Constructor
  const PhotoUploadScreen({super.key});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  File? _selfiePhoto;
  File? _frontIdPhoto;
  File? _backIdPhoto;
  bool _isLoading = false;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    // Optimize system UI and memory usage
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.lightBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
    // Preload image processing capabilities
    PerformanceUtils.runAsync(() {
      ImageCache().clear();
      PaintingBinding.instance.imageCache.clear();
    });
  }

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
    
    // Define step labels
    const stepLabels = [
      'اختيار الدور',
      'المعلومات الأساسية',
      'معلومات الاتصال',
      'الصور الشخصية',
      'إنشاء حساب',
    ];
    
    // Check if all photos are uploaded
    final bool allPhotosUploaded = 
        _selfiePhoto != null && 
        _frontIdPhoto != null && 
        _backIdPhoto != null;
    
    return SignupStepContainer(
      title: 'الصور الشخصية',
      subtitle: 'يرجى التقاط الصور المطلوبة',
      currentStep: 4,
      totalSteps: 5,
      stepLabels: stepLabels,
      isNextEnabled: allPhotosUploaded && !_isLoading,
      isLoading: _isLoading,
      onNext: () async {
        if (_isProcessing) return;
        
        setState(() {
          _isLoading = true;
          _isProcessing = true;
        });
        
        try {
          // Get the current user ID
          final supabase = Supabase.instance.client;
          final user = supabase.auth.currentUser;
          
          if (user == null) {
            throw Exception('المستخدم غير مصرح له');
          }
          
          // Check if initial user record has been created
          final userCreationService = UserCreationService();
          final userExists = await userCreationService.userExists(user.id);
          final userCreationStatus = ref.read(provider).userCreationStatus;
          
          if (!userExists || userCreationStatus == UserCreationStatus.notStarted) {
            throw Exception('يجب إكمال الخطوات السابقة أولاً');
          }
          
          // Process images in parallel for better performance
          final futures = [
            PerformanceUtils.compressImage(_selfiePhoto!),
            PerformanceUtils.compressImage(_frontIdPhoto!),
            PerformanceUtils.compressImage(_backIdPhoto!)
          ];
          
          final compressedImages = await Future.wait(futures);
          
          // Upload photos and update user record
          final photoUrls = await userCreationService.uploadUserPhotos(
            userId: user.id,
            selfiePhoto: compressedImages[0],
            frontIdPhoto: compressedImages[1],
            backIdPhoto: compressedImages[2],
          );
        
          // Update the form data with the actual URLs
          ref.read(provider.notifier).updateSelfiePhotoUrl(photoUrls['selfie_photo_url'] ?? '');
          ref.read(provider.notifier).updateFrontIdPhotoUrl(photoUrls['front_id_photo_url'] ?? '');
          ref.read(provider.notifier).updateBackIdPhotoUrl(photoUrls['back_id_photo_url'] ?? '');
          
          // Update user creation status
          ref.read(provider.notifier).updateUserCreationStatus(UserCreationStatus.photosUploaded);
          
          // Cache cleanup to free memory after heavy image operations
          ImageCache().clear();
          PaintingBinding.instance.imageCache.clear();
          
          // Navigate to the next screen
          if (mounted) {
            Navigator.pushReplacementNamed(
              context, 
              '/signup/create-account',
              arguments: (name: formData.name, email: formData.email),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ أثناء رفع الصور: ${e.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        } finally {
          // Clear loading state
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isProcessing = false;
            });
          }
        }
      },
      onBack: () {
        ref.read(provider.notifier).goToPreviousStep();
        Navigator.of(context).pop();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selfie photo upload with performance optimization
          RepaintBoundary(
            child: PhotoUploadWidget(
              title: 'صورة شخصية',
              description: 'يرجى التقاط صورة شخصية واضحة لوجهك',
              icon: Icons.person,
              currentPhoto: _selfiePhoto,
              onPhotoSelected: (file) {
                // Debounce the state update to prevent excessive rebuilds
                PerformanceUtils.debounce(() {
                  setState(() {
                    _selfiePhoto = file;
                  });
                }, 300)();
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Front ID photo upload with performance optimization
          RepaintBoundary(
            child: PhotoUploadWidget(
              title: 'صورة بطاقة الهوية (الوجه)',
              description: 'يرجى التقاط صورة واضحة للوجه الأمامي لبطاقة الهوية',
              icon: Icons.credit_card,
              currentPhoto: _frontIdPhoto,
              onPhotoSelected: (file) {
                // Debounce the state update to prevent excessive rebuilds
                PerformanceUtils.debounce(() {
                  setState(() {
                    _frontIdPhoto = file;
                  });
                }, 300)();
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Back ID photo upload with performance optimization
          RepaintBoundary(
            child: PhotoUploadWidget(
              title: 'صورة بطاقة الهوية (الظهر)',
              description: 'يرجى التقاط صورة واضحة للوجه الخلفي لبطاقة الهوية',
              icon: Icons.credit_card,
              currentPhoto: _backIdPhoto,
              onPhotoSelected: (file) {
                // Debounce the state update to prevent excessive rebuilds
                PerformanceUtils.debounce(() {
                  setState(() {
                    _backIdPhoto = file;
                  });
                }, 300)();
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Information about photo requirements
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
                  'يجب أن تكون الصور واضحة وغير مشوشة. سيتم استخدام هذه الصور للتحقق من هويتك.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'في الخطوة التالية، سنطلب منك إنشاء اسم مستخدم وكلمة مرور للدخول إلى حسابك.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}