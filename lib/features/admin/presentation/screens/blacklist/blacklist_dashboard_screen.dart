import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/models/blacklist_model.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/presentation/screens/blacklist/components/blacklist_entry_card.dart';
import 'package:trusted/features/admin/presentation/screens/blacklist/components/block_phone_dialog.dart';
import 'package:trusted/features/admin/presentation/screens/blacklist/components/phone_block_card.dart';
import 'package:trusted/features/admin/presentation/widgets/empty_state.dart';

/// Blacklist dashboard screen for managing blacklisted users and phone numbers
class BlacklistDashboardScreen extends ConsumerStatefulWidget {
  /// Constructor
  const BlacklistDashboardScreen({super.key});

  @override
  ConsumerState<BlacklistDashboardScreen> createState() => _BlacklistDashboardScreenState();
}

class _BlacklistDashboardScreenState extends ConsumerState<BlacklistDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load blacklist data
    Future.microtask(() {
      ref.read(adminStateProvider.notifier).loadBlacklistData();
    });
    
    // Listen to search changes
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    ref.read(adminStateProvider.notifier).updateSearchQuery(_searchController.text);
  }
  
  void _showBlockPhoneDialog() {
    showDialog(
      context: context,
      builder: (context) => const BlockPhoneDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('القائمة السوداء'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.brightness == Brightness.light 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.primary.withOpacity(0.2),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.brightness == Brightness.light
              ? AppColors.darkText.withOpacity(0.6)
              : AppColors.lightText.withOpacity(0.6),
          tabs: const [
            Tab(text: 'المستخدمين المحظورين'),
            Tab(text: 'أرقام الهواتف المحظورة'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                  ),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.grey.shade800,
              ),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Blacklisted users tab
                _buildBlacklistTab(adminState, theme),
                
                // Blocked phone numbers tab
                _buildPhoneBlockTab(adminState, theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBlockPhoneDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildBlacklistTab(AdminState adminState, ThemeData theme) {
    if (adminState.isLoadingBlacklist) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final filteredEntries = adminState.filteredBlacklistEntries;
    
    if (filteredEntries.isEmpty) {
      return const EmptyState(
        message: 'لا يوجد مستخدمين محظورين',
        icon: Icons.block,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final entry = filteredEntries[index];
        return BlacklistEntryCard(
          entry: entry,
          onUnblock: () => _showUnblockDialog(entry),
        );
      },
    );
  }
  
  Widget _buildPhoneBlockTab(AdminState adminState, ThemeData theme) {
    if (adminState.isLoadingBlacklist) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final filteredBlocks = adminState.filteredPrimitivePhoneBlocks;
    
    if (filteredBlocks.isEmpty) {
      return const EmptyState(
        message: 'لا يوجد أرقام هواتف محظورة',
        icon: Icons.phone_disabled,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBlocks.length,
      itemBuilder: (context, index) {
        final block = filteredBlocks[index];
        return PhoneBlockCard(
          block: block,
          onUnblock: () => _showUnblockPhoneDialog(block),
        );
      },
    );
  }
  
  void _showUnblockDialog(BlacklistModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إلغاء الحظر'),
        content: Text('هل أنت متأكد من إلغاء حظر ${entry.email ?? entry.phoneNumber ?? entry.userId ?? entry.deviceId}؟'),
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
              await ref.read(adminStateProvider.notifier).removeFromBlacklist(entry.id);
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
  
  void _showUnblockPhoneDialog(PrimitivePhoneBlockModel block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إلغاء الحظر'),
        content: Text('هل أنت متأكد من إلغاء حظر الرقم ${block.phoneNumber}؟'),
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
              await ref.read(adminStateProvider.notifier).unblockPhoneNumber(block.phoneNumber);
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
}
