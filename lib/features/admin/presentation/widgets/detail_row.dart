import 'package:flutter/material.dart';
import 'package:trusted/core/theme/colors.dart';

/// A reusable widget for displaying a labeled detail row with an icon
/// Used across admin screens to show user information in a consistent format
class DetailRow extends StatelessWidget {
  /// The icon to display
  final IconData icon;
  
  /// The label text (displayed in bold)
  final String label;
  
  /// The value text
  final String value;

  /// Constructor
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.brightness == Brightness.light
                ? AppColors.darkText.withOpacity(0.6)
                : AppColors.lightText.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
