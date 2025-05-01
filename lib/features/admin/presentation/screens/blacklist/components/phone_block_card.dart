import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trusted/core/theme/colors.dart';
import 'package:trusted/features/admin/domain/models/primitive_phone_block_model.dart';

/// Card widget to display a primitive phone block
class PhoneBlockCard extends StatelessWidget {
  /// The phone block to display
  final PrimitivePhoneBlockModel block;
  
  /// Callback when the unblock button is pressed
  final VoidCallback onUnblock;

  /// Constructor
  const PhoneBlockCard({
    super.key,
    required this.block,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: block.isActive ? AppColors.error.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              children: [
                Icon(
                  Icons.phone_disabled,
                  color: block.isActive ? AppColors.error : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'حظر رقم هاتف',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: block.isActive ? AppColors.error.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    block.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      color: block.isActive ? AppColors.error : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Phone number details
            _buildDetailRow('رقم الهاتف:', block.phoneNumber),
            _buildDetailRow('سبب الحظر:', block.reason),
            _buildDetailRow('تاريخ الحظر:', dateFormat.format(block.createdAt)),
            
            if (block.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUnblock,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('إلغاء الحظر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
