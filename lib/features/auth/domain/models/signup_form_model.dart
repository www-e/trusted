import 'package:trusted/core/constants/app_constants.dart';

/// Model to handle the sign-up form data
class SignupFormModel {
  /// User's selected role
  final String role;
  
  /// User's name from Google account
  final String name;
  
  /// User's email from Google account
  final String email;
  
  /// User's phone number
  final String phoneNumber;
  
  /// User's secondary phone number (optional)
  final String? secondaryPhoneNumber;
  
  /// User's nickname
  final String nickname;
  
  /// User's country
  final String country;
  
  /// Business name (for merchants)
  final String? businessName;
  
  /// Business description (for merchants)
  final String? businessDescription;
  
  /// Whether the merchant works solo
  final bool? workingSolo;
  
  /// IDs of associates (for merchants not working solo)
  final String? associateIds;
  
  /// WhatsApp number (for mediators)
  final String? whatsappNumber;

  /// Constructor
  SignupFormModel({
    required this.role,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.secondaryPhoneNumber,
    required this.nickname,
    required this.country,
    this.businessName,
    this.businessDescription,
    this.workingSolo,
    this.associateIds,
    this.whatsappNumber,
  });

  /// Creates a copy of this SignupFormModel with the given fields replaced
  SignupFormModel copyWith({
    String? role,
    String? name,
    String? email,
    String? phoneNumber,
    String? secondaryPhoneNumber,
    String? nickname,
    String? country,
    String? businessName,
    String? businessDescription,
    bool? workingSolo,
    String? associateIds,
    String? whatsappNumber,
  }) {
    return SignupFormModel(
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      secondaryPhoneNumber: secondaryPhoneNumber ?? this.secondaryPhoneNumber,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      workingSolo: workingSolo ?? this.workingSolo,
      associateIds: associateIds ?? this.associateIds,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  /// Converts this SignupFormModel to a Map
  Map<String, dynamic> toJson() {
    final status = role == AppConstants.roleBuyerSeller
        ? AppConstants.statusActive
        : AppConstants.statusPending;
        
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone_number': phoneNumber,
      'secondary_phone_number': secondaryPhoneNumber,
      'nickname': nickname,
      'country': country,
      'status': status,
      'business_name': businessName,
      'business_description': businessDescription,
      'working_solo': workingSolo,
      'associate_ids': associateIds,
      'whatsapp_number': whatsappNumber,
    };
  }

  /// Creates an initial SignupFormModel with data from Google account
  factory SignupFormModel.initial({
    required String name,
    required String email,
  }) {
    return SignupFormModel(
      role: AppConstants.roleBuyerSeller,
      name: name,
      email: email,
      phoneNumber: '',
      nickname: '',
      country: '',
    );
  }

  /// Checks if the form is valid for the current step
  bool isValidForStep(int step) {
    switch (step) {
      case 1: // Role selection
        return role.isNotEmpty;
      case 2: // Information entry
        final bool basicInfoValid = phoneNumber.isNotEmpty && 
                                   nickname.isNotEmpty && 
                                   country.isNotEmpty;
                                   
        if (!basicInfoValid) return false;
        
        if (role == AppConstants.roleMerchant) {
          final bool merchantInfoValid = businessName != null && 
                                       businessName!.isNotEmpty && 
                                       businessDescription != null && 
                                       businessDescription!.isNotEmpty && 
                                       workingSolo != null;
                                       
          if (!merchantInfoValid) return false;
          
          if (workingSolo == false) {
            return associateIds != null && associateIds!.isNotEmpty;
          }
        } else if (role == AppConstants.roleMediator) {
          return whatsappNumber != null && whatsappNumber!.isNotEmpty;
        }
        
        return true;
      default:
        return false;
    }
  }
}
