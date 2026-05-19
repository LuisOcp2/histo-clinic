import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/evolucion_model.dart';
import '../../data/services/evolucion_service.dart';
import 'auth_provider.dart';

final evolucionServiceProvider = Provider((ref) {
  return EvolucionService(authService: ref.watch(authServiceProvider));
});

final evolucionesPacienteProvider = FutureProvider.family<List<EvolucionModel>, String>((ref, pacienteId) {
  return ref.watch(evolucionServiceProvider).listarPorPaciente(pacienteId);
});
