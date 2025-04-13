import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Utility class for form validation functions
class FormValidators {
  /// Validate phone number format
  static String? validatePhoneNumber(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    
    // Remove spaces and check if it contains only digits and optionally starts with +
    final cleanPhone = value.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }
    
    if (cleanPhone.length < 8) {
      return 'رقم الهاتف قصير جدًا';
    }
    
    return null;
  }
  
  /// Get a composed validator for phone numbers
  static FormFieldValidator<String> phoneValidator(BuildContext context) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'الرجاء إدخال رقم الهاتف'),
      (String? value) => validatePhoneNumber(value, context),
    ]);
  }
  
  /// Validate username format
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال اسم المستخدم';
    }
    
    if (value.length < 4) {
      return 'اسم المستخدم يجب أن يكون 4 أحرف على الأقل';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام وشرطات سفلية فقط';
    }
    
    return null;
  }
  
  /// Get a composed validator for usernames
  static FormFieldValidator<String> usernameValidator() {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'الرجاء إدخال اسم المستخدم'),
      (String? value) => validateUsername(value),
    ]);
  }
  
  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    
    if (!hasLetter || !hasNumber) {
      return 'كلمة المرور يجب أن تحتوي على حرف واحد ورقم واحد على الأقل';
    }
    
    return null;
  }
  
  /// Get a composed validator for passwords
  static FormFieldValidator<String> passwordValidator() {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'الرجاء إدخال كلمة المرور'),
      (String? value) => validatePassword(value),
    ]);
  }
  
  /// Validate text field is not empty
  static FormFieldValidator<String> requiredValidator(String errorMessage) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: errorMessage),
    ]);
  }
  
  /// Validate email format
  static FormFieldValidator<String> emailValidator() {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: 'الرجاء إدخال البريد الإلكتروني'),
      FormBuilderValidators.email(errorText: 'الرجاء إدخال بريد إلكتروني صحيح'),
    ]);
  }
}
