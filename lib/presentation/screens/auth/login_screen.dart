import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    final values = _formKey.currentState!.value;
    try {
      await ref.read(authServiceProvider).login(
            email: values['email'] as String,
            password: values['password'] as String,
          );
      if (mounted) context.go(AppRoutes.dashboard);
    } on AppException catch (e) {
      if (mounted) _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandMark(),
                    const SizedBox(height: 18),
                    Text(
                      'Bienvenido',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa a tu consultorio clinico.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline),
                                labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: emailField,
                          ),
                          const SizedBox(height: 14),
                          FormBuilderTextField(
                            name: 'password',
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                labelText: 'Contrasena'),
                            obscureText: true,
                            validator: requiredField,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                        label: 'Entrar',
                        icon: Icons.login,
                        isLoading: _loading,
                        onPressed: _submit),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Crear cuenta')),
                    TextButton(
                        onPressed: () => context.go(AppRoutes.forgotPassword),
                        child: const Text('Recuperar contrasena')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.hearing_outlined,
              color: AppColors.teal, size: 34),
        ),
      );
}
