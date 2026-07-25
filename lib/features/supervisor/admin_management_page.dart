import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loading.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/app_enums.dart';
import '../../data/models/machine_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/machine_repository.dart';
import '../../data/repositories/unit_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';

final managementUnitsProvider = FutureProvider<List<UnitModel>>((ref) {
  return ref.read(unitRepositoryProvider).getUnits();
});

final managementMachinesProvider = FutureProvider<List<MachineModel>>((ref) {
  return ref.read(machineRepositoryProvider).getAllMachines();
});

final managementUsersProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.read(userRepositoryProvider).getUsers();
});

class AdminManagementPage extends ConsumerStatefulWidget {
  const AdminManagementPage({super.key});

  @override
  ConsumerState<AdminManagementPage> createState() =>
      _AdminManagementPageState();
}

class _AdminManagementPageState extends ConsumerState<AdminManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Data'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSoft,
          tabs: const [
            Tab(text: 'Pengguna'),
            Tab(text: 'Unit'),
            Tab(text: 'Mesin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UsersTab(),
          _UnitsTab(),
          _MachinesTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────── USERS TAB ───────────────────────────

class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(managementUsersProvider);
    final currentUser = ref.watch(authControllerProvider).user;

    return usersAsync.when(
      data: (users) {
        final grouped = {
          for (final role in UserRole.values)
            role: users.where((u) => u.role == role).toList(),
        };

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header card with counts
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Manajemen Pengguna',
                    subtitle:
                        'Tambah, edit, dan hapus akun operator, supervisor, admin, dan superadmin.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: UserRole.values
                        .map(
                          (role) => _CountPill(
                            label: role.label,
                            value:
                                (grouped[role]?.length ?? 0).toString(),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: '+ Tambah Pengguna Baru',
                    onPressed: () => _addUser(context, currentUser),
                    fullWidth: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Group by role
            ...UserRole.values.expand((role) {
              final list = grouped[role] ?? [];
              if (list.isEmpty) return <Widget>[];
              return [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    role.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _roleColor(role),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...list.map(
                  (user) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _UserCard(
                      user: user,
                      currentUser: currentUser,
                      onEdit: () => _editUser(context, user, currentUser),
                      onDelete: currentUser?.isSuperadmin == true
                          ? () => _deleteUser(context, user)
                          : null,
                      onResetPassword: () =>
                          _resetPassword(context, user),
                    ),
                  ),
                ),
              ];
            }),
          ],
        );
      },
      loading: () => const AppLoading(),
      error: (error, _) => AppErrorState(
        message: ApiException.fromObject(error).message,
        onRetry: () => ref.invalidate(managementUsersProvider),
      ),
    );
  }

  Color _roleColor(UserRole role) => switch (role) {
    UserRole.operator => AppColors.success,
    UserRole.supervisor => AppColors.primary,
    UserRole.admin => AppColors.highlight,
    UserRole.superadmin => AppColors.danger,
  };

  Future<void> _addUser(BuildContext context, UserModel? currentUser) async {
    final result = await _showUserDialog(
      context: context,
      currentUser: currentUser,
    );
    if (result == null || !mounted) return;
    try {
      await ref.read(userRepositoryProvider).createUser(
        name: result['name']!,
        username: result['username']!,
        password: result['password']!,
        role: result['role']!,
        unitId: result['unitId'],
        unitName: result['unitName'],
      );
      ref.invalidate(managementUsersProvider);
      ref.invalidate(demoStatusProvider);
      if (!mounted) return;
      _snack('Pengguna baru berhasil dibuat.');
    } catch (e) {
      if (!mounted) return;
      _snack(ApiException.fromObject(e).message, isError: true);
    }
  }

  Future<void> _editUser(
    BuildContext context,
    UserModel user,
    UserModel? currentUser,
  ) async {
    final result = await _showUserDialog(
      context: context,
      user: user,
      currentUser: currentUser,
    );
    if (result == null || !mounted) return;
    try {
      await ref.read(userRepositoryProvider).updateUser(
        id: user.id,
        name: result['name'],
        username: result['username'],
        password: result['password']?.isEmpty == true
            ? null
            : result['password'],
        role: result['role'],
        unitId: result['unitId'],
        unitName: result['unitName'],
      );
      ref.invalidate(managementUsersProvider);
      ref.invalidate(demoStatusProvider);
      if (!mounted) return;
      _snack('Data pengguna berhasil diperbarui.');
    } catch (e) {
      if (!mounted) return;
      _snack(ApiException.fromObject(e).message, isError: true);
    }
  }

  Future<void> _deleteUser(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text(
          'Hapus akun "${user.name}" (${user.username})?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(userRepositoryProvider).deleteUser(user.id);
      ref.invalidate(managementUsersProvider);
      ref.invalidate(demoStatusProvider);
      if (!mounted) return;
      _snack('Pengguna berhasil dihapus.');
    } catch (e) {
      if (!mounted) return;
      _snack(ApiException.fromObject(e).message, isError: true);
    }
  }

  Future<void> _resetPassword(BuildContext context, UserModel user) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password – ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan password baru untuk akun "${user.username}".',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: passwordController,
              label: 'Password Baru *',
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final newPassword = passwordController.text.trim();
    passwordController.dispose();
    if (newPassword.length < 6) {
      _snack('Password minimal 6 karakter', isError: true);
      return;
    }
    try {
      await ref.read(userRepositoryProvider).resetPassword(user.id, newPassword);
      if (!mounted) return;
      _snack('Password berhasil direset.');
    } catch (e) {
      if (!mounted) return;
      _snack(ApiException.fromObject(e).message, isError: true);
    }
  }

  Future<Map<String, String?>?> _showUserDialog({
    required BuildContext context,
    UserModel? user,
    UserModel? currentUser,
  }) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role.name ?? UserRole.operator.name;
    String? selectedUnitId = user?.unitId.isEmpty == true ? null : user?.unitId;
    String? selectedUnitName = user?.unitName.isEmpty == true ? null : user?.unitName;

    final units = ref.read(managementUnitsProvider).value ?? [];

    return showDialog<Map<String, String?>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final availableRoles = currentUser?.isSuperadmin == true
              ? UserRole.values
              : UserRole.values
                  .where(
                    (r) =>
                        r == UserRole.operator ||
                        r == UserRole.supervisor,
                  )
                  .toList();

          return AlertDialog(
            title: Text(user == null ? 'Tambah Pengguna Baru' : 'Edit Pengguna'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: nameController,
                      label: 'Nama Lengkap *',
                      hint: 'Contoh: Budi Santoso',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: usernameController,
                      label: 'Username *',
                      hint: 'Tanpa spasi, huruf kecil',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: passwordController,
                      label: user == null
                          ? 'Password *'
                          : 'Password Baru (kosongkan jika tidak diubah)',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('role-$selectedRole'),
                      // ignore: deprecated_member_use
                      value: selectedRole,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Role / Jabatan *'),
                      items: availableRoles
                          .map(
                            (r) => DropdownMenuItem<String>(
                              value: r.name,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedRole = value);
                        }
                      },
                    ),
                    if (units.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        key: ValueKey('unit-$selectedUnitId'),
                        // ignore: deprecated_member_use
                        value: selectedUnitId,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Unit (Opsional)'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('– Tidak ada unit –'),
                          ),
                          ...units.map(
                            (unit) => DropdownMenuItem<String?>(
                              value: unit.id,
                              child: Text(unit.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedUnitId = value;
                            selectedUnitName = units
                                .cast<UnitModel?>()
                                .firstWhere(
                                  (u) => u?.id == value,
                                  orElse: () => null,
                                )
                                ?.name;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Operator & Supervisor: dapat dikelola oleh Admin. '
                              'Admin & Superadmin: hanya dapat dibuat oleh Superadmin.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final username = usernameController.text.trim();
                  final password = passwordController.text.trim();

                  if (name.isEmpty || username.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Nama dan username wajib diisi.'),
                      ),
                    );
                    return;
                  }
                  if (user == null && password.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Password wajib diisi untuk pengguna baru.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(ctx, {
                    'name': name,
                    'username': username,
                    'password': password.isEmpty ? null : password,
                    'role': selectedRole,
                    'unitId': selectedUnitId,
                    'unitName': selectedUnitName,
                  });
                },
                child: Text(user == null ? 'Buat Akun' : 'Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.currentUser,
    required this.onEdit,
    required this.onResetPassword,
    this.onDelete,
  });

  final UserModel user;
  final UserModel? currentUser;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final roleColor = switch (user.role) {
      UserRole.operator => AppColors.success,
      UserRole.supervisor => AppColors.primary,
      UserRole.admin => AppColors.highlight,
      UserRole.superadmin => AppColors.danger,
    };

    final roleIcon = switch (user.role) {
      UserRole.operator => Icons.engineering_rounded,
      UserRole.supervisor => Icons.supervisor_account_rounded,
      UserRole.admin => Icons.admin_panel_settings_rounded,
      UserRole.superadmin => Icons.shield_rounded,
    };

    return GlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(roleIcon, color: roleColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'reset') onResetPassword();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Profil'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'reset',
                          child: Row(
                            children: [
                              Icon(Icons.lock_reset_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Reset Password'),
                            ],
                          ),
                        ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 18),
                                SizedBox(width: 8),
                                Text('Hapus Pengguna', style: TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                      ],
                      icon: const Icon(Icons.more_vert_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.unitName.isNotEmpty ? user.unitName : "Semua Unit",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(label: user.role.label, color: roleColor),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(roleIcon, color: roleColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username} • ${user.unitName.isNotEmpty ? user.unitName : "Semua Unit"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: user.role.label, color: roleColor),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'reset') onResetPassword();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Profil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Reset Password'),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 18),
                          SizedBox(width: 8),
                          Text('Hapus Pengguna', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                ],
                icon: const Icon(Icons.more_vert_rounded, size: 20),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────── UNITS TAB ───────────────────────────

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(managementUnitsProvider);

    return units.when(
      data: (items) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Master Unit PLTD',
                  subtitle:
                      'Daftar unit aktif yang menjadi tujuan input operator dan relasi mesin.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _CountPill(label: 'Total Unit', value: items.length.toString()),
                    _CountPill(
                      label: 'Status Aktif',
                      value: items.where((item) => item.status == 'active').length.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (unit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.electrical_services_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    unit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${unit.locationName} • Radius ${unit.radiusMeter.toStringAsFixed(0)} m',
                  ),
                  trailing: StatusBadge(
                    label: unit.status,
                    color: unit.status == 'active'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => const AppLoading(),
      error: (error, _) => AppErrorState(
        message: ApiException.fromObject(error).message,
      ),
    );
  }
}

// ─────────────────────────── MACHINES TAB ───────────────────────────

class _MachinesTab extends ConsumerStatefulWidget {
  const _MachinesTab();

  @override
  ConsumerState<_MachinesTab> createState() => _MachinesTabState();
}

class _MachinesTabState extends ConsumerState<_MachinesTab> {
  late final TextEditingController _searchController;
  String _query = '';
  String _selectedUnitId = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(managementUnitsProvider);
    final machinesAsync = ref.watch(managementMachinesProvider);

    if (unitsAsync.isLoading || machinesAsync.isLoading) {
      return const AppLoading();
    }
    if (unitsAsync.hasError) {
      return AppErrorState(
        message: ApiException.fromObject(unitsAsync.error!).message,
      );
    }
    if (machinesAsync.hasError) {
      return AppErrorState(
        message: ApiException.fromObject(machinesAsync.error!).message,
      );
    }

    final units = unitsAsync.value ?? const <UnitModel>[];
    final machines = machinesAsync.value ?? const <MachineModel>[];
    final unitNameById = {for (final unit in units) unit.id: unit.name};
    final filtered = machines.where((machine) {
      final unitName = unitNameById[machine.unitId] ?? machine.unitId;
      final searchText = [
        machine.displayLabel,
        machine.displaySubtitle,
        machine.masterInfoLine,
        unitName,
      ].join(' ').toLowerCase();
      final matchQuery = _query.trim().isEmpty ||
          searchText.contains(_query.trim().toLowerCase());
      final matchUnit =
          _selectedUnitId == 'all' || machine.unitId == _selectedUnitId;
      return matchQuery && matchUnit;
    }).toList();

    final unitOptions = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(value: 'all', child: Text('Semua Unit')),
      ...units.map(
        (unit) => DropdownMenuItem<String>(
          value: unit.id,
          child: Text(unit.name),
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Master Mesin PLTD',
                subtitle:
                    'Superadmin dapat tambah, edit, hapus, dan memindahkan mesin antar unit langsung dari panel ini.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _CountPill(label: 'Total Mesin', value: machines.length.toString()),
                  _CountPill(
                    label: 'Unit Terpakai',
                    value: machines.map((item) => item.unitId).toSet().length.toString(),
                  ),
                  _CountPill(
                    label: 'Gangguan/Rusak',
                    value: machines
                        .where(
                          (item) => parseMachineStatus(
                                item.conditionLabel.isEmpty
                                    ? item.status
                                    : item.conditionLabel,
                              ) ==
                              MachineStatus.gangguanRusak,
                        )
                        .length
                        .toString(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _searchController,
                      label: 'Cari mesin, serial, UP3, atau unit',
                      onChanged: (value) => setState(() => _query = value),
                      suffixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_selectedUnitId),
                      initialValue: _selectedUnitId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Filter Unit'),
                      items: unitOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUnitId = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: 'Tambah Mesin',
                    onPressed: units.isEmpty ? null : () => _addMachine(units),
                    fullWidth: false,
                  ),
                  AppButton(
                    label: 'Reset Filter',
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _selectedUnitId = 'all';
                      });
                      _searchController.clear();
                    },
                    type: AppButtonType.outlined,
                    fullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const AppErrorState(
            title: 'Mesin tidak ditemukan',
            message: 'Tidak ada mesin yang cocok dengan filter saat ini.',
          )
        else
          ...filtered.map(
            (machine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MachineCard(
                machine: machine,
                unitName: unitNameById[machine.unitId] ?? machine.unitId,
                onEdit: () => _editMachine(units, machine),
                onMove: () => _moveMachine(units, machine),
                onDelete: () => _deleteMachine(machine),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addMachine(List<UnitModel> units) async {
    final created = await _showMachineDialog(units: units);
    if (!mounted || created == null) return;
    await ref.read(machineRepositoryProvider).createMachine(created);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin baru berhasil ditambahkan.');
  }

  Future<void> _editMachine(List<UnitModel> units, MachineModel machine) async {
    final updated = await _showMachineDialog(units: units, machine: machine);
    if (!mounted || updated == null) return;
    await ref.read(machineRepositoryProvider).updateMachine(updated);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Master mesin berhasil diperbarui.');
  }

  Future<void> _moveMachine(List<UnitModel> units, MachineModel machine) async {
    final targetUnitId = await _showMoveDialog(units: units, machine: machine);
    if (!mounted || targetUnitId == null || targetUnitId == machine.unitId) {
      return;
    }
    await ref.read(machineRepositoryProvider).moveMachine(machine.id, targetUnitId);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin berhasil dipindahkan ke unit baru.');
  }

  Future<void> _deleteMachine(MachineModel machine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mesin'),
        content: Text(
          'Hapus ${machine.displayLabel}? Mesin ini tidak akan muncul lagi pada form input operator, tetapi riwayat logsheet lama tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(machineRepositoryProvider).deleteMachine(machine.id);
    ref.invalidate(managementMachinesProvider);
    if (!mounted) return;
    _snack('Mesin berhasil dihapus dari master data.');
  }

  Future<MachineModel?> _showMachineDialog({
    required List<UnitModel> units,
    MachineModel? machine,
  }) async {
    final nameController = TextEditingController(text: machine?.machineName ?? '');
    final brandController = TextEditingController(text: machine?.brand ?? '');
    final typeController = TextEditingController(text: machine?.machineType ?? '');
    final serialController = TextEditingController(text: machine?.serialNumber ?? '');
    final generatorController = TextEditingController(
      text: machine?.generatorCode ?? '',
    );
    final ownershipController = TextEditingController(
      text: machine?.ownershipStatus ?? '',
    );
    final performanceController = TextEditingController(
      text: machine?.performanceLabel ?? '',
    );
    final capacityController = TextEditingController(text: machine?.capacity ?? '');
    final availableController = TextEditingController(
      text: machine?.availableCapacity ?? '',
    );
    final dispatchController = TextEditingController(
      text: machine?.dispatchCapacity ?? '',
    );
    final up3Controller = TextEditingController(text: machine?.up3 ?? '');
    final conditionController = TextEditingController(
      text: machine?.conditionLabel ?? '',
    );
    var selectedUnitId = machine?.unitId ?? (units.isNotEmpty ? units.first.id : '');
    var selectedStatus = parseMachineStatus(
      machine == null
          ? MachineStatus.operasi.apiValue
          : machine.conditionLabel.isEmpty
          ? machine.status
          : machine.conditionLabel,
    );

    final result = await showDialog<MachineModel>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(machine == null ? 'Tambah Mesin PLTD' : 'Edit Mesin PLTD'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey('unit-$selectedUnitId'),
                      initialValue: selectedUnitId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unit PLTD *'),
                      items: units
                          .map(
                            (unit) => DropdownMenuItem<String>(
                              value: unit.id,
                              child: Text(unit.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedUnitId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MachineStatus>(
                      key: ValueKey('status-${selectedStatus.name}'),
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status Mesin *'),
                      items: MachineStatus.values
                          .map(
                            (status) => DropdownMenuItem<MachineStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedStatus = value;
                          if (conditionController.text.trim().isEmpty ||
                              MachineStatus.values.any(
                                (item) =>
                                    item.label ==
                                    conditionController.text.trim(),
                              )) {
                            conditionController.text = value.label;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: nameController,
                      label: 'Nama Mesin *',
                      hint: 'Contoh: Cummins #3',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: serialController,
                      label: 'Serial Number',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: brandController, label: 'Merk'),
                    const SizedBox(height: 12),
                    AppTextField(controller: typeController, label: 'Tipe Mesin'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: capacityController,
                      label: 'Kapasitas Terpasang',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: availableController,
                      label: 'Kapasitas DMN',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: dispatchController,
                      label: 'Kapasitas Pasok',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: up3Controller, label: 'UP3'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: generatorController,
                      label: 'Kode Generator',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: ownershipController,
                      label: 'Status Kepemilikan',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: performanceController,
                      label: 'Label Kinerja',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: conditionController,
                      label: 'Label Kondisi',
                      hint: 'Default mengikuti status mesin',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Anda bisa memindahkan mesin ke unit lain kapan saja dengan mengganti pilihan Unit PLTD saat edit.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () {
                  if (selectedUnitId.isEmpty ||
                      (nameController.text.trim().isEmpty &&
                          serialController.text.trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unit dan identitas mesin wajib diisi.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    MachineModel(
                      id: machine?.id ?? '',
                      unitId: selectedUnitId,
                      up3: up3Controller.text.trim(),
                      machineName: nameController.text.trim(),
                      brand: brandController.text.trim(),
                      machineType: typeController.text.trim(),
                      serialNumber: serialController.text.trim(),
                      generatorCode: generatorController.text.trim(),
                      ownershipStatus: ownershipController.text.trim(),
                      performanceLabel: performanceController.text.trim(),
                      capacity: capacityController.text.trim(),
                      availableCapacity: availableController.text.trim(),
                      dispatchCapacity: dispatchController.text.trim(),
                      status: selectedStatus.apiValue,
                      conditionLabel: conditionController.text.trim().isEmpty
                          ? selectedStatus.label
                          : conditionController.text.trim(),
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );

    nameController.dispose();
    brandController.dispose();
    typeController.dispose();
    serialController.dispose();
    generatorController.dispose();
    ownershipController.dispose();
    performanceController.dispose();
    capacityController.dispose();
    availableController.dispose();
    dispatchController.dispose();
    up3Controller.dispose();
    conditionController.dispose();
    return result;
  }

  Future<String?> _showMoveDialog({
    required List<UnitModel> units,
    required MachineModel machine,
  }) async {
    var selectedUnitId = machine.unitId;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pindah Mesin ke Unit Lain'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.displayLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih unit tujuan baru untuk memperbarui relasi mesin ini.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('move-$selectedUnitId'),
                  initialValue: selectedUnitId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Unit Tujuan'),
                  items: units
                      .map(
                        (unit) => DropdownMenuItem<String>(
                          value: unit.id,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedUnitId = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selectedUnitId),
              child: const Text('Pindahkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.machine,
    required this.unitName,
    required this.onEdit,
    required this.onMove,
    required this.onDelete,
  });

  final MachineModel machine;
  final String unitName;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = parseMachineStatus(
      machine.conditionLabel.isEmpty ? machine.status : machine.conditionLabel,
    );
    final statusColor = switch (status) {
      MachineStatus.operasi => AppColors.success,
      MachineStatus.standby => AppColors.warning,
      MachineStatus.gangguanRusak => AppColors.danger,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: statusColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                machine.displayLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                unitName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'move') onMove();
                            if (value == 'delete') onDelete();
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Mesin')),
                            const PopupMenuItem(
                              value: 'move',
                              child: Text('Pindah Unit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Hapus Mesin',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            machine.displaySubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: status.label,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machine.displayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$unitName • ${machine.displaySubtitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: status.label,
                    color: statusColor,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'move') onMove();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Mesin')),
                      const PopupMenuItem(
                        value: 'move',
                        child: Text('Pindah Unit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Hapus Mesin',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                  ),
                ],
              );
            },
          ),
          if (machine.masterInfoLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              machine.masterInfoLine,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSoft),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────── SHARED WIDGETS ───────────────────────────

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            TextSpan(
              text: ' $label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
