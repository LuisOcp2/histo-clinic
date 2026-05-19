import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/cita_model.dart';
import '../../data/services/cita_service.dart';
import 'auth_provider.dart';

final citaServiceProvider = Provider((ref) {
  return CitaService(authService: ref.watch(authServiceProvider));
});

final selectedAgendaDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final citasDelMesProvider = FutureProvider.family<List<CitaModel>, DateTime>((ref, month) {
  final first = DateTime(month.year, month.month);
  final last = DateTime(month.year, month.month + 1, 0, 23, 59);
  return ref.watch(citaServiceProvider).listarPorRango(first, last);
});

final citasDeHoyProvider = FutureProvider<List<CitaModel>>((ref) {
  return ref.watch(citaServiceProvider).citasDeHoy();
});
