import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Admin history screen for viewing approved users
class AdminHistoryScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AdminHistoryScreen({super.key});

  @override
  ConsumerState<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends ConsumerState<AdminHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light 
                  ? AppColors.primary.withOpacity(0.1) 
                  : AppColors.primary.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // History info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.success,
                      radius: 24,
                      child: Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سجل المستخدمين المفعلين',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'قائمة بجميع المستخدمين الذين تم تفعيل حساباتهم',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'إجمالي المستخدمين المفعلين',
                        '${adminState.approvedUsers.length}',
                        Icons.people,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'تم تفعيلهم اليوم',
                        '${adminState.approvedTodayCount}',
                        Icons.today,
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث عن مستخدم...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade100
                          : AppColors.darkSurface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.read(adminStateProvider.notifier).loadApprovedUsers();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.light
                        ? Colors.grey.shade100
                        : AppColors.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Users list
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminState.approvedUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: adminState.approvedUsers.length,
                        itemBuilder: (context, index) {
                          final user = adminState.approvedUsers[index];
                          return _buildUserHistoryCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade400
                : Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد مستخدمين مفعلين بعد',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا قائمة المستخدمين الذين تم تفعيل حساباتهم',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserHistoryCard(UserModel user) {
    final theme = Theme.of(context);
    final roleArabic = _getRoleArabic(user.role);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isRejected 
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.success.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: user.isRejected ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                        user.email,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (user.isRejected ? AppColors.error : AppColors.success).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: user.isRejected ? AppColors.error : AppColors.success),
                  ),
                  child: Text(
                    roleArabic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.isRejected ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // User details
            _buildDetailRow(Icons.phone, 'رقم الهاتف', user.phoneNumber),
            _buildDetailRow(Icons.location_on, 'البلد', user.country),
            
            if (user.isMerchant) ...[
              _buildDetailRow(
                Icons.business, 
                'اسم النشاط التجاري', 
                user.businessName ?? 'غير محدد',
              ),
            ],
            
            _buildDetailRow(
              Icons.calendar_today, 
              'تاريخ التسجيل', 
              _formatDate(user.createdAt),
            ),
            
            const SizedBox(height: 8),
            
            // Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (user.isRejected ? AppColors.error : AppColors.success).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: user.isRejected ? AppColors.error : AppColors.success),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isRejected ? Icons.cancel : Icons.check_circle,
                        size: 16,
                        color: user.isRejected ? AppColors.error : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isRejected ? 'تم الرفض' : 'تم التفعيل',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: user.isRejected ? AppColors.error : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.darkText.withOpacity(0.6)
                : AppColors.lightText.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleArabic(String role) {
    switch (role) {
      case AppConstants.roleBuyerSeller:
        return AppConstants.roleBuyerSellerArabic;
      case AppConstants.roleMerchant:
        return AppConstants.roleMerchantArabic;
      case AppConstants.roleMediator:
        return AppConstants.roleMediatorArabic;
      default:
        return role;
    }
  }

  String _formatDate(DateTime date) {
    // Format date with year, month, day, hour, minute, second
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
