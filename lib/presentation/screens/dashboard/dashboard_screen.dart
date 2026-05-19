import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/cita_provider.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/agenda/cita_item.dart';
import '../../widgets/common/loading_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pacientes = ref.watch(pacientesProvider);
    final citasHoy = ref.watch(citasDeHoyProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(pacientesProvider);
        ref.invalidate(citasDeHoyProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _DashboardHero(),
          const SizedBox(height: 16),
          pacientes.when(
            loading: () =>
                const SizedBox(height: 220, child: LoadingList(itemCount: 2)),
            error: (e, _) => Text('$e'),
            data: (p) => citasHoy.when(
              loading: () =>
                  const SizedBox(height: 220, child: LoadingList(itemCount: 2)),
              error: (e, _) => Text('$e'),
              data: (c) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _KpiCard(
                      label: 'Pacientes activos',
                      value: '${p.length}',
                      icon: Icons.groups_2_outlined,
                      color: AppColors.teal),
                  _KpiCard(
                      label: 'Citas hoy',
                      value: '${c.length}',
                      icon: Icons.today_outlined,
                      color: AppColors.aprendizajeColor),
                  const _KpiCard(
                      label: 'Evoluciones mes',
                      value: '-',
                      icon: Icons.assignment_outlined,
                      color: AppColors.success),
                  const _KpiCard(
                      label: 'Plan',
                      value: 'Trial',
                      icon: Icons.workspace_premium_outlined,
                      color: AppColors.gold),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
              title: 'Citas de hoy', icon: Icons.today_outlined),
          const SizedBox(height: 10),
          citasHoy.when(
            loading: () => const LoadingList(itemCount: 2),
            error: (e, _) => Text('$e'),
            data: (items) => items.isEmpty
                ? Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available_outlined,
                          color: AppColors.teal),
                      title: const Text('No tienes citas programadas hoy'),
                      subtitle: const Text(
                          'Tu agenda esta despejada para seguimiento o documentacion.'),
                      trailing: TextButton(
                          onPressed: () => context.go('/agenda/nueva'),
                          child: const Text('Agendar')),
                    ),
                  )
                : Column(
                    children: items
                        .map((cita) => CitaItem(
                              cita: cita,
                              onEstadoChanged: (estado) async {
                                await ref
                                    .read(citaServiceProvider)
                                    .cambiarEstado(id: cita.id, estado: estado);
                                ref.invalidate(citasDeHoyProvider);
                              },
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
              title: 'Ultimos pacientes', icon: Icons.groups_2_outlined),
          const SizedBox(height: 10),
          pacientes.when(
            loading: () => const LoadingList(itemCount: 2),
            error: (e, _) => Text('$e'),
            data: (items) => Column(
              children: items
                  .take(5)
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.tealSoft,
                            child: Icon(Icons.person_outline,
                                color: AppColors.teal),
                          ),
                          title: Text(p.nombreCompleto),
                          subtitle: Text(p.codigo),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/pacientes/${p.id}'),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: .12),
              offset: const Offset(0, 12),
              blurRadius: 28,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inicio clinico',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Resumen rapido de pacientes, agenda y actividad del consultorio.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: .82)),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: .22)),
              ),
              child: const Icon(Icons.medical_services_outlined,
                  color: Colors.white),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 22),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 240,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(height: 16),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
}
