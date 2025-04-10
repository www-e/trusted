import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';

/// Screen shown to users with rejected status
class RejectedScreen extends ConsumerWidget {
  /// Constructor
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب مرفوض'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rejected icon
                Icon(
                  Icons.cancel_outlined,
                  size: 100,
                  color: AppColors.error,
                ),
                
                const SizedBox(height: 32),
                
                // Rejected title
                Text(
                  'تم رفض طلبك',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Rejection message
                Text(
                  'نأسف لإبلاغك أن طلب التسجيل الخاص بك في تطبيق Trusted قد تم رفضه من قبل المسؤول.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // User info card
                if (user != null)
                  Card(
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
                          _buildInfoRow(context, 'الاسم', user.name),
                          _buildInfoRow(context, 'البريد الإلكتروني', user.email),
                          _buildInfoRow(context, 'الدور', _getRoleArabic(user.role)),
                          _buildInfoRow(context, 'تاريخ التسجيل', 
                              _formatDate(user.createdAt)),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Rejection reason card
                Card(
                  elevation: 0,
                  color: AppColors.error.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سبب الرفض:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لم تستوفِ المعلومات المقدمة المعايير المطلوبة للتسجيل في التطبيق. يرجى التواصل مع فريق الدعم لمزيد من المعلومات.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Contact info
                Text(
                  'إذا كنت تعتقد أن هناك خطأ أو ترغب في معرفة المزيد من التفاصيل، يرجى التواصل معنا على البريد الإلكتروني:',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'support@trusted-app.com',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Try again button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signup/role',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة التسجيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleArabic(String role) {
    switch (role) {
      case 'buyer_seller':
        return 'شاري / بايع';
      case 'merchant':
        return 'تاجر';
      case 'mediator':
        return 'وسيط';
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
