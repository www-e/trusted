import 'package:flutter/foundation.dart';

/// Model for blacklist entries
class BlacklistModel {
  /// Blacklist entry ID
  final String id;
  
  /// User ID (optional)
  final String? userId;
  
  /// Email (optional)
  final String? email;
  
  /// Phone number (optional)
  final String? phoneNumber;
  
  /// Device ID (optional)
  final String? deviceId;
  
  /// Reason for blacklisting
  final String reason;
  
  /// Banned at timestamp
  final DateTime bannedAt;
  
  /// Banned by user ID
  final String? bannedBy;
  
  /// Is the blacklist entry active
  final bool isActive;
  
  /// Created at timestamp
  final DateTime createdAt;
  
  /// Updated at timestamp
  final DateTime? updatedAt;

  /// Constructor
  const BlacklistModel({
    required this.id,
    this.userId,
    this.email,
    this.phoneNumber,
    this.deviceId,
    required this.reason,
    required this.bannedAt,
    this.bannedBy,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory BlacklistModel.fromJson(Map<String, dynamic> json) {
    return BlacklistModel(
      id: json['id'],
      userId: json['user_id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      deviceId: json['device_id'],
      reason: json['reason'],
      bannedAt: DateTime.parse(json['banned_at']),
      bannedBy: json['banned_by'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone_number': phoneNumber,
      'device_id': deviceId,
      'reason': reason,
      'banned_at': bannedAt.toIso8601String(),
      'banned_by': bannedBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  BlacklistModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? phoneNumber,
    String? deviceId,
    String? reason,
    DateTime? bannedAt,
    String? bannedBy,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BlacklistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceId: deviceId ?? this.deviceId,
      reason: reason ?? this.reason,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedBy: bannedBy ?? this.bannedBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlacklistModel &&
        other.id == id &&
        other.userId == userId &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.deviceId == deviceId &&
        other.reason == reason &&
        other.bannedAt == bannedAt &&
        other.bannedBy == bannedBy &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        email,
        phoneNumber,
        deviceId,
        reason,
        bannedAt,
        bannedBy,
        isActive,
        createdAt,
        updatedAt,
      );
}
