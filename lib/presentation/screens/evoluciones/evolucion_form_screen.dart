import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/evolucion_provider.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/evoluciones/evolucion_area_fields.dart';

class EvolucionFormScreen extends ConsumerStatefulWidget {
  const EvolucionFormScreen({required this.pacienteId, super.key});

  final String pacienteId;

  @override
  ConsumerState<EvolucionFormScreen> createState() =>
      _EvolucionFormScreenState();
}

class _EvolucionFormScreenState extends ConsumerState<EvolucionFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    final v = Map<String, dynamic>.from(_formKey.currentState!.value);
    final datos = {
      'fecha_atencion':
          (v.remove('fecha_atencion') as DateTime).toUtc().toIso8601String(),
      'modalidad': v.remove('modalidad'),
      'motivo_consulta': v.remove('motivo_consulta'),
      'hallazgos': v.remove('hallazgos'),
      'intervencion': v.remove('intervencion'),
      'respuesta_paciente': v.remove('respuesta_paciente'),
      'plan': v.remove('plan'),
      'proxima_cita': (v.remove('proxima_cita') as DateTime?)
          ?.toIso8601String()
          .split('T')
          .first,
    };
    final notaAclaratoria = v.remove('nota_aclaratoria') as String?;
    final enmienda = v.remove('enmienda') as String?;
    try {
      await ref.read(evolucionServiceProvider).crearEvolucion(
            pacienteId: widget.pacienteId,
            datos: datos,
            datosArea: v,
            notaAclaratoria: notaAclaratoria,
            enmienda: enmienda,
          );
      ref.invalidate(evolucionesPacienteProvider(widget.pacienteId));
      if (mounted) context.go('/pacientes/${widget.pacienteId}');
    } on AppException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacienteDetailProvider(widget.pacienteId));
    return paciente.when(
      loading: () => const Scaffold(body: Center(child: Text('Cargando...'))),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (p) => Scaffold(
        appBar: AppBar(title: const Text('Nueva evolucion')),
        body: FormBuilder(
          key: _formKey,
          initialValue: {
            'fecha_atencion': DateTime.now(),
            'modalidad': 'Presencial'
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (p != null)
                Text(p.nombreCompleto,
                    style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                  name: 'fecha_atencion',
                  decoration:
                      const InputDecoration(labelText: 'Fecha de atencion'),
                  validator: requiredField),
              const SizedBox(height: 12),
              FormBuilderDropdown(
                  name: 'modalidad',
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                  items: const ['Presencial', 'Virtual', 'Domicilio']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList()),
              const SizedBox(height: 12),
              FormBuilderTextField(
                  name: 'motivo_consulta',
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                  validator: requiredField,
                  maxLines: 2),
              const SizedBox(height: 12),
              FormBuilderTextField(
                  name: 'hallazgos',
                  decoration: const InputDecoration(labelText: 'Hallazgos'),
                  validator: requiredField,
                  maxLines: 3),
              const SizedBox(height: 12),
              FormBuilderTextField(
                  name: 'intervencion',
                  decoration: const InputDecoration(labelText: 'Intervencion'),
                  validator: requiredField,
                  maxLines: 3),
              const SizedBox(height: 12),
              FormBuilderTextField(
                  name: 'respuesta_paciente',
                  decoration: const InputDecoration(
                      labelText: 'Respuesta del paciente'),
                  validator: requiredField,
                  maxLines: 2),
              const SizedBox(height: 12),
              FormBuilderTextField(
                  name: 'plan',
                  decoration: const InputDecoration(labelText: 'Plan casero'),
                  validator: requiredField,
                  maxLines: 2),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(
                  name: 'proxima_cita',
                  inputType: InputType.date,
                  decoration: const InputDecoration(
                      labelText: 'Proxima cita sugerida')),
              const SizedBox(height: 16),
              Text('Anexos opcionales',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FormBuilderTextField(
                name: 'nota_aclaratoria',
                decoration:
                    const InputDecoration(labelText: 'Nota aclaratoria'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              FormBuilderTextField(
                name: 'enmienda',
                decoration: const InputDecoration(labelText: 'Enmienda'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Campos del area',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              EvolucionAreaFields(area: p?.areaAtencion ?? 'AOS'),
              const SizedBox(height: 24),
              AppButton(
                  label: 'Guardar evolucion',
                  icon: Icons.save_outlined,
                  isLoading: _loading,
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
