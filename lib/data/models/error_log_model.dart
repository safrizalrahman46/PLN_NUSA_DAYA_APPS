import 'app_enums.dart';

class ErrorLogModel {
  const ErrorLogModel({
    required this.id,
    required this.createdAt,
    required this.page,
    required this.errorType,
    required this.message,
    required this.detail,
    this.userId = '',
    this.userName = '',
    this.role = UserRole.operator,
    this.stackTrace = '',
    this.status = ErrorLogStatus.baru,
    this.source = 'app',
    this.metadata = const {},
  });

  final String id;
  final DateTime createdAt;
  final String page;
  final String errorType;
  final String message;
  final String detail;
  final String userId;
  final String userName;
  final UserRole role;
  final String stackTrace;
  final ErrorLogStatus status;
  final String source;
  final Map<String, dynamic> metadata;

  ErrorLogModel copyWith({
    String? id,
    DateTime? createdAt,
    String? page,
    String? errorType,
    String? message,
    String? detail,
    String? userId,
    String? userName,
    UserRole? role,
    String? stackTrace,
    ErrorLogStatus? status,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    return ErrorLogModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      page: page ?? this.page,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
      detail: detail ?? this.detail,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      stackTrace: stackTrace ?? this.stackTrace,
      status: status ?? this.status,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'page': page,
    'errorType': errorType,
    'message': message,
    'detail': detail,
    'userId': userId,
    'userName': userName,
    'role': role.name,
    'stackTrace': stackTrace,
    'status': status.name,
    'source': source,
    'metadata': metadata,
  };

  factory ErrorLogModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return ErrorLogModel(
      id: json['id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      page: json['page']?.toString() ?? '-',
      errorType: json['errorType']?.toString() ?? 'UnknownError',
      message: json['message']?.toString() ?? 'Terjadi kesalahan',
      detail: json['detail']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      role: parseUserRole(json['role']?.toString()),
      stackTrace: json['stackTrace']?.toString() ?? '',
      status: parseErrorLogStatus(json['status']?.toString()),
      source: json['source']?.toString() ?? 'app',
      metadata: metadata is Map
          ? Map<String, dynamic>.from(metadata)
          : <String, dynamic>{},
    );
  }
}
