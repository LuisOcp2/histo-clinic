import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/cita_provider.dart';
import '../../widgets/agenda/cita_item.dart';
import '../../widgets/common/empty_state.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedAgendaDayProvider);
    final citasMes = ref.watch(citasDelMesProvider(selectedDay));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/agenda/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Cita'),
      ),
      body: citasMes.when(
        loading: () => const Center(child: Text('Cargando agenda...')),
        error: (e, _) => EmptyState(
            icon: Icons.warning_amber,
            title: 'No se pudo cargar la agenda',
            subtitle: '$e'),
        data: (items) {
          final citasDia =
              items.where((c) => isSameDay(c.fechaHora, selectedDay)).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2035),
                    focusedDay: selectedDay,
                    selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                    eventLoader: (day) => items
                        .where((c) => isSameDay(c.fechaHora, day))
                        .toList(),
                    onDaySelected: (day, _) => ref
                        .read(selectedAgendaDayProvider.notifier)
                        .state = day,
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(
                          color: AppColors.teal, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(
                          color: AppColors.teal, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: AppColors.surfaceAlt, shape: BoxShape.circle),
                      selectedTextStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                      todayTextStyle: TextStyle(
                          color: AppColors.teal, fontWeight: FontWeight.w800),
                    ),
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (citasDia.isEmpty)
                const EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'Sin citas este dia',
                    subtitle: 'Programa una cita desde el boton inferior.')
              else
                ...citasDia.map(
                  (cita) => CitaItem(
                    cita: cita,
                    onEstadoChanged: (estado) async {
                      await ref
                          .read(citaServiceProvider)
                          .cambiarEstado(id: cita.id, estado: estado);
                      ref.invalidate(citasDelMesProvider(selectedDay));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
