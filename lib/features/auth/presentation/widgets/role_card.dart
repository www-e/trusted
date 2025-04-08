import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';

/// A card widget for selecting a role during sign-up
class RoleCard extends StatelessWidget {
  /// Title of the role
  final String title;
  
  /// Description of the role
  final String description;
  
  /// Icon for the role
  final IconData icon;
  
  /// Whether this role is selected
  final bool isSelected;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Constructor
  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1) 
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : theme.brightness == Brightness.light
                    ? AppColors.lightBorder
                    : AppColors.darkBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary 
                    : theme.brightness == Brightness.light
                        ? AppColors.lightBackground
                        : AppColors.darkBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white 
                    : theme.brightness == Brightness.light
                        ? AppColors.darkText
                        : AppColors.lightText,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected 
                          ? AppColors.primary 
                          : null,
                      fontWeight: isSelected 
                          ? FontWeight.bold 
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
