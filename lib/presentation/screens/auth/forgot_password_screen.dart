import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/form_validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _loading = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordReset(_formKey.currentState!.value['email'] as String);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revisa tu correo para continuar.')));
        context.go(AppRoutes.login);
      }
    } on AppException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo enviar el correo: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Recuperar contrasena')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: FormBuilder(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                children: [
                  FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: emailField),
                  const SizedBox(height: 20),
                  AppButton(
                      label: 'Enviar enlace',
                      icon: Icons.mark_email_read_outlined,
                      isLoading: _loading,
                      onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      );
}
