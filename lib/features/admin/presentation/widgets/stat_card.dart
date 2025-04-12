import 'package:flutter/material.dart';

/// A reusable widget for displaying statistics in a card format
/// Used in admin dashboard and history screens
class StatCard extends StatelessWidget {
  /// The title of the statistic
  final String title;
  
  /// The value to display (as a string)
  final String value;
  
  /// The icon to display
  final IconData icon;
  
  /// The accent color for the card
  final Color color;

  /// Constructor
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light 
            ? Colors.white 
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.light 
                  ? theme.textTheme.bodyLarge?.color 
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.brightness == Brightness.light 
                  ? Colors.black54 
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
