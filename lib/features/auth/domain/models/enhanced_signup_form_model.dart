import 'package:trusted/core/constants/app_constants.dart';

/// Enhanced model to handle the multi-step sign-up form data with additional fields
class EnhancedSignupFormModel {
  /// User's selected role
  final String role;
  
  /// User's full name
  final String name;
  
  /// User's email from Google account
  final String email;
  
  /// User's phone number with country code
  final String phoneNumber;
  
  /// User's WhatsApp number with country code
  final String whatsappNumber;
  
  /// User's Vodafone Cash number with country code
  final String vodafoneCashNumber;
  
  /// User's nickname/business name
  final String nickname;
  
  /// User's country
  final String country;
  
  /// User's selfie photo URL (for merchant and mediator)
  final String? selfiePhotoUrl;
  
  /// User's front ID photo URL (for merchant and mediator)
  final String? frontIdPhotoUrl;
  
  /// User's back ID photo URL (for merchant and mediator)
  final String? backIdPhotoUrl;
  
  /// Username for secondary login
  final String username;
  
  /// Password for secondary login
  final String password;
  
  /// Constructor
  EnhancedSignupFormModel({
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.vodafoneCashNumber,
    required this.nickname,
    required this.country,
    this.selfiePhotoUrl,
    this.frontIdPhotoUrl,
    this.backIdPhotoUrl,
    required this.username,
    required this.password,
  });

  /// Creates a copy of this EnhancedSignupFormModel with the given fields replaced
  EnhancedSignupFormModel copyWith({
    String? role,
    String? name,
    String? email,
    String? phoneNumber,
    String? whatsappNumber,
    String? vodafoneCashNumber,
    String? nickname,
    String? country,
    String? selfiePhotoUrl,
    String? frontIdPhotoUrl,
    String? backIdPhotoUrl,
    String? username,
    String? password,
  }) {
    return EnhancedSignupFormModel(
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      vodafoneCashNumber: vodafoneCashNumber ?? this.vodafoneCashNumber,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      selfiePhotoUrl: selfiePhotoUrl ?? this.selfiePhotoUrl,
      frontIdPhotoUrl: frontIdPhotoUrl ?? this.frontIdPhotoUrl,
      backIdPhotoUrl: backIdPhotoUrl ?? this.backIdPhotoUrl,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  /// Converts this EnhancedSignupFormModel to a Map for database storage
  Map<String, dynamic> toJson() {
    final status = role == AppConstants.roleBuyerSeller
        ? AppConstants.statusActive
        : AppConstants.statusPending;
        
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'vodafone_cash_number': vodafoneCashNumber,
      'nickname': nickname,
      'country': country,
      'status': status,
      'selfie_photo_url': selfiePhotoUrl,
      'front_id_photo_url': frontIdPhotoUrl,
      'back_id_photo_url': backIdPhotoUrl,
      'username': username,
    };
  }

  /// Creates an initial EnhancedSignupFormModel with data from Google account
  factory EnhancedSignupFormModel.initial({
    required String name,
    required String email,
  }) {
    return EnhancedSignupFormModel(
      role: AppConstants.roleBuyerSeller,
      name: name,
      email: email,
      phoneNumber: '',
      whatsappNumber: '',
      vodafoneCashNumber: '',
      nickname: '',
      country: '',
      username: '',
      password: '',
    );
  }
  
  /// Creates an EnhancedSignupFormModel from JSON data
  factory EnhancedSignupFormModel.fromJson(Map<String, dynamic> json) {
    return EnhancedSignupFormModel(
      role: json['role'] ?? AppConstants.roleBuyerSeller,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      vodafoneCashNumber: json['vodafone_cash_number'] ?? '',
      nickname: json['nickname'] ?? '',
      country: json['country'] ?? '',
      selfiePhotoUrl: json['selfie_photo_url'],
      frontIdPhotoUrl: json['front_id_photo_url'],
      backIdPhotoUrl: json['back_id_photo_url'],
      username: json['username'] ?? '',
      password: json['password'] ?? '', // Password is typically not stored in JSON
    );
  }

  /// Checks if the form is valid for the current step
  bool isValidForStep(int step) {
    // For merchant and mediator, there are 5 steps
    // For buyer_seller, there are 4 steps (no ID photos)
    
    switch (step) {
      case 1: // Role selection
        return role.isNotEmpty;
        
      case 2: // Basic information (name, email, phone, country)
        return name.isNotEmpty && 
               email.isNotEmpty && 
               _isValidPhoneNumber(phoneNumber) && 
               country.isNotEmpty;
               
      case 3: // Additional contact information (WhatsApp, Vodafone Cash, nickname)
        return _isValidPhoneNumber(whatsappNumber) && 
               _isValidPhoneNumber(vodafoneCashNumber) && 
               nickname.isNotEmpty;
               
      case 4: 
        // For buyer_seller: Username and password
        if (role == AppConstants.roleBuyerSeller) {
          return _isValidUsername(username) && _isValidPassword(password);
        }
        // For merchant and mediator: ID photos
        else {
          return selfiePhotoUrl != null && 
                 frontIdPhotoUrl != null && 
                 backIdPhotoUrl != null;
        }
        
      case 5: // Username and password (only for merchant and mediator)
        if (role == AppConstants.roleBuyerSeller) {
          return true; // Buyer/seller doesn't have step 5
        }
        return _isValidUsername(username) && _isValidPassword(password);
        
      default:
        return false;
    }
  }
  
  /// Get the total number of steps based on user role
  int getTotalSteps() {
    return role == AppConstants.roleBuyerSeller ? 4 : 5;
  }
  
  /// Validate phone number format
  bool _isValidPhoneNumber(String phone) {
    // Basic validation: non-empty and contains only digits, +, and spaces
    if (phone.isEmpty) return false;
    
    // Remove spaces and check if it contains only digits and optionally starts with +
    final cleanPhone = phone.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    return phoneRegex.hasMatch(cleanPhone) && cleanPhone.length >= 8;
  }
  
  /// Validate username format
  bool _isValidUsername(String username) {
    // Username should be at least 4 characters and contain only letters, numbers, and underscores
    if (username.length < 4) return false;
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    return usernameRegex.hasMatch(username);
  }
  
  /// Validate password strength
  bool _isValidPassword(String password) {
    // Password should be at least 8 characters and contain at least one letter and one number
    if (password.length < 8) return false;
    
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    
    return hasLetter && hasNumber;
  }
}
