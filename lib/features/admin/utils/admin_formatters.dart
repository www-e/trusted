import 'package:flutter/material.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/core/theme/colors.dart';

/// Utility class for formatting and display helpers used in admin screens
class AdminFormatters {
  /// Converts role constants to Arabic display text
  static String getRoleArabic(String role) {
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

  /// Formats a date for display in the UI
  /// Shows full date and time in a consistent format
  static String formatDateTime(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  /// Formats a date for display in the UI (date only)
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Gets the appropriate color for a user status
  static Color getStatusColor(String status) {
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
}
