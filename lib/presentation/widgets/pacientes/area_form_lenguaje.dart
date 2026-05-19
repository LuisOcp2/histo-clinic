import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AreaFormLenguaje extends StatelessWidget {
  const AreaFormLenguaje({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FormBuilderTextField(name: 'nivel_lenguaje', decoration: InputDecoration(labelText: 'Nivel de lenguaje')),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'fonologia', decoration: InputDecoration(labelText: 'Fonologia')),
          SizedBox(height: 12),
          FormBuilderTextField(name: 'morfosintaxis', decoration: InputDecoration(labelText: 'Morfosintaxis')),
          SizedBox(height: 12),
          FormBuilderSwitch(name: 'sospecha_tea', title: Text('Sospecha TEA')),
        ],
      );
}
