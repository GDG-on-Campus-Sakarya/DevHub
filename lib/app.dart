import 'package:flutter/material.dart';

import 'navigation/app_routes.dart';
import 'screens/applications/applications_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/projects/create_project_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/projects_screen.dart';
import 'theme/app_theme.dart';

class DevHubApp extends StatelessWidget {
  const DevHubApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DevHub',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AuthGate(),

routes: {
  AppRoutes.projects: (_) => const ProjectsScreen(),
  AppRoutes.createProject: (_) => const CreateProjectScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.register: (_) => const RegisterScreen(),
  AppRoutes.profile: (_) => const ProfileScreen(),
  AppRoutes.applications: (_) => const ApplicationsScreen(),
},

    onGenerateRoute: (settings) {
      if (settings.name == AppRoutes.projectDetail) {
        final id = settings.arguments;
        if (id is String && id.isNotEmpty) {
          return MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: id));
        }
      }
      return null;
    },
  );
}
