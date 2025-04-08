// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  phoneNumber: json['phoneNumber'] as String,
  secondaryPhoneNumber: json['secondaryPhoneNumber'] as String?,
  nickname: json['nickname'] as String,
  country: json['country'] as String,
  status: json['status'] as String,
  businessName: json['businessName'] as String?,
  businessDescription: json['businessDescription'] as String?,
  workingSolo: json['workingSolo'] as bool?,
  associateIds: json['associateIds'] as String?,
  whatsappNumber: json['whatsappNumber'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': instance.role,
  'phoneNumber': instance.phoneNumber,
  'secondaryPhoneNumber': instance.secondaryPhoneNumber,
  'nickname': instance.nickname,
  'country': instance.country,
  'status': instance.status,
  'businessName': instance.businessName,
  'businessDescription': instance.businessDescription,
  'workingSolo': instance.workingSolo,
  'associateIds': instance.associateIds,
  'whatsappNumber': instance.whatsappNumber,
  'createdAt': instance.createdAt.toIso8601String(),
};
