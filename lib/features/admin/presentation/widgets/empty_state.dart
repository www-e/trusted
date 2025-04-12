import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';

/// A reusable widget for displaying an empty state
/// Used across admin screens when there is no data to display
class EmptyState extends StatelessWidget {
  /// The message to display
  final String message;
  
  /// The icon to display
  final IconData icon;
  
  /// Optional action button
  final Widget? actionButton;

  /// Constructor
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
