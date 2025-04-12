import 'package:flutter/material.dart';
import 'package:trusted/features/admin/presentation/widgets/detail_row.dart';
import 'package:trusted/features/admin/presentation/widgets/status_badge.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// A component for displaying a user history card
/// Shows user details and status in the history screen
class HistoryCard extends StatelessWidget {
  /// The user to display
  final UserModel user;

  /// Constructor
  const HistoryCard({
    super.key,
    required this.user,
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
                  backgroundColor: AdminFormatters.getStatusColor(user.status).withOpacity(0.1),
                  radius: 24,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AdminFormatters.getStatusColor(user.status),
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
                StatusBadge(status: user.status),
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
            
            if (user.isMerchant && user.businessName != null) 
              DetailRow(
                icon: Icons.business,
                label: 'اسم النشاط التجاري',
                value: user.businessName!,
              ),
            
            DetailRow(
              icon: Icons.calendar_today,
              label: 'تاريخ التسجيل',
              value: AdminFormatters.formatDateTime(user.createdAt),
            ),
            
            if (user.acceptedAt != null)
              DetailRow(
                icon: Icons.check_circle_outline,
                label: 'تاريخ التفعيل',
                value: AdminFormatters.formatDateTime(user.acceptedAt!),
              ),
          ],
        ),
      ),
    );
  }
}
