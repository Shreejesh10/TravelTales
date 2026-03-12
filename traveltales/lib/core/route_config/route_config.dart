import 'package:flutter/material.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/features/bookedEventsDetail/bookedEventScreen.dart';
import 'package:traveltales/features/dashboard/dashboardScreen.dart';
import 'package:traveltales/features/destinationDetailScreen/destinationDetailScreen.dart';
import 'package:traveltales/features/homeScreen/homeScreen.dart';
import 'package:traveltales/features/auth/login/loginScreen.dart';
import 'package:traveltales/features/onboardingScreen/onboardingScreen.dart';
import 'package:traveltales/features/searchScreen/searchScreen.dart';
import 'package:traveltales/features/settings/settingsScreen.dart';
import 'package:traveltales/features/viewAllScreen/viewAllScreen.dart';

import '../../features/auth/signup/signupScreen.dart';

class RouteConfig {
  RouteConfig._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? screenName = settings.name;
    final dynamic args = settings.arguments;

    switch (screenName) {
      case AuthRouteName.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        case AuthRouteName.signupScreen:
        return MaterialPageRoute(builder: (_) => const
        SignUpScreen());

      case RouteName.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteName.dashBoardScreen:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case RouteName.viewAllScreen:
        return MaterialPageRoute(builder: (_) => ViewAllScreen(title: args as String,));
      case RouteName.preferenceScreen:
        return MaterialPageRoute(builder: (_) => PreferenceScreen());
      case RouteName.settingScreen:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case RouteName.destinationDetailScreen:
        return MaterialPageRoute(builder: (_) => DestinationDetailScreen(), settings: settings);
      case RouteName.searchScreen:
        return MaterialPageRoute(builder: (_) => SearchScreen());
      case RouteName.bookedEventScreen:
        return MaterialPageRoute(builder: (_) => BookedEventsScreen());

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
