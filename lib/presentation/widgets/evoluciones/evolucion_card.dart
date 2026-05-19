import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/evolucion_model.dart';

class EvolucionCard extends StatelessWidget {
  const EvolucionCard({required this.evolucion, super.key});

  final EvolucionModel evolucion;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Sesion ${evolucion.numSesion}', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(evolucion.fechaAtencion), style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Text(evolucion.hallazgos),
              const SizedBox(height: 8),
              Text('Plan: ${evolucion.plan}', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}
