import 'package:flutter/foundation.dart';

/// Model for primitive phone block
class PrimitivePhoneBlockModel {
  /// Phone number
  final String phoneNumber;
  
  /// Reason for blocking
  final String reason;
  
  /// Created at timestamp
  final DateTime createdAt;
  
  /// Created by user ID
  final String? createdBy;
  
  /// Is the block active
  final bool isActive;

  /// Constructor
  const PrimitivePhoneBlockModel({
    required this.phoneNumber,
    required this.reason,
    required this.createdAt,
    this.createdBy,
    required this.isActive,
  });

  /// Create from JSON
  factory PrimitivePhoneBlockModel.fromJson(Map<String, dynamic> json) {
    return PrimitivePhoneBlockModel(
      phoneNumber: json['phone_number'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      isActive: json['is_active'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'is_active': isActive,
    };
  }

  /// Create a copy with updated fields
  PrimitivePhoneBlockModel copyWith({
    String? phoneNumber,
    String? reason,
    DateTime? createdAt,
    String? createdBy,
    bool? isActive,
  }) {
    return PrimitivePhoneBlockModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrimitivePhoneBlockModel &&
        other.phoneNumber == phoneNumber &&
        other.reason == reason &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
        phoneNumber,
        reason,
        createdAt,
        createdBy,
        isActive,
      );
}
