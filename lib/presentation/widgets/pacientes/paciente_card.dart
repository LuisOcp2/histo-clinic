import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/paciente_model.dart';

class PacienteCard extends StatelessWidget {
  const PacienteCard({required this.paciente, required this.onTap, super.key});

  final PacienteModel paciente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (paciente.areaAtencion) {
      'DISFAGIA' => AppColors.disfagiaColor,
      'AFASIA' => AppColors.afasiaColor,
      'LENGUAJE' => AppColors.lenguajeColor,
      'APRENDIZAJE' => AppColors.aprendizajeColor,
      _ => AppColors.aosColor,
    };

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .18),
                child: Icon(Icons.person_outline, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paciente.nombreCompleto,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${paciente.codigo} - ${paciente.tipoDoc} ${paciente.numDoc}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: .5)),
                ),
                child: Text(paciente.areaAtencion,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
