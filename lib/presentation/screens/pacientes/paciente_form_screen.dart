import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/catalogo_cie10.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/paciente_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/pacientes/area_form_afasia.dart';
import '../../widgets/pacientes/area_form_aos.dart';
import '../../widgets/pacientes/area_form_aprendizaje.dart';
import '../../widgets/pacientes/area_form_disfagia.dart';
import '../../widgets/pacientes/area_form_lenguaje.dart';

class PacienteFormScreen extends ConsumerStatefulWidget {
  const PacienteFormScreen({super.key});

  @override
  ConsumerState<PacienteFormScreen> createState() => _PacienteFormScreenState();
}

class _PacienteFormScreenState extends ConsumerState<PacienteFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _area = 'AOS';
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    final v = Map<String, dynamic>.from(_formKey.currentState!.value);
    final datosPaciente = {
      'nombres': v.remove('nombres'),
      'apellidos': v.remove('apellidos'),
      'tipo_doc': v.remove('tipo_doc'),
      'num_doc': v.remove('num_doc'),
      'fecha_nacimiento': (v.remove('fecha_nacimiento') as DateTime).toIso8601String().split('T').first,
      'sexo': v.remove('sexo'),
      'telefono': v.remove('telefono'),
      'email': v.remove('email'),
      'direccion': v.remove('direccion'),
      'eps': v.remove('eps'),
      'acudiente_nombre': v.remove('acudiente_nombre'),
      'acudiente_tel': v.remove('acudiente_tel'),
      'area_atencion': v.remove('area_atencion'),
      'diagnostico_cie10': v.remove('diagnostico_cie10'),
      'consentimiento_firmado': v.remove('consentimiento_firmado') ?? false,
    };
    try {
      await ref.read(pacienteServiceProvider).crearPaciente(
            datosPaciente: datosPaciente,
            datosClinicosArea: v,
          );
      ref.invalidate(pacientesProvider);
      if (mounted) context.go('/pacientes');
    } on AppException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Nuevo paciente')),
        body: FormBuilder(
          key: _formKey,
          initialValue: {'tipo_doc': 'CC', 'sexo': 'F', 'area_atencion': _area},
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Identificacion'),
              FormBuilderTextField(name: 'nombres', decoration: const InputDecoration(labelText: 'Nombres'), validator: requiredField),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'apellidos', decoration: const InputDecoration(labelText: 'Apellidos'), validator: requiredField),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: FormBuilderDropdown(name: 'tipo_doc', decoration: const InputDecoration(labelText: 'Tipo'), items: const ['CC', 'TI', 'CE', 'PA', 'RC', 'NIT'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList())),
                const SizedBox(width: 12),
                Expanded(child: FormBuilderTextField(name: 'num_doc', decoration: const InputDecoration(labelText: 'Numero'), validator: requiredField)),
              ]),
              const SizedBox(height: 12),
              FormBuilderDateTimePicker(name: 'fecha_nacimiento', inputType: InputType.date, decoration: const InputDecoration(labelText: 'Fecha de nacimiento'), validator: requiredField),
              const SizedBox(height: 12),
              FormBuilderDropdown(name: 'sexo', decoration: const InputDecoration(labelText: 'Sexo'), items: const ['F', 'M', 'Otro'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList()),
              const SizedBox(height: 16),
              _section('Contacto'),
              FormBuilderTextField(name: 'telefono', decoration: const InputDecoration(labelText: 'Telefono')),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'email', decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'direccion', decoration: const InputDecoration(labelText: 'Direccion')),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'eps', decoration: const InputDecoration(labelText: 'EPS')),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'acudiente_nombre', decoration: const InputDecoration(labelText: 'Acudiente')),
              const SizedBox(height: 12),
              FormBuilderTextField(name: 'acudiente_tel', decoration: const InputDecoration(labelText: 'Telefono acudiente')),
              const SizedBox(height: 16),
              _section('Area clinica'),
              FormBuilderDropdown(
                name: 'area_atencion',
                decoration: const InputDecoration(labelText: 'Area de atencion'),
                items: const ['AOS', 'DISFAGIA', 'AFASIA', 'LENGUAJE', 'APRENDIZAJE'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (value) => setState(() => _area = value ?? 'AOS'),
              ),
              const SizedBox(height: 12),
              FormBuilderDropdown(
                name: 'diagnostico_cie10',
                decoration: const InputDecoration(labelText: 'Diagnostico CIE-10'),
                validator: requiredField,
                items: catalogoCie10.map((c) => DropdownMenuItem(value: c.codigo, child: Text('${c.codigo} - ${c.descripcion}'))).toList(),
              ),
              FormBuilderSwitch(name: 'consentimiento_firmado', title: const Text('Consentimiento firmado')),
              const SizedBox(height: 12),
              _areaFields(),
              const SizedBox(height: 24),
              AppButton(label: 'Guardar paciente', icon: Icons.save_outlined, isLoading: _loading, onPressed: _submit),
            ],
          ),
        ),
      );

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _areaFields() => switch (_area) {
        'DISFAGIA' => const AreaFormDisfagia(),
        'AFASIA' => const AreaFormAfasia(),
        'LENGUAJE' => const AreaFormLenguaje(),
        'APRENDIZAJE' => const AreaFormAprendizaje(),
        _ => const AreaFormAos(),
      };
}
