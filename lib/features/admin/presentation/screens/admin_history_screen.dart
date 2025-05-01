import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/presentation/components/history_card.dart';
import 'package:trusted/features/admin/presentation/widgets/empty_state.dart';
import 'package:trusted/features/admin/presentation/widgets/stat_card.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Admin history screen for viewing approved users
class AdminHistoryScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AdminHistoryScreen({super.key});

  @override
  ConsumerState<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends ConsumerState<AdminHistoryScreen> {
  // Filter options
  String _filterStatus = 'all';
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    
    // Filter users based on status and search query
    final filteredUsers = _getFilteredUsers(adminState.approvedUsers);
    
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact header with stats
          Container(
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
                // Compact history header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.success,
                      radius: 18,
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سجل المستخدمين المفعلين',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'قائمة بجميع المستخدمين الذين تم تفعيل حساباتهم',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Stats cards in a more compact layout
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        color: AppColors.success.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.people, color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'إجمالي المستخدمين',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${adminState.approvedUsers.length}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        color: AppColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.today, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تم تفعيلهم اليوم',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${adminState.approvedTodayCount}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
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
                ),
              ],
            ),
          ),
          
          // Filter section - more compact
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث عن مستخدم...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      isDense: true,
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('الكل', style: theme.textTheme.bodyMedium),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('مفعل', style: theme.textTheme.bodyMedium),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text('مرفوض', style: theme.textTheme.bodyMedium),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filterStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // User count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'عدد النتائج: ${filteredUsers.length}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          
          // User history list
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? const EmptyState(
                        message: 'لا يوجد مستخدمين في السجل',
                        icon: Icons.history,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return HistoryCard(user: user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// Builds the history header with icon and text
  Widget _buildHistoryHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.success,
          radius: 24,
          child: const Icon(
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
    );
  }

  /// Filters users based on status and search query
  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    // First filter by status
    var filteredByStatus = users;
    if (_filterStatus == 'active') {
      filteredByStatus = users.where((user) => user.isActive).toList();
    } else if (_filterStatus == 'rejected') {
      filteredByStatus = users.where((user) => user.isRejected).toList();
    }
    
    // Then filter by search query if present
    if (_searchQuery.isEmpty) {
      return filteredByStatus;
    }
    
    final query = _searchQuery.toLowerCase();
    return filteredByStatus.where((user) {
      return user.name.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query) ||
             user.phoneNumber.toLowerCase().contains(query) ||
             user.nickname.toLowerCase().contains(query);
    }).toList();
  }
}
