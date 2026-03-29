import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/features/auth/login/authProvider.dart';
import 'package:traveltales/features/auth/login/loginScreen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    if (auth.role == "company") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          RouteName.companyDashboardScreen,
        );
      });
      return const SizedBox.shrink();
    }

    if (auth.role == "admin") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          RouteName.adminDashboardScreen,
        );
      });
      return const SizedBox.shrink();
    }

    if (auth.hasCompletedPreference) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          RouteName.dashBoardScreen,
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          RouteName.preferenceScreen,
        );
      });
    }

    return const SizedBox.shrink();
  }
}