import 'package:flutter/material.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/presentation/widgets/detail_row.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// A component for displaying a user card in the admin dashboard
/// Shows user details and provides approve/reject actions
class UserCard extends StatelessWidget {
  /// The user to display
  final UserModel user;
  
  /// Callback when the approve button is pressed
  final VoidCallback onApprove;
  
  /// Callback when the reject button is pressed
  final VoidCallback onReject;

  /// Constructor
  const UserCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header with avatar and name
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  radius: 24,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AdminFormatters.getRoleArabic(user.role),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.light
                              ? Colors.black54
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'قيد المراجعة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // User details
            DetailRow(
              icon: Icons.email,
              label: 'البريد الإلكتروني',
              value: user.email,
            ),
            DetailRow(
              icon: Icons.person,
              label: 'اسم المستخدم',
              value: user.nickname,
            ),
            DetailRow(
              icon: Icons.phone,
              label: 'رقم الهاتف',
              value: user.phoneNumber,
            ),
            DetailRow(
              icon: Icons.location_on,
              label: 'البلد',
              value: user.country,
            ),
            
            if (user.isMerchant) ...[
              DetailRow(
                icon: Icons.business,
                label: 'اسم النشاط التجاري',
                value: user.businessName ?? 'غير محدد',
              ),
              if (user.businessDescription != null && user.businessDescription!.isNotEmpty)
                DetailRow(
                  icon: Icons.description,
                  label: 'وصف النشاط',
                  value: user.businessDescription!,
                ),
            ],
            
            if (user.isMediator && user.whatsappNumber != null)
              DetailRow(
                icon: Icons.phone_android, // Using phone_android instead of whatsapp as it's not available
                label: 'رقم الواتساب',
                value: user.whatsappNumber!,
              ),
            
            DetailRow(
              icon: Icons.calendar_today,
              label: 'تاريخ التسجيل',
              value: AdminFormatters.formatDateTime(user.createdAt),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: const Text('رفض'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: const Text('قبول'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
