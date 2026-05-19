import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AreaFormAfasia extends StatelessWidget {
  const AreaFormAfasia({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FormBuilderDropdown(name: 'tipo_afasia', decoration: InputDecoration(labelText: 'Tipo de afasia'), items: [
            DropdownMenuItem(value: 'Broca', child: Text('Broca')),
            DropdownMenuItem(value: 'Wernicke', child: Text('Wernicke')),
            DropdownMenuItem(value: 'Global', child: Text('Global')),
            DropdownMenuItem(value: 'Anomica', child: Text('Anomica')),
          ]),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'comprension', decoration: InputDecoration(labelText: 'Comprension')),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'expresion', decoration: InputDecoration(labelText: 'Expresion')),
          SizedBox(height: 12),
          FormBuilderSwitch(name: 'usa_caa', title: Text('Usa CAA')),
        ],
      );
}
