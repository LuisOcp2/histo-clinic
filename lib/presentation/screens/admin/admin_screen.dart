import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/app_button.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _messageController = TextEditingController();
  bool? _allowRegistration;
  bool _savingSettings = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final allow = _allowRegistration;
    if (allow == null) return;
    setState(() => _savingSettings = true);
    try {
      await ref.read(adminServiceProvider).updateRegistrationSettings(
            allowPublicRegistration: allow,
            registrationMessage: _messageController.text.trim(),
          );
      ref.invalidate(publicRegistrationSettingsProvider);
      ref.invalidate(adminSettingsProvider);
      _showMessage('Configuracion actualizada.');
    } on AppException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _savingSettings = false);
    }
  }

  Future<void> _updateTenant(TenantAdminModel tenant, String estado) async {
    try {
      await ref.read(adminServiceProvider).updateTenantStatus(
            tenantId: tenant.id,
            estado: estado,
            trialEndsAt: tenant.trialEndsAt,
          );
      ref.invalidate(adminTenantsProvider);
      _showMessage('Suscripcion actualizada.');
    } on AppException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isPlatformAdminProvider);
    final settings = ref.watch(adminSettingsProvider);
    final tenants = ref.watch(adminTenantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: isAdmin.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _AccessDenied(message: '$e'),
        data: (admin) {
          if (!admin) return const _AccessDenied();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminSettingsProvider);
              ref.invalidate(adminTenantsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsCard(
                  settings: settings,
                  allowRegistration: _allowRegistration,
                  messageController: _messageController,
                  saving: _savingSettings,
                  onAllowChanged: (value) {
                    setState(() => _allowRegistration = value);
                  },
                  onSave: _saveSettings,
                ),
                const SizedBox(height: 12),
                tenants.when(
                  loading: () => const Card(
                    child: ListTile(title: Text('Cargando suscripciones...')),
                  ),
                  error: (e, _) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: const Text('No se pudieron cargar tenants'),
                      subtitle: Text('$e'),
                    ),
                  ),
                  data: (items) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Text(
                          'Suscripciones',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      for (final tenant in items)
                        _TenantCard(
                          tenant: tenant,
                          onStatusChanged: (estado) =>
                              _updateTenant(tenant, estado),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.allowRegistration,
    required this.messageController,
    required this.saving,
    required this.onAllowChanged,
    required this.onSave,
  });

  final AsyncValue<AppRegistrationSettings> settings;
  final bool? allowRegistration;
  final TextEditingController messageController;
  final bool saving;
  final ValueChanged<bool> onAllowChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return settings.when(
      loading: () => const Card(
        child: ListTile(title: Text('Cargando configuracion...')),
      ),
      error: (e, _) => Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline),
          title: const Text('No se pudo cargar configuracion'),
          subtitle: Text('$e'),
        ),
      ),
      data: (value) {
        final currentAllow = allowRegistration ?? value.allowPublicRegistration;
        if (messageController.text.isEmpty) {
          messageController.text = value.registrationMessage;
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.person_add_disabled_outlined),
                  title: const Text('Permitir registros publicos'),
                  subtitle: Text(currentAllow
                      ? 'Cualquier profesional puede crear una cuenta.'
                      : 'El formulario de registro queda bloqueado.'),
                  value: currentAllow,
                  onChanged: onAllowChanged,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje cuando registros estan cerrados',
                    prefixIcon: Icon(Icons.message_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Guardar',
                    icon: Icons.save_outlined,
                    isLoading: saving,
                    onPressed: onSave,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.tenant,
    required this.onStatusChanged,
  });

  static const _statuses = ['trial', 'activo', 'suspendido', 'cancelado'];

  final TenantAdminModel tenant;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final trialText = tenant.trialEndsAt == null
        ? 'Sin fecha de trial'
        : 'Trial hasta ${_formatDate(tenant.trialEndsAt!)}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.tealSoft,
                  child: Icon(Icons.business_outlined, color: AppColors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.nombre,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        tenant.emailAdmin,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: tenant.estado),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(Icons.workspace_premium_outlined,
                    tenant.planNombre ?? 'Sin plan'),
                _InfoChip(Icons.groups_2_outlined,
                    '${tenant.usuariosCount} usuarios'),
                _InfoChip(Icons.folder_shared_outlined,
                    '${tenant.pacientesCount} pacientes'),
                _InfoChip(Icons.calendar_today_outlined, trialText),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue:
                  _statuses.contains(tenant.estado) ? tenant.estado : 'trial',
              decoration: const InputDecoration(
                labelText: 'Estado de suscripcion',
                prefixIcon: Icon(Icons.tune_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'trial', child: Text('Trial')),
                DropdownMenuItem(value: 'activo', child: Text('Activo')),
                DropdownMenuItem(
                    value: 'suspendido', child: Text('Suspendido')),
                DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
              ],
              onChanged: (value) {
                if (value != null && value != tenant.estado) {
                  onStatusChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'activo' => AppColors.teal,
      'trial' => AppColors.gold,
      'suspendido' => Colors.deepOrange,
      'cancelado' => Colors.red,
      _ => AppColors.textSecondary,
    };
    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(status),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
      );
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings_outlined,
                        size: 44, color: AppColors.teal),
                    const SizedBox(height: 12),
                    Text(
                      'Acceso de administrador',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message ??
                          'Tu usuario no esta marcado como administrador de plataforma.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
