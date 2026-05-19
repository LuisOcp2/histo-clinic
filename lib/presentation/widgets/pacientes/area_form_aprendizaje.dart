import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AreaFormAprendizaje extends StatelessWidget {
  const AreaFormAprendizaje({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FormBuilderTextField(name: 'lectura', decoration: InputDecoration(labelText: 'Lectura')),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'escritura', decoration: InputDecoration(labelText: 'Escritura')),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'calculo', decoration: InputDecoration(labelText: 'Calculo')),
          SizedBox(height: 12),
          FormBuilderSwitch(name: 'tdah', title: Text('Indicadores de TDAH')),
        ],
      );
}
