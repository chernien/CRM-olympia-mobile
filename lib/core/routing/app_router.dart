import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../views/auth/login_view.dart';
// import '../../views/splash/splash_view.dart'; // Removed redundant splash 
import '../../views/onboarding/onboarding_view.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/tasks/task_form_view.dart';
import '../../views/tasks/task_list_view.dart';
import '../../views/demandes/demande_list_view.dart';
import '../../views/demandes/demande_form_view.dart';
import '../../views/demandes/demande_type_selection_view.dart';
import '../../views/demandes/demande_detail_view.dart';
import '../../views/profile/profile_view.dart';
import '../../views/notifications/notifications_view.dart';
import '../../views/shared/widgets/main_shell.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(String initialLocation) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      // Splash route removed
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: RouteNames.tasks,
            name: RouteNames.tasks,
            builder: (context, state) => const TaskListView(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.taskForm,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TaskFormView(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.demandes,
            name: RouteNames.demandes,
            builder: (context, state) => const DemandeListView(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.demandeTypeSelection,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const DemandeTypeSelectionView(),
                routes: [
                  GoRoute(
                    path: ':type',
                    name: RouteNames.demandeForm,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final type = int.tryParse(
                              state.pathParameters['type'] ?? '1') ??
                          1;
                      return DemandeFormView(type: type);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.demandeDetail,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => DemandeDetailView(
                  demandeId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: RouteNames.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsView(),
      ),
    ],
  );
}
