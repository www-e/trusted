import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/admin/domain/services/admin_cache_service.dart';
import 'package:trusted/features/admin/presentation/components/user_edit_form.dart';
import 'package:trusted/features/admin/presentation/components/user_list_item.dart';
import 'package:trusted/features/admin/presentation/widgets/empty_state.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Admin screen for editing user data
/// Redesigned for better mobile experience with a list-detail pattern
class AdminUsersScreen extends ConsumerStatefulWidget {
  /// Constructor
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _searchQuery = '';
  UserModel? _selectedUser;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _nicknameController;
  late TextEditingController _countryController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessDescController;
  late TextEditingController _whatsappController;
  
  @override
  void initState() {
    super.initState();
    _initControllers();
    
    // Load users when the screen is first shown
    Future.microtask(() {
      // Use debouncing to prevent rapid API calls
      final cacheService = ref.read(adminCacheServiceProvider);
      cacheService.debounce('load_users', () {
        ref.read(adminStateProvider.notifier).loadPendingUsers();
        ref.read(adminStateProvider.notifier).loadApprovedUsers();
      });
    });
  }
  
  void _initControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _secondaryPhoneController = TextEditingController();
    _nicknameController = TextEditingController();
    _countryController = TextEditingController();
    _businessNameController = TextEditingController();
    _businessDescController = TextEditingController();
    _whatsappController = TextEditingController();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _nicknameController.dispose();
    _countryController.dispose();
    _businessNameController.dispose();
    _businessDescController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
  
  void _populateFormWithUser(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phoneNumber;
    _secondaryPhoneController.text = user.secondaryPhoneNumber ?? '';
    _nicknameController.text = user.nickname;
    _countryController.text = user.country;
    _businessNameController.text = user.businessName ?? '';
    _businessDescController.text = user.businessDescription ?? '';
    _whatsappController.text = user.whatsappNumber ?? '';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminState = ref.watch(adminStateProvider);
    final mediaQuery = MediaQuery.of(context);
    
    // Combine both pending and approved users for editing
    final allUsers = [...adminState.pendingUsers, ...adminState.approvedUsers];
    
    // Filter users based on search query
    final filteredUsers = _getFilteredUsers(allUsers);
    
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
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
                // Header with title
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 24,
                      child: const Icon(
                        Icons.edit,
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
                            'تعديل بيانات المستخدمين',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'اختر مستخدم من القائمة لتعديل بياناته',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Search field
                TextField(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'بحث عن مستخدم...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: theme.brightness == Brightness.light 
                        ? Colors.white 
                        : Colors.black12,
                  ),
                  onChanged: (value) {
                    // Use debouncing to prevent rapid API calls
                    final cacheService = ref.read(adminCacheServiceProvider);
                    cacheService.debounce('search_query', () {
                      setState(() {
                        _searchQuery = value;
                      });
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Main content - User list
          Expanded(
            child: adminState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredUsers.isEmpty
                ? const EmptyState(
                    message: 'لا يوجد مستخدمين مطابقين للبحث',
                    icon: Icons.person_search,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserListItem(
                        user: user,
                        isSelected: _selectedUser?.id == user.id,
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                            _populateFormWithUser(user);
                          });
                          
                          // Show bottom sheet with user edit form on mobile
                          _showUserEditBottomSheet(context, user);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  /// Shows a bottom sheet with the user edit form
  void _showUserEditBottomSheet(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: mediaQuery.size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Bottom sheet header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
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
                          'تعديل بيانات المستخدم',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          user.name,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: UserEditForm(
                  user: user,
                  formKey: _formKey,
                  onSave: () {
                    _updateUserData();
                    Navigator.of(context).pop();
                  },
                  onCancel: () => Navigator.of(context).pop(),
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  secondaryPhoneController: _secondaryPhoneController,
                  nicknameController: _nicknameController,
                  countryController: _countryController,
                  businessNameController: _businessNameController,
                  businessDescController: _businessDescController,
                  whatsappController: _whatsappController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Filters users based on search query
  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query) ||
             user.phoneNumber.toLowerCase().contains(query) ||
             user.nickname.toLowerCase().contains(query);
    }).toList();
  }
  
  void _updateUserData() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedUser == null) return;
      
      final updatedUser = _selectedUser!.copyWith(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        secondaryPhoneNumber: _secondaryPhoneController.text.isEmpty 
            ? null 
            : _secondaryPhoneController.text,
        nickname: _nicknameController.text,
        country: _countryController.text,
        businessName: _businessNameController.text.isEmpty 
            ? null 
            : _businessNameController.text,
        businessDescription: _businessDescController.text.isEmpty 
            ? null 
            : _businessDescController.text,
        whatsappNumber: _whatsappController.text.isEmpty 
            ? null 
            : _whatsappController.text,
      );
      
      ref.read(adminStateProvider.notifier).updateUserData(updatedUser).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          // Update the selected user with the new data
          setState(() {
            _selectedUser = updatedUser;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل في حفظ التغييرات'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      });
    }
  }
}
