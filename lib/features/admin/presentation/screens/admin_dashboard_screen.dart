import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/domain/services/admin_cache_service.dart';
import 'package:trusted/features/admin/presentation/components/user_card.dart';
import 'package:trusted/features/admin/presentation/widgets/empty_state.dart';
import 'package:trusted/features/admin/presentation/widgets/stat_card.dart';
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
    // Load data with debouncing to prevent rapid API calls
    Future.microtask(() {
      final cacheService = ref.read(adminCacheServiceProvider);
      cacheService.debounce('init_dashboard', () {
        ref.read(adminStateProvider.notifier).loadPendingUsers();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Admin stats and welcome section
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
                // Admin welcome card
                _buildWelcomeHeader(theme),
                
                const SizedBox(height: 24),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'المستخدمون قيد المراجعة',
                        value: '${adminState.pendingUsers.length}',
                        icon: Icons.people_alt,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'تم تفعيلهم اليوم',
                        value: '${adminState.approvedTodayCount}',
                        icon: Icons.today,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pending users list
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminState.pendingUsers.isEmpty
                    ? const EmptyState(
                        message: 'لا يوجد مستخدمين قيد المراجعة حالياً',
                        icon: Icons.people_alt_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminState.pendingUsers.length,
                        itemBuilder: (context, index) {
                          final user = adminState.pendingUsers[index];
                          return UserCard(
                            user: user,
                            onApprove: () => _showApproveDialog(user),
                            onReject: () => _showRejectDialog(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Builds the welcome header with admin avatar and greeting text
  Widget _buildWelcomeHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 24,
          child: const Icon(
            Icons.admin_panel_settings,
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
                'مرحباً بك في لوحة التحكم',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'يمكنك مراجعة وتفعيل حسابات المستخدمين الجدد من هنا.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: Text('هل أنت متأكد من رفض المستخدم ${user.name}؟'),
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
              await ref.read(adminStateProvider.notifier).rejectUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}
