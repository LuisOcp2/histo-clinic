import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/cita_provider.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/common/app_button.dart';

class CitaFormScreen extends ConsumerStatefulWidget {
  const CitaFormScreen({super.key});

  @override
  ConsumerState<CitaFormScreen> createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends ConsumerState<CitaFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    final v = _formKey.currentState!.value;
    final date = v['fecha'] as DateTime;
    final time = v['hora'] as DateTime;
    final fechaHora = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    try {
      await ref.read(citaServiceProvider).crearCita({
        'paciente_id': v['paciente_id'],
        'fecha_hora': fechaHora,
        'duracion_min': int.tryParse('${v['duracion_min']}') ?? 45,
        'tipo_cita': v['tipo_cita'],
        'modalidad': v['modalidad'],
        'estado': 'Programada',
        'notas': v['notas'],
        'link_virtual': v['link_virtual'],
      });
      ref.invalidate(citasDelMesProvider(DateTime.now()));
      ref.invalidate(citasDeHoyProvider);
      if (mounted) context.go('/agenda');
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pacientes = ref.watch(pacientesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva cita')),
      body: pacientes.when(
        loading: () => const Center(child: Text('Cargando pacientes...')),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => FormBuilder(
          key: _formKey,
          initialValue: {
            'fecha': DateTime.now(),
            'hora': DateTime.now(),
            'duracion_min': '45',
            'tipo_cita': 'Seguimiento',
            'modalidad': 'Presencial',
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FormBuilderDropdown(
                name: 'paciente_id',
                decoration: const InputDecoration(labelText: 'Paciente'),
                validator: requiredField,
                items: items.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto))).toList(),
              ),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(name: 'fecha', inputType: InputType.date, decoration: const InputDecoration(labelText: 'Fecha'), validator: requiredField),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(name: 'hora', inputType: InputType.time, decoration: const InputDecoration(labelText: 'Hora'), validator: requiredField),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'duracion_min', decoration: const InputDecoration(labelText: 'Duracion minutos'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              FormBuilderDropdown(name: 'tipo_cita', decoration: const InputDecoration(labelText: 'Tipo'), items: const ['Valoracion', 'TMO', 'Seguimiento', 'Teleconsulta', 'Domicilio'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList()),
              const SizedBox(height: 12),
              FormBuilderDropdown(name: 'modalidad', decoration: const InputDecoration(labelText: 'Modalidad'), items: const ['Presencial', 'Virtual', 'Domicilio'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList()),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'link_virtual', decoration: const InputDecoration(labelText: 'Link virtual')),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'notas', decoration: const InputDecoration(labelText: 'Notas'), maxLines: 3),
              const SizedBox(height: 24),
              AppButton(label: 'Programar cita', icon: Icons.event_available_outlined, isLoading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
