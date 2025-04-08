import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';
import 'package:trusted/features/auth/domain/notifiers/auth_notifier.dart';

/// Admin dashboard screen for managing pending users
class AdminDashboardScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load pending users when the screen is initialized
    Future.microtask(() {
      ref.read(adminStateProvider.notifier).loadPendingUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Admin welcome card
              Card(
                elevation: 0,
                color: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'مرحباً بك في لوحة التحكم',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يمكنك مراجعة وتفعيل حسابات المستخدمين الجدد من هنا.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Pending users section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المستخدمون قيد المراجعة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.read(adminStateProvider.notifier).loadPendingUsers();
                    },
                    tooltip: 'تحديث',
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Pending users list
              Expanded(
                child: adminState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : adminState.pendingUsers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: adminState.pendingUsers.length,
                            itemBuilder: (context, index) {
                              final user = adminState.pendingUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
              ),
              
              if (adminState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    adminState.errorMessage!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
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
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد مستخدمون قيد المراجعة',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'جميع المستخدمين تم مراجعتهم وتفعيلهم',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.primary,
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
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Text(
                    roleArabic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
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
              _buildDetailRow(
                Icons.description, 
                'وصف النشاط التجاري', 
                user.businessDescription ?? 'غير محدد',
              ),
              _buildDetailRow(
                Icons.person, 
                'يعمل بمفرده', 
                user.workingSolo == true ? 'نعم' : 'لا',
              ),
              if (user.workingSolo == false)
                _buildDetailRow(
                  Icons.people, 
                  'معرفات الشركاء', 
                  user.associateIds ?? 'غير محدد',
                ),
            ],
            
            if (user.isMediator)
              _buildDetailRow(
                Icons.phone_android, 
                'رقم الواتساب', 
                user.whatsappNumber ?? '-',
              ),
            
            _buildDetailRow(
              Icons.calendar_today, 
              'تاريخ التسجيل', 
              _formatDate(user.createdAt),
            ),
            
            const SizedBox(height: 16),
            
            // Approve button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _showRejectDialog(user);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: const Text('رفض'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _showApproveDialog(user);
                  },
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

  void _showApproveDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد القبول'),
        content: Text('هل أنت متأكد من قبول المستخدم ${user.name}؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(adminStateProvider.notifier).approveUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(UserModel user) {
    // In a real application, you would implement rejection functionality
    // For now, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض المستخدم'),
        content: const Text(
          'هذه الوظيفة غير متاحة حالياً. في التطبيق الكامل، يمكنك رفض المستخدم وإرسال سبب الرفض.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('حسناً'),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
