import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// Utility class for form validation functions
class FormValidators {
  /// Validate phone number format with country-specific validation
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
    
    // Country-specific validation
    if (cleanPhone.startsWith('+20') || cleanPhone.startsWith('20') || cleanPhone.startsWith('0')) {
      // Egypt - should be 11 digits (excluding country code)
      final digitsOnly = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final isEgyptMobile = cleanPhone.startsWith('+20') ? digitsOnly.length == 12 : 
                           cleanPhone.startsWith('20') ? digitsOnly.length == 11 :
                           cleanPhone.startsWith('0') ? digitsOnly.length == 11 : false;
      
      if (!isEgyptMobile) {
        return 'رقم الهاتف المصري يجب أن يتكون من 11 رقم';
      }
    } else if (cleanPhone.startsWith('+966') || cleanPhone.startsWith('966')) {
      // Saudi Arabia - should be 9 digits (excluding country code)
      final digitsOnly = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final isSaudiMobile = cleanPhone.startsWith('+966') ? digitsOnly.length == 12 : 
                           cleanPhone.startsWith('966') ? digitsOnly.length == 12 : false;
      
      if (!isSaudiMobile) {
        return 'رقم الهاتف السعودي يجب أن يتكون من 9 أرقام بعد كود الدولة';
      }
    } else if (cleanPhone.startsWith('+971') || cleanPhone.startsWith('971')) {
      // UAE - should be 9 digits (excluding country code)
      final digitsOnly = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final isUAEMobile = cleanPhone.startsWith('+971') ? digitsOnly.length == 12 : 
                         cleanPhone.startsWith('971') ? digitsOnly.length == 12 : false;
      
      if (!isUAEMobile) {
        return 'رقم الهاتف الإماراتي يجب أن يتكون من 9 أرقام بعد كود الدولة';
      }
    } else if (cleanPhone.length < 8) {
      // Generic validation for other countries
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
