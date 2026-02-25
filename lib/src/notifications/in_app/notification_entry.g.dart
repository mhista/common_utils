// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationEntry _$NotificationEntryFromJson(Map<String, dynamic> json) =>
    _NotificationEntry(
      id: json['id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      imageUrl: json['imageUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      type: json['type'] as String? ?? 'general',
      channelId: json['channelId'] as String? ?? 'general',
      data: json['data'] as Map<String, dynamic>? ?? const {},
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationEntryToJson(_NotificationEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'imageUrl': instance.imageUrl,
      'deepLink': instance.deepLink,
      'type': instance.type,
      'channelId': instance.channelId,
      'data': instance.data,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'isRead': instance.isRead,
    };
