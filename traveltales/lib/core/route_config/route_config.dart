import 'package:flutter/material.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/features/homeScreen/homeScreen.dart';
import 'package:traveltales/features/auth/login/loginScreen.dart';

import '../../features/auth/signup/signupScreen.dart';

class RouteConfig {
  RouteConfig._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? screenName = settings.name;
    // final dynamic args = settings.arguments;

    switch (screenName) {
      case AuthRouteName.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        case AuthRouteName.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case RouteName.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());


      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('No route defined'))),
    );
  }
}
