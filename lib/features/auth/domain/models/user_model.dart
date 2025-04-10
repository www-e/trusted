import 'package:json_annotation/json_annotation.dart';
import 'package:trusted/core/constants/app_constants.dart';

part 'user_model.g.dart';

/// User model representing a user in the application
@JsonSerializable()
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's full name
  final String name;

  /// User's role (buyer_seller, merchant, mediator, admin)
  final String role;

  /// User's phone number
  final String phoneNumber;

  /// User's secondary phone number (optional)
  final String? secondaryPhoneNumber;

  /// User's nickname
  final String nickname;

  /// User's country
  final String country;

  /// User's status (active, pending)
  final String status;

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

  /// When the user was created
  final DateTime createdAt;

  /// When the user was accepted/activated
  final DateTime? acceptedAt;

  /// Constructor
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.phoneNumber,
    this.secondaryPhoneNumber,
    required this.nickname,
    required this.country,
    required this.status,
    this.businessName,
    this.businessDescription,
    this.workingSolo,
    this.associateIds,
    this.whatsappNumber,
    required this.createdAt,
    this.acceptedAt,
  });

  /// Creates a new UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);

  /// Converts this UserModel to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a copy of this UserModel with the given fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? secondaryPhoneNumber,
    String? nickname,
    String? country,
    String? status,
    String? businessName,
    String? businessDescription,
    bool? workingSolo,
    String? associateIds,
    String? whatsappNumber,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      secondaryPhoneNumber: secondaryPhoneNumber ?? this.secondaryPhoneNumber,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      status: status ?? this.status,
      businessName: businessName ?? this.businessName,
      businessDescription: businessDescription ?? this.businessDescription,
      workingSolo: workingSolo ?? this.workingSolo,
      associateIds: associateIds ?? this.associateIds,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }

  /// Creates an empty UserModel
  factory UserModel.empty() => UserModel(
        id: '',
        email: '',
        name: '',
        role: AppConstants.roleBuyerSeller,
        phoneNumber: '',
        nickname: '',
        country: '',
        status: AppConstants.statusActive,
        createdAt: DateTime.now(),
        acceptedAt: null,
      );

  /// Checks if this UserModel is empty
  bool get isEmpty => id.isEmpty;

  /// Checks if this UserModel is not empty
  bool get isNotEmpty => !isEmpty;

  /// Checks if this user is an admin
  bool get isAdmin => email == AppConstants.adminEmail;

  /// Checks if this user is a buyer/seller
  bool get isBuyerSeller => role == AppConstants.roleBuyerSeller;

  /// Checks if this user is a merchant
  bool get isMerchant => role == AppConstants.roleMerchant;

  /// Checks if this user is a mediator
  bool get isMediator => role == AppConstants.roleMediator;

  /// Checks if this user is active
  bool get isActive => status == AppConstants.statusActive;

  /// Checks if this user is pending
  bool get isPending => status == AppConstants.statusPending;

  /// Checks if this user is rejected
  bool get isRejected => status == AppConstants.statusRejected;

}
