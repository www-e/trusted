import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/domain/services/admin_cache_service.dart';
import 'package:trusted/features/admin/presentation/widgets/empty_state.dart';
import 'package:trusted/features/admin/presentation/widgets/stat_card.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';
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
  // Search controller and query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
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
    
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    final mediaQuery = MediaQuery.of(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminStateProvider.notifier).loadPendingUsers();
      },
      child: CustomScrollView(
        slivers: [
          // Compact header with stats
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light 
                    ? AppColors.primary.withOpacity(0.1) 
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compact welcome header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 20,
                        child: const Icon(
                          Icons.dashboard,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لوحة المتابعة',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'مراجعة وتفعيل المستخدمين الجدد',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'البحث عن مستخدم...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats cards in a row with responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.people_alt, color: AppColors.warning, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${adminState.pendingUsers.length}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'قيد المراجعة',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${adminState.approvedTodayCount}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'تم قبولهم اليوم',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Section header for pending users
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'المستخدمون قيد المراجعة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${adminState.pendingUsers.length} مستخدم',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          // Pending users list with filtering
          adminState.isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : adminState.pendingUsers.isEmpty
                  ? SliverFillRemaining(
                      child: EmptyState(
                        message: 'لا يوجد مستخدمين قيد المراجعة حالياً',
                        icon: Icons.person_add_disabled,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Filter users based on search query
                          Builder(builder: (context) {
                            final filteredUsers = _searchQuery.isEmpty
                                ? adminState.pendingUsers
                                : adminState.pendingUsers.where((user) {
                                    final query = _searchQuery.toLowerCase();
                                    return user.name.toLowerCase().contains(query) ||
                                           user.email.toLowerCase().contains(query) ||
                                           user.phoneNumber.toLowerCase().contains(query) ||
                                           user.nickname.toLowerCase().contains(query);
                                  }).toList();
                            
                            if (filteredUsers.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: EmptyState(
                                  message: 'لا يوجد مستخدمين مطابقين لبحثك "$_searchQuery"',
                                  icon: Icons.search_off,
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _buildExpandableUserCard(user, theme);
                              },
                            );
                          }),
                        ],
                      ),
                    )
        ],
      ),
    );
  }

  /// Builds an expandable user card for the pending users list
  Widget _buildExpandableUserCard(UserModel user, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: AdminFormatters.getStatusColor(user.status).withOpacity(0.1),
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
        subtitle: Text(
          user.email,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Approve button
            IconButton(
              icon: const Icon(Icons.check_circle, size: 20),
              color: AppColors.success,
              tooltip: 'قبول',
              onPressed: () => _showApproveDialog(user),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            // Reject button
            IconButton(
              icon: const Icon(Icons.cancel, size: 20),
              color: AppColors.error,
              tooltip: 'رفض',
              onPressed: () => _showRejectDialog(user),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
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
                // User ID section
                _buildUserDetailRow(Icons.perm_identity, 'معرف المستخدم', user.id),
                const Divider(height: 16),
                
                // Contact information section
                Text(
                  'معلومات الاتصال',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.person, 'الاسم الكامل', user.name),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.email, 'البريد الإلكتروني', user.email),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.phone, 'رقم الهاتف', user.phoneNumber),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.phone_android, 'رقم الواتساب', user.whatsappNumber ?? 'غير متوفر'),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.person_pin, 'اللقب', user.nickname),
                const Divider(height: 16),
                
                // Business information section
                Text(
                  'معلومات العمل',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.business, 'اسم العمل', user.businessName ?? 'غير متوفر'),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.description, 'وصف العمل', user.businessDescription ?? 'غير متوفر'),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.location_on, 'الدولة', user.country),
                const Divider(height: 16),
                
                // Account information section
                Text(
                  'معلومات الحساب',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.calendar_today, 'تاريخ التسجيل', DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt)),
                const SizedBox(height: 8),
                _buildUserDetailRow(Icons.verified_user, 'حالة الحساب', AdminFormatters.getStatusText(user.status)),
                
                // Note about ID photos
                const Divider(height: 16),
                Text(
                  'ملاحظة حول الصور',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يمكن مشاهدة صور الهوية الشخصية من خلال قاعدة البيانات المباشرة',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Approve button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('قبول المستخدم'),
                      onPressed: () => _showApproveDialog(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Reject button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('رفض المستخدم'),
                      onPressed: () => _showRejectDialog(user),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a photo card for ID photos
  Widget _buildPhotoCard(BuildContext context, String label, String photoUrl) {
    return InkWell(
      onTap: () {
        // Show full-screen image when tapped
        showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(label),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  automaticallyImplyLeading: false,
                ),
                Flexible(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 24, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Helper method to build a user detail row
  Widget _buildUserDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.end,
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
