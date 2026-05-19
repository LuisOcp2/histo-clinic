import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SuscripcionScreen extends StatelessWidget {
  const SuscripcionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Suscripcion')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _PlanCard(nombre: 'Trial', precio: '14 dias gratis', limite: '50 pacientes activos', color: AppColors.gold),
            _PlanCard(nombre: 'Basico', precio: r'$35.000 COP/mes', limite: '50 pacientes - 1 usuario', color: AppColors.teal),
            _PlanCard(nombre: 'Pro', precio: r'$69.000 COP/mes', limite: '200 pacientes - 2 usuarios', color: AppColors.aprendizajeColor),
          ],
        ),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.nombre, required this.precio, required this.limite, required this.color});

  final String nombre;
  final String precio;
  final String limite;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(Icons.workspace_premium_outlined, color: color),
          title: Text(nombre),
          subtitle: Text('$precio - $limite'),
        ),
      );
}
