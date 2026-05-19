import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AreaFormDisfagia extends StatelessWidget {
  const AreaFormDisfagia({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FormBuilderDropdown(
              name: 'fois',
              decoration: InputDecoration(labelText: 'Escala FOIS'),
              items: [
                DropdownMenuItem(value: '1', child: Text('1 - Nada via oral')),
                DropdownMenuItem(
                    value: '4',
                    child: Text('4 - Via oral unica con restricciones')),
                DropdownMenuItem(
                    value: '7', child: Text('7 - Via oral completa')),
              ]),
          SizedBox(height: 12),
          FormBuilderTextField(
              name: 'fase_afectada',
              decoration: InputDecoration(labelText: 'Fase afectada')),
          SizedBox(height: 12),
          FormBuilderSwitch(
              name: 'riesgo_aspiracion', title: Text('Riesgo de aspiracion')),
        ],
      );
}
