import 'package:flutter/material.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/utils/admin_formatters.dart';

/// A reusable widget for displaying a user status badge
/// Used across admin screens to show user status in a consistent format
class StatusBadge extends StatelessWidget {
  /// The status to display
  final String status;
  
  /// Optional custom text to display
  final String? customText;

  /// Constructor
  const StatusBadge({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status == AppConstants.statusRejected;
    final isPending = status == AppConstants.statusPending;
    final color = AdminFormatters.getStatusColor(status);
    
    final displayText = customText ?? (isRejected 
        ? 'تم الرفض' 
        : isPending 
            ? 'قيد المراجعة' 
            : 'تم التفعيل');
    
    final icon = isRejected 
        ? Icons.cancel 
        : isPending 
            ? Icons.pending 
            : Icons.check_circle;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
