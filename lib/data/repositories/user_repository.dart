import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../local/hive_service.dart';
import '../models/app_enums.dart';
import '../models/user_model.dart';
import '../remote/user_api.dart';

final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(ref.read(dioProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    ref.read(hiveServiceProvider),
    ref.read(userApiProvider),
  );
});

class UserRepository {
  UserRepository(this._hive, this._api);

  final HiveService _hive;
  final UserApi _api;

  /// Fetch list of users. Combines server users with locally created users.
  Future<List<UserModel>> getUsers({String? role, String? unitId}) async {
    try {
      // 1. Try to fetch from the Server API
      final apiUsers = await _api.getUsers(role: role, unitId: unitId);
      
      // 2. Cache the server result in the local Hive usersBox
      final box = _hive.usersBox;
      for (final user in apiUsers) {
        await box.put(user.username, user.toJson());
      }
    } catch (_) {
      // Ignore API errors, fallback to reading all users from local Hive box
    }

    // Always fetch from the local Hive box to get the merged list of
    // cached server users AND custom local users!
    final box = _hive.usersBox;
    final List<UserModel> list = [];
    for (final key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        try {
          final user = UserModel.fromJson(Map<String, dynamic>.from(val));
          if (role != null && user.role.name != role) continue;
          if (unitId != null && user.unitId != unitId) continue;
          list.add(user);
        } catch (_) {}
      }
    }
    return list;
  }

  /// Create a user. Fallback to local user if API fails or offline.
  Future<UserModel> createUser({
    required String name,
    required String username,
    required String password,
    required String role,
    String? unitId,
    String? unitName,
  }) async {
    try {
      // 1. Send create request to the Server API
      final serverUser = await _api.createUser(
        name: name,
        username: username,
        password: password,
        role: role,
        unitId: unitId,
        unitName: unitName,
      );

      // 2. Cache profile copy in the local Hive usersBox
      final box = _hive.usersBox;
      await box.put(serverUser.username, serverUser.toJson());

      // 3. Save password locally to enable offline local authentication
      await _hive.settingsBox.put('pwd_${serverUser.username}', password);

      return serverUser;
    } catch (e) {
      // Graceful Fallback: If server throws an error (e.g. 404, offline, timeout), save locally
      final localUser = UserModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        username: username,
        role: UserRole.values.firstWhere(
          (r) => r.name == role,
          orElse: () => UserRole.operator,
        ),
        unitId: unitId ?? '',
        unitName: unitName ?? '',
        token: '',
      );

      final box = _hive.usersBox;
      await box.put(localUser.username, localUser.toJson());
      await _hive.settingsBox.put('pwd_${localUser.username}', password);

      return localUser;
    }
  }

  /// Update a user. Skips API call if the user is a local-only user.
  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? username,
    String? password,
    String? role,
    String? unitId,
    String? unitName,
  }) async {
    final isLocal = id.startsWith('local_');

    if (!isLocal) {
      try {
        // 1. Send update request to the Server API
        final serverUser = await _api.updateUser(
          id: id,
          name: name,
          username: username,
          password: password,
          role: role,
          unitId: unitId,
          unitName: unitName,
        );

        // 2. Update local Hive database
        final box = _hive.usersBox;
        String? oldUsernameKey;
        for (final key in box.keys) {
          final val = box.get(key);
          if (val is Map) {
            final u = UserModel.fromJson(Map<String, dynamic>.from(val));
            if (u.id == id) {
              oldUsernameKey = key.toString();
              break;
            }
          }
        }

        if (oldUsernameKey != null && oldUsernameKey != serverUser.username) {
          await box.delete(oldUsernameKey);
          final oldPwd = _hive.settingsBox.get('pwd_$oldUsernameKey');
          if (oldPwd != null) {
            await _hive.settingsBox.delete('pwd_$oldUsernameKey');
            await _hive.settingsBox.put('pwd_${serverUser.username}', oldPwd);
          }
        }

        await box.put(serverUser.username, serverUser.toJson());

        if (password != null && password.isNotEmpty) {
          await _hive.settingsBox.put('pwd_${serverUser.username}', password);
        }

        return serverUser;
      } catch (_) {
        // Fallback to local update if server throws error
      }
    }

    // Local Update Fallback (runs directly for local users or if server API fails)
    final box = _hive.usersBox;
    String? targetUsername;
    UserModel? existingUser;
    for (final key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final u = UserModel.fromJson(Map<String, dynamic>.from(val));
        if (u.id == id) {
          targetUsername = key.toString();
          existingUser = u;
          break;
        }
      }
    }

    if (existingUser != null && targetUsername != null) {
      final nextUsername = username ?? existingUser.username;
      final updatedUser = existingUser.copyWith(
        name: name ?? existingUser.name,
        username: nextUsername,
        role: role != null
            ? UserRole.values.firstWhere(
                (r) => r.name == role,
                orElse: () => existingUser!.role,
              )
            : existingUser.role,
        unitId: unitId ?? existingUser.unitId,
        unitName: unitName ?? existingUser.unitName,
      );

      if (targetUsername != nextUsername) {
        await box.delete(targetUsername);
        final oldPwd = _hive.settingsBox.get('pwd_$targetUsername');
        if (oldPwd != null) {
          await _hive.settingsBox.delete('pwd_$targetUsername');
          await _hive.settingsBox.put('pwd_$nextUsername', oldPwd);
        }
      }

      await box.put(nextUsername, updatedUser.toJson());

      if (password != null && password.isNotEmpty) {
        await _hive.settingsBox.put('pwd_$nextUsername', password);
      }

      return updatedUser;
    }

    throw Exception('Pengguna tidak ditemukan di database lokal.');
  }

  /// Delete a user. Skips API call if the user is a local-only user.
  Future<void> deleteUser(String id) async {
    final isLocal = id.startsWith('local_');

    if (!isLocal) {
      try {
        // 1. Delete on the Server API
        await _api.deleteUser(id);
      } catch (_) {
        // Keep going to delete locally anyway
      }
    }

    // 2. Delete on local Hive database
    final box = _hive.usersBox;
    String? foundKey;
    for (final key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final u = UserModel.fromJson(Map<String, dynamic>.from(val));
        if (u.id == id) {
          foundKey = key.toString();
          break;
        }
      }
    }

    if (foundKey != null) {
      await box.delete(foundKey);
      await _hive.settingsBox.delete('pwd_$foundKey');
    }
  }

  /// Reset a user's password. Skips API call if the user is a local-only user.
  Future<void> resetPassword(String id, String newPassword) async {
    final isLocal = id.startsWith('local_');

    if (!isLocal) {
      try {
        // 1. Reset password on the Server API
        await _api.resetPassword(id, newPassword);
      } catch (_) {
        // Keep going to reset locally anyway
      }
    }

    // 2. Reset password on local Hive database
    final box = _hive.usersBox;
    String? username;
    for (final key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        final u = UserModel.fromJson(Map<String, dynamic>.from(val));
        if (u.id == id) {
          username = u.username;
          break;
        }
      }
    }

    if (username != null) {
      await _hive.settingsBox.put('pwd_$username', newPassword);
    }
  }
}
