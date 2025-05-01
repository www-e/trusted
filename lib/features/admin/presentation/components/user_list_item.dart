import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/presentation/widgets/status_badge.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';
import 'package:trusted/features/auth/domain/models/user_model.dart';

/// A component for displaying a user list item in the admin users screen
class UserListItem extends StatelessWidget {
  /// The user to display
  final UserModel user;
  
  /// Callback when the item is tapped
  final VoidCallback onTap;
  
  /// Whether the item is selected
  final bool isSelected;
  
  /// Callback when the block button is pressed
  final VoidCallback? onBlock;

  /// Constructor
  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    this.isSelected = false,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: AppColors.primary, width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            textDirection: TextDirection.rtl, // Ensure RTL layout
            children: [
              // Block button (if provided)
              if (onBlock != null)
                IconButton(
                  icon: const Icon(Icons.block, size: 18),
                  color: Colors.deepOrange,
                  tooltip: 'حظر المستخدم',
                  onPressed: onBlock,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                
              // Status badge (right side in RTL)
              StatusBadge(status: user.status),
              
              const SizedBox(width: 8),
              
              // User avatar
              CircleAvatar(
                backgroundColor: isSelected 
                    ? AppColors.primary 
                    : AdminFormatters.getStatusColor(user.status).withOpacity(0.1),
                radius: 20,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : AdminFormatters.getStatusColor(user.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // User details (takes remaining space)
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
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
