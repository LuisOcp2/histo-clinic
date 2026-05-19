import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/paciente_model.dart';
import '../../data/services/paciente_service.dart';
import 'auth_provider.dart';

final pacienteServiceProvider = Provider((ref) {
  return PacienteService(authService: ref.watch(authServiceProvider));
});

final pacienteSearchProvider = StateProvider<String>((ref) => '');

final pacientesProvider = FutureProvider<List<PacienteModel>>((ref) {
  final query = ref.watch(pacienteSearchProvider);
  return ref.watch(pacienteServiceProvider).listarPacientes(query: query);
});

final pacienteDetailProvider = FutureProvider.family<PacienteModel?, String>((ref, id) {
  return ref.watch(pacienteServiceProvider).obtenerPaciente(id);
});
