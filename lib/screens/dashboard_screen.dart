import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/app_loading.dart';
import '../features/admin/admin_shell_page.dart';
import '../features/auth/auth_controller.dart';
import '../features/dashboard/operator_shell_page.dart';
import '../features/supervisor/supervisor_shell_page.dart';
import '../providers/auth_provider.dart';
import '../services/local_storage_service.dart';
import '../data/models/user_model.dart' as data_model;
import '../data/models/app_enums.dart' as data_enums;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _syncAuthController();
  }

  Future<void> _syncAuthController() async {
    final oldUser = ref.read(authProvider).value;
    if (oldUser == null) {
      if (mounted) {
        setState(() => _initialized = true);
      }
      return;
    }

    final controllerUser = ref.read(authControllerProvider).user;
    if (controllerUser != null) {
      if (mounted) {
        setState(() => _initialized = true);
      }
      return;
    }

    // Sync token and user object
    final storage = await LocalStorageService.getInstance();
    final token = storage.getToken();

    final mappedRole = oldUser.role == 'superadmin'
        ? data_enums.UserRole.superadmin
        : oldUser.role == 'admin'
            ? data_enums.UserRole.admin
            : oldUser.role == 'supervisor'
                ? data_enums.UserRole.supervisor
                : data_enums.UserRole.operator;

    final newUser = data_model.UserModel(
      id: oldUser.id,
      name: oldUser.name,
      username: oldUser.username,
      role: mappedRole,
      unitId: oldUser.role == 'operator' ? 'U01' : '',
      unitName: oldUser.role == 'operator' ? 'PLTD KRAYAN' : '',
      token: token ?? '',
    );

    await ref.read(authControllerProvider.notifier).updateUser(newUser);

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: AppLoading(),
        ),
      );
    }

    final oldUser = ref.watch(authProvider).value;
    if (oldUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Tidak ada sesi login aktif'),
        ),
      );
    }

    if (oldUser.role == 'operator') {
      return const OperatorShellPage();
    } else if (oldUser.role == 'supervisor') {
      return const SupervisorShellPage();
    } else {
      return const AdminShellPage();
    }
  }
}
