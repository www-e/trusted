import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trusted/core/constants/app_constants.dart';
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
        setState(() {
          _isLoading = true;
        });
        
        // Use PerformanceUtils to handle heavy operations
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
          
          // Compress photos for better performance
          final selfieCompressed = await PerformanceUtils.compressImage(_selfiePhoto!);  
          final frontIdCompressed = await PerformanceUtils.compressImage(_frontIdPhoto!);
          final backIdCompressed = await PerformanceUtils.compressImage(_backIdPhoto!);
          
          // Upload photos and update user record
          final photoUrls = await userCreationService.uploadUserPhotos(
            userId: user.id,
            selfiePhoto: selfieCompressed,
            frontIdPhoto: frontIdCompressed,
            backIdPhoto: backIdCompressed,
          );
          
          // Update the form data with the actual URLs
          ref.read(provider.notifier).updateSelfiePhotoUrl(photoUrls['selfie_photo_url'] ?? '');
          ref.read(provider.notifier).updateFrontIdPhotoUrl(photoUrls['front_id_photo_url'] ?? '');
          ref.read(provider.notifier).updateBackIdPhotoUrl(photoUrls['back_id_photo_url'] ?? '');
          
          // Update user creation status
          ref.read(provider.notifier).updateUserCreationStatus(UserCreationStatus.photosUploaded);
          
          if (ref.read(provider.notifier).goToNextStep()) {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context, 
                '/signup/account-creation',
                arguments: (name: formData.name, email: formData.email),
              );
            }
          }
        } catch (e) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ أثناء رفع الصور: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      onBack: () {
        ref.read(provider.notifier).goToPreviousStep();
        Navigator.pop(context);
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
                PerformanceUtils.runAsync(() {
                  setState(() {
                    _selfiePhoto = file;
                  });
                });
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
                PerformanceUtils.runAsync(() {
                  setState(() {
                    _frontIdPhoto = file;
                  });
                });
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
                PerformanceUtils.runAsync(() {
                  setState(() {
                    _backIdPhoto = file;
                  });
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Information about photo requirements
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
