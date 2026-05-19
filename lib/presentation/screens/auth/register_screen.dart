import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    final v = _formKey.currentState!.value;
    try {
      await ref.read(authServiceProvider).register(
            nombre: v['nombre'] as String,
            consultorio: v['consultorio'] as String,
            tarjetaProfesional: v['tarjeta_profesional'] as String,
            email: v['email'] as String,
            password: v['password'] as String,
          );
      if (mounted) context.go(AppRoutes.dashboard);
    } on AppException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(publicRegistrationSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _RegisterForm(
            formKey: _formKey, loading: _loading, onSubmit: _submit),
        data: (value) {
          if (!value.allowPublicRegistration) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_person_outlined,
                              size: 44, color: AppColors.teal),
                          const SizedBox(height: 12),
                          Text('Registros cerrados',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(
                            value.registrationMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            label: 'Iniciar sesion',
                            icon: Icons.login_outlined,
                            onPressed: () => context.go(AppRoutes.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return _RegisterForm(
              formKey: _formKey, loading: _loading, onSubmit: _submit);
        },
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormBuilderState> formKey;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FormBuilder(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Datos del consultorio',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Configura tu acceso profesional.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                          name: 'nombre',
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined),
                              labelText: 'Nombre profesional'),
                          validator: requiredField),
                      const SizedBox(height: 14),
                      FormBuilderTextField(
                          name: 'consultorio',
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.apartment_outlined),
                              labelText: 'Consultorio'),
                          validator: requiredField),
                      const SizedBox(height: 14),
                      FormBuilderTextField(
                          name: 'tarjeta_profesional',
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.verified_user_outlined),
                              labelText: 'Tarjeta profesional'),
                          validator: requiredField),
                      const SizedBox(height: 14),
                      FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline),
                              labelText: 'Email'),
                          validator: emailField),
                      const SizedBox(height: 14),
                      FormBuilderTextField(
                          name: 'password',
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              labelText: 'Contrasena'),
                          obscureText: true,
                          validator: (value) => minLengthField(value, 8)),
                      const SizedBox(height: 22),
                      AppButton(
                          label: 'Registrar',
                          icon: Icons.person_add_alt,
                          isLoading: loading,
                          onPressed: onSubmit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
