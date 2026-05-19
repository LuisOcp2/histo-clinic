import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/cita_model.dart';

class CitaItem extends StatelessWidget {
  const CitaItem(
      {required this.cita, required this.onEstadoChanged, super.key});

  final CitaModel cita;
  final ValueChanged<String> onEstadoChanged;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_available_outlined,
                color: AppColors.teal),
          ),
          title: Text(cita.pacienteNombre ?? 'Paciente'),
          subtitle: Text(
              '${DateFormat('HH:mm').format(cita.fechaHora)} - ${cita.tipoCita} - ${cita.modalidad}'),
          trailing: DropdownButton<String>(
            value: cita.estado,
            underline: const SizedBox.shrink(),
            items: const [
              'Programada',
              'Confirmada',
              'Realizada',
              'Cancelada',
              'No_asistio'
            ]
                .map((estado) =>
                    DropdownMenuItem(value: estado, child: Text(estado)))
                .toList(),
            onChanged: (value) {
              if (value != null) onEstadoChanged(value);
            },
          ),
        ),
      );
}
