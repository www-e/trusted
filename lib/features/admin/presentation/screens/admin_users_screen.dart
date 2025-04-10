import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/notifiers/admin_notifier.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// Admin screen for editing user data
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
      ref.read(adminStateProvider.notifier).loadPendingUsers();
      ref.read(adminStateProvider.notifier).loadApprovedUsers();
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
    
    // Combine both pending and approved users for editing
    final allUsers = [...adminState.pendingUsers, ...adminState.approvedUsers];
    
    // Filter users based on search query
    final filteredUsers = _searchQuery.isEmpty
        ? allUsers
        : allUsers.where((user) {
            final query = _searchQuery.toLowerCase();
            return user.name.toLowerCase().contains(query) ||
                   user.email.toLowerCase().contains(query) ||
                   user.phoneNumber.toLowerCase().contains(query) ||
                   user.nickname.toLowerCase().contains(query);
          }).toList();
    
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
                // Users info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 24,
                      child: Icon(
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
                            'قم بتحديث معلومات المستخدمين',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search section
          Padding(
            padding: const EdgeInsets.all(16.0),
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Users list and edit form
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Users list
                Expanded(
                  flex: 1,
                  child: adminState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return _buildUserListItem(user);
                              },
                            ),
                ),
                
                // Vertical divider
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: theme.brightness == Brightness.light
                      ? AppColors.lightBorder
                      : AppColors.darkBorder,
                ),
                
                // Edit form
                Expanded(
                  flex: 2,
                  child: _selectedUser == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 64,
                                color: theme.brightness == Brightness.light
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'اختر مستخدم للتعديل',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildEditForm(),
                        ),
                ),
              ],
            ),
          ),
        ],
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
            'لا يوجد مستخدمين',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي مستخدمين مطابقين لبحثك',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserListItem(UserModel user) {
    final theme = Theme.of(context);
    final isSelected = _selectedUser?.id == user.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : theme.brightness == Brightness.light
              ? Colors.white
              : AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : theme.brightness == Brightness.light
                  ? AppColors.lightBorder
                  : AppColors.darkBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedUser = user;
            _populateFormWithUser(user);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(user.status).withOpacity(0.1),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: _getStatusColor(user.status),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getRoleArabic(user.role),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(user.status),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEditForm() {
    if (_selectedUser == null) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final user = _selectedUser!;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getStatusColor(user.status).withOpacity(0.1),
                radius: 32,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: _getStatusColor(user.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعديل بيانات المستخدم',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getRoleArabic(user.role),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _getStatusColor(user.status),
                      ),
                    ),
                    Text(
                      'تاريخ التسجيل: ${_formatDate(user.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // Basic information section
          Text(
            'المعلومات الأساسية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال الاسم الكامل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email field (disabled)
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
            ),
            enabled: false, // Email cannot be changed
          ),
          const SizedBox(height: 16),
          
          // Phone number field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال رقم الهاتف';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Secondary phone number field
          TextFormField(
            controller: _secondaryPhoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف الثانوي (اختياري)',
              prefixIcon: Icon(Icons.phone_android),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          // Nickname field
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: 'اللقب',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اللقب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Country field
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'البلد',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال البلد';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Role-specific fields
          if (user.isMerchant) ...[
            const Divider(),
            const SizedBox(height: 24),
            
            Text(
              'معلومات التاجر',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Business name field
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'اسم النشاط التجاري',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (user.isMerchant && (value == null || value.isEmpty)) {
                  return 'الرجاء إدخال اسم النشاط التجاري';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Business description field
            TextFormField(
              controller: _businessDescController,
              decoration: const InputDecoration(
                labelText: 'وصف النشاط التجاري',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (user.isMerchant && (value == null || value.isEmpty)) {
                  return 'الرجاء إدخال وصف النشاط التجاري';
                }
                return null;
              },
            ),
          ],
          
          if (user.isMediator) ...[
            const Divider(),
            const SizedBox(height: 24),
            
            Text(
              'معلومات الوسيط',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // WhatsApp number field
            TextFormField(
              controller: _whatsappController,
              decoration: const InputDecoration(
                labelText: 'رقم الواتساب',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (user.isMediator && (value == null || value.isEmpty)) {
                  return 'الرجاء إدخال رقم الواتساب';
                }
                return null;
              },
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUser = null;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _updateUserData,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التغييرات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusActive:
        return AppColors.success;
      case AppConstants.statusPending:
        return AppColors.warning;
      case AppConstants.statusRejected:
        return AppColors.error;
      default:
        return Colors.grey;
    }
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
