import 'app_enums.dart';

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.priority,
    required this.type,
    required this.targetType,
    this.read = false,
    this.userId,
    this.localId,
    this.errorLogId,
    this.unitId,
    this.payload = const {},
    this.recipientRoles = const <String>[],
  });

  final String id;
  final String title;
  final String description;
  final DateTime time;
  final NotificationPriority priority;
  final String type;
  final NotificationTargetType targetType;
  final bool read;
  final String? userId;
  final String? localId;
  final String? errorLogId;
  final String? unitId;
  final Map<String, dynamic> payload;
  final List<String> recipientRoles;

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? time,
    NotificationPriority? priority,
    String? type,
    NotificationTargetType? targetType,
    bool? read,
    String? userId,
    String? localId,
    String? errorLogId,
    String? unitId,
    Map<String, dynamic>? payload,
    List<String>? recipientRoles,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      targetType: targetType ?? this.targetType,
      read: read ?? this.read,
      userId: userId ?? this.userId,
      localId: localId ?? this.localId,
      errorLogId: errorLogId ?? this.errorLogId,
      unitId: unitId ?? this.unitId,
      payload: payload ?? this.payload,
      recipientRoles: recipientRoles ?? this.recipientRoles,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'time': time.toIso8601String(),
    'priority': priority.name,
    'type': type,
    'targetType': targetType.name,
    'read': read,
    'userId': userId,
    'localId': localId,
    'errorLogId': errorLogId,
    'unitId': unitId,
    'payload': payload,
    'recipientRoles': recipientRoles,
  };

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final roles = json['recipientRoles'];
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      priority: parseNotificationPriority(json['priority']?.toString()),
      type: json['type']?.toString() ?? 'general',
      targetType: parseNotificationTargetType(json['targetType']?.toString()),
      read: json['read'] == true,
      userId: json['userId']?.toString(),
      localId: json['localId']?.toString(),
      errorLogId: json['errorLogId']?.toString(),
      unitId: json['unitId']?.toString(),
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{},
      recipientRoles: roles is List
          ? roles.map((item) => item.toString()).toList()
          : const <String>[],
    );
  }
}
