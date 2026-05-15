import 'app_enums.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.unitId,
    required this.unitName,
    required this.token,
  });

  final String id;
  final String name;
  final String username;
  final UserRole role;
  final String unitId;
  final String unitName;
  final String token;

  bool get isOperator => role == UserRole.operator;
  bool get isSupervisor => role == UserRole.supervisor;
  bool get isAdmin => role == UserRole.admin;
  bool get isSuperadmin => role == UserRole.superadmin;
  bool get canManageMasterData => isAdmin || isSuperadmin;
  bool get canManageSystem => isSuperadmin;

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    UserRole? role,
    String? unitId,
    String? unitName,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'role': role.name,
    'unitId': unitId,
    'unitName': unitName,
    'token': token,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: parseUserRole(json['role']?.toString()),
      unitId: json['unitId']?.toString() ?? '',
      unitName: json['unitName']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}
