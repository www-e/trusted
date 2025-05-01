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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: AdminFormatters.getStatusColor(user.status).withOpacity(0.1),
          radius: 20,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AdminFormatters.getStatusColor(user.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              AdminFormatters.getRoleArabic(user.role),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Icon(Icons.circle, size: 8, color: AdminFormatters.getStatusColor(user.status)),
            const SizedBox(width: 4),
            Text(
              AdminFormatters.getStatusText(user.status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AdminFormatters.getStatusColor(user.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.expand_more),
        children: [
          // User details
          Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.grey.shade50
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact information section
                Text(
                  'معلومات الاتصال',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                if (user.secondaryPhoneNumber != null && user.secondaryPhoneNumber!.isNotEmpty)
                  DetailRow(
                    icon: Icons.phone_android,
                    label: 'رقم الهاتف الثانوي',
                    value: user.secondaryPhoneNumber!,
                  ),
                if (user.whatsappNumber != null && user.whatsappNumber!.isNotEmpty)
                  DetailRow(
                    icon: Icons.phone_android,
                    label: 'رقم الواتساب',
                    value: user.whatsappNumber!,
                  ),
                DetailRow(
                  icon: Icons.location_on,
                  label: 'البلد',
                  value: user.country,
                ),
                
                const Divider(height: 24),
                
                // Business information (for merchants)
                if (user.isMerchant) ...[  
                  Text(
                    'معلومات النشاط التجاري',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DetailRow(
                    icon: Icons.business,
                    label: 'اسم النشاط',
                    value: user.businessName ?? 'غير متوفر',
                  ),
                  if (user.businessDescription != null && user.businessDescription!.isNotEmpty)
                    DetailRow(
                      icon: Icons.description,
                      label: 'وصف النشاط',
                      value: user.businessDescription!,
                    ),
                  DetailRow(
                    icon: Icons.group,
                    label: 'يعمل بمفرده',
                    value: (user.workingSolo ?? true) ? 'نعم' : 'لا',
                  ),
                  const Divider(height: 24),
                ],
                
                // Account information
                Text(
                  'معلومات الحساب',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}
