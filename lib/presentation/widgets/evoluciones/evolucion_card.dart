import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/evolucion_model.dart';
import '../../providers/evolucion_provider.dart';

class EvolucionCard extends ConsumerWidget {
  const EvolucionCard({required this.evolucion, super.key});

  final EvolucionModel evolucion;

  Future<void> _openAnexoDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String tipo,
  }) async {
    final controller = TextEditingController();
    final title = tipo == 'enmienda' ? 'Enmienda' : 'Nota aclaratoria';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: title,
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );
    final contenido = controller.text.trim();
    controller.dispose();
    if (saved != true || contenido.isEmpty) return;
    try {
      await ref.read(evolucionServiceProvider).crearAnexo(
            evolucionId: evolucion.id,
            tipo: tipo,
            contenido: contenido,
          );
      ref.invalidate(evolucionesPacienteProvider(evolucion.pacienteId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title guardada.')),
        );
      }
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Sesion ${evolucion.numSesion}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(evolucion.fechaAtencion),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Chip(
                avatar: Icon(Icons.lock_outline, size: 16),
                label: Text('Nota cerrada'),
              ),
              const SizedBox(height: 10),
              _ClinicalLine(label: 'Objetivo', value: evolucion.motivoConsulta),
              _ClinicalLine(label: 'Hallazgos', value: evolucion.hallazgos),
              _ClinicalLine(
                  label: 'Intervencion', value: evolucion.intervencion),
              _ClinicalLine(
                  label: 'Respuesta', value: evolucion.respuestaPaciente),
              _ClinicalLine(label: 'Plan casero', value: evolucion.plan),
              if (evolucion.anexos.isNotEmpty) ...[
                const Divider(height: 24),
                for (final anexo in evolucion.anexos) _AnexoLine(anexo: anexo),
              ],
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openAnexoDialog(
                      context: context,
                      ref: ref,
                      tipo: 'nota_aclaratoria',
                    ),
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Nota aclaratoria'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openAnexoDialog(
                      context: context,
                      ref: ref,
                      tipo: 'enmienda',
                    ),
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Enmienda'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _ClinicalLine extends StatelessWidget {
  const _ClinicalLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AnexoLine extends StatelessWidget {
  const _AnexoLine({required this.anexo});

  final EvolucionAnexoModel anexo;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${anexo.titulo} - ${DateFormat('dd/MM/yyyy HH:mm').format(anexo.createdAt)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(anexo.contenido),
          ],
        ),
      );
}
