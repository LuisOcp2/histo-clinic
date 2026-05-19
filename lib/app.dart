import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/screens/admin/admin_screen.dart';
import 'presentation/screens/agenda/agenda_screen.dart';
import 'presentation/screens/agenda/cita_form_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/evoluciones/evolucion_form_screen.dart';
import 'presentation/screens/evoluciones/evoluciones_screen.dart';
import 'presentation/screens/pacientes/paciente_detail_screen.dart';
import 'presentation/screens/pacientes/paciente_form_screen.dart';
import 'presentation/screens/pacientes/pacientes_list_screen.dart';
import 'presentation/screens/reportes/reporte_screen.dart';
import 'presentation/screens/settings/perfil_screen.dart';
import 'presentation/screens/settings/suscripcion_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class FonoClinicApp extends ConsumerWidget {
  const FonoClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final router = _buildRouter(isAuthenticated);
    return MaterialApp.router(
      title: 'FonoClinic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

GoRouter _buildRouter(bool isAuthenticated) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final location = state.uri.path;
      final inAuth = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword;
      if (!isAuthenticated && !inAuth) return AppRoutes.login;
      if (isAuthenticated && inAuth) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DashboardScreen())),
          GoRoute(
            path: AppRoutes.pacientes,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PacientesListScreen()),
            routes: [
              GoRoute(
                  path: 'nuevo',
                  builder: (context, state) => const PacienteFormScreen()),
              GoRoute(
                path: ':id',
                builder: (context, state) => PacienteDetailScreen(
                    pacienteId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'evolucion',
                    builder: (context, state) => EvolucionFormScreen(
                        pacienteId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
              path: AppRoutes.evoluciones,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: EvolucionesScreen())),
          GoRoute(
            path: AppRoutes.agenda,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AgendaScreen()),
            routes: [
              GoRoute(
                  path: 'nueva',
                  builder: (context, state) => const CitaFormScreen()),
            ],
          ),
          GoRoute(
              path: AppRoutes.reportes,
              builder: (context, state) => const ReporteScreen()),
          GoRoute(
              path: AppRoutes.admin,
              builder: (context, state) => const AdminScreen()),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PerfilScreen()),
            routes: [
              GoRoute(
                  path: 'suscripcion',
                  builder: (context, state) => const SuscripcionScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _NavTab(AppRoutes.dashboard, 'Inicio', Icons.home_outlined),
    _NavTab(AppRoutes.pacientes, 'Pacientes', Icons.groups_2_outlined),
    _NavTab(AppRoutes.evoluciones, 'Evoluciones', Icons.assignment_outlined),
    _NavTab(AppRoutes.agenda, 'Agenda', Icons.calendar_month_outlined),
    _NavTab(AppRoutes.settings, 'Perfil', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex =
        _tabs.indexWhere((tab) => currentLocation.startsWith(tab.route));
    final isAdmin = ref.watch(isPlatformAdminProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.tealSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hearing_outlined,
                  color: AppColors.teal, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('FonoClinic'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reportes',
            onPressed: () => context.go(AppRoutes.reportes),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          if (isAdmin)
            IconButton(
              tooltip: 'Admin',
              onPressed: () => context.go(AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].route),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.icon, color: AppColors.teal),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}
