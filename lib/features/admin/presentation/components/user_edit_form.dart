import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// A component for editing user data in the admin users screen
class UserEditForm extends StatefulWidget {
  /// The user to edit
  final UserModel user;
  
  /// Form key for validation
  final GlobalKey<FormState> formKey;
  
  /// Callback when the save button is pressed
  final VoidCallback onSave;
  
  /// Callback when the cancel button is pressed
  final VoidCallback onCancel;
  
  /// Controllers for form fields
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController secondaryPhoneController;
  final TextEditingController nicknameController;
  final TextEditingController countryController;
  final TextEditingController businessNameController;
  final TextEditingController businessDescController;
  final TextEditingController whatsappController;

  /// Constructor
  const UserEditForm({
    super.key,
    required this.user,
    required this.formKey,
    required this.onSave,
    required this.onCancel,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.secondaryPhoneController,
    required this.nicknameController,
    required this.countryController,
    required this.businessNameController,
    required this.businessDescController,
    required this.whatsappController,
  });

  @override
  State<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;
    
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Note about photos
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.photo_library, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'ملاحظة حول الصور',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'يمكن مشاهدة صور الهوية الشخصية من خلال قاعدة البيانات المباشرة',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          // User ID and status information
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('معرف المستخدم', style: theme.textTheme.bodySmall),
                            Text(user.id, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AdminFormatters.getStatusColor(user.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          AdminFormatters.getStatusText(user.status),
                          style: TextStyle(
                            color: AdminFormatters.getStatusColor(user.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('تاريخ التسجيل: ${DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt)}', 
                       style: theme.textTheme.bodySmall),
                  if (user.acceptedAt != null)
                    Text('تاريخ التفعيل: ${DateFormat('yyyy-MM-dd HH:mm').format(user.acceptedAt!)}', 
                         style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          // Form title
          Text(
            'تعديل بيانات المستخدم',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Basic information section
          Text(
            'المعلومات الأساسية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name field
          TextFormField(
            controller: widget.nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(),
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
          
          // Email field (readonly)
          TextFormField(
            controller: widget.emailController,
            readOnly: true, // Email should not be editable
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              helperText: 'لا يمكن تغيير البريد الإلكتروني',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nickname field
          TextFormField(
            controller: widget.nicknameController,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم المستخدم';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Phone field
          TextFormField(
            controller: widget.phoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(),
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
          
          // Secondary phone field
          TextFormField(
            controller: widget.secondaryPhoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف الثانوي (اختياري)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          // Country field
          TextFormField(
            controller: widget.countryController,
            decoration: const InputDecoration(
              labelText: 'البلد',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال البلد';
              }
              return null;
            },
          ),
          
          // Contact information section
          const SizedBox(height: 16),
          
          TextFormField(
            controller: widget.phoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(),
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
          
          TextFormField(
            controller: widget.secondaryPhoneController,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف الثانوي (اختياري)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: widget.whatsappController,
            decoration: const InputDecoration(
              labelText: 'رقم الواتساب',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          // Business information section (only for merchants)
          if (user.isMerchant) ...[
            const SizedBox(height: 32),
            
            Text(
              'معلومات النشاط التجاري',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Business name field
            TextFormField(
              controller: widget.businessNameController,
              decoration: const InputDecoration(
                labelText: 'اسم النشاط التجاري',
                border: OutlineInputBorder(),
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
              controller: widget.businessDescController,
              decoration: const InputDecoration(
                labelText: 'وصف النشاط التجاري',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
          
          // Additional information section
          const SizedBox(height: 32),
          
          Text(
            'معلومات إضافية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mediator information section (only for mediators)
          if (user.isMediator) ...[
            const SizedBox(height: 32),
            
            Text(
              'معلومات الوسيط',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Additional mediator fields can be added here
            Text(
              'معلومات الوسيط مهمة للتواصل بين المشترين والبائعين',
              style: theme.textTheme.bodySmall,
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onCancel,
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
                  onPressed: widget.onSave,
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
}
