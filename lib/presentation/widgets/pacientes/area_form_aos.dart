import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AreaFormAos extends StatelessWidget {
  const AreaFormAos({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FormBuilderTextField(name: 'iah', decoration: InputDecoration(labelText: 'IAH'), keyboardType: TextInputType.number),
          SizedBox(height: 12),
          FormBuilderDropdown(name: 'severidad', decoration: InputDecoration(labelText: 'Severidad'), items: [
            DropdownMenuItem(value: 'Leve', child: Text('Leve')),
            DropdownMenuItem(value: 'Moderada', child: Text('Moderada')),
            DropdownMenuItem(value: 'Severa', child: Text('Severa')),
          ]),
          SizedBox(height: 12),
          FormBuilderSwitch(name: 'usa_cpap', title: Text('Usa CPAP')),
          FormBuilderSwitch(name: 'ronquido', title: Text('Ronquido')),
          FormBuilderSwitch(name: 'bruxismo', title: Text('Bruxismo')),
        ],
      );
}
