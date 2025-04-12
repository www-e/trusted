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
                _buildHistoryHeader(theme),
                
                const SizedBox(height: 24),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'إجمالي المستخدمين المفعلين',
                        value: '${adminState.approvedUsers.length}',
                        icon: Icons.people,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'تم تفعيلهم اليوم',
                        value: '${adminState.approvedTodayCount}',
                        icon: Icons.today,
                        color: AppColors.primary,
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
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filterStatus,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('الكل'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('مفعل'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('مرفوض'),
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
              ],
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
                        padding: const EdgeInsets.all(16),
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
