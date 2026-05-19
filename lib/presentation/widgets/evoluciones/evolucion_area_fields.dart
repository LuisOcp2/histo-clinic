import 'package:flutter/widgets.dart';

import '../pacientes/area_form_afasia.dart';
import '../pacientes/area_form_aos.dart';
import '../pacientes/area_form_aprendizaje.dart';
import '../pacientes/area_form_disfagia.dart';
import '../pacientes/area_form_lenguaje.dart';

class EvolucionAreaFields extends StatelessWidget {
  const EvolucionAreaFields({required this.area, super.key});

  final String area;

  @override
  Widget build(BuildContext context) => switch (area) {
        'DISFAGIA' => const AreaFormDisfagia(),
        'AFASIA' => const AreaFormAfasia(),
        'LENGUAJE' => const AreaFormLenguaje(),
        'APRENDIZAJE' => const AreaFormAprendizaje(),
        _ => const AreaFormAos(),
      };
}
