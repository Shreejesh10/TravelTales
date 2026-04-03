import 'package:flutter/material.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:traveltales/features/addFriend/acceptFriendScreen.dart';
import 'package:traveltales/features/addFriend/addFriendScreen.dart';
import 'package:traveltales/features/addFriend/viewFriendScreen.dart';
import 'package:traveltales/features/adminScreen/adminDashboard/adminDashboard.dart';
import 'package:traveltales/features/adminScreen/createDestinationPage/adminDestinationDetailScreen.dart';
import 'package:traveltales/features/auth/login/loginScreen.dart';
import 'package:traveltales/features/bookedEventsDetail/bookedEventHomeScreen.dart';
import 'package:traveltales/features/bookmark/bookmarkScreen.dart';
import 'package:traveltales/features/companyDashboard/companyDashboardScreen.dart';
import 'package:traveltales/features/dashboard/dashboardScreen.dart';
import 'package:traveltales/features/destinationDetailScreen/destinationDetailScreen.dart';
import 'package:traveltales/features/eventsScreen/eventBookingScreen/eventBookingScreen.dart';
import 'package:traveltales/features/eventsScreen/eventCreatingScreen/eventCreatingScreen.dart';
import 'package:traveltales/features/eventsScreen/eventDetailScreen.dart';
import 'package:traveltales/features/homeScreen/homeScreen.dart';
import 'package:traveltales/features/notification/notificationScreen.dart';
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
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AuthRouteName.signupScreen:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case RouteName.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case RouteName.dashBoardScreen:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case RouteName.viewAllScreen:
        return MaterialPageRoute(
          builder: (_) => ViewAllScreen(title: args as String),
        );
      case RouteName.preferenceScreen:
        return MaterialPageRoute(builder: (_) => PreferenceScreen());
      case RouteName.settingScreen:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case RouteName.destinationDetailScreen:
        return MaterialPageRoute(
          builder: (_) => DestinationDetailScreen(),
          settings: settings,
        );
      case RouteName.searchScreen:
        return MaterialPageRoute(builder: (_) => SearchScreen());
      case RouteName.bookedEventScreen:
        return MaterialPageRoute(builder: (_) => const BookedEventHomeScreen());
      case RouteName.companyDashboardScreen:
        return MaterialPageRoute(
          builder: (_) => CompanyDashboardScreen(),
          settings: settings,
        );
      case RouteName.eventCreatingScreen:
        return MaterialPageRoute(
          builder: (_) => EventCreatingScreen(),
          settings: settings,
        );
      case RouteName.eventDetailScreen:
        final event = settings.arguments as Event;
        return MaterialPageRoute(
          builder: (_) => EventDetailScreen(event: event),
        );
      case RouteName.addFriendScreen:
        return MaterialPageRoute(builder: (_) => AddFriendScreen());
      case RouteName.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => AdminDashboardScreen());
      case RouteName.eventBookingScreen:
        final event = settings.arguments as Event;
        return MaterialPageRoute(
          builder: (_) => EventBookingScreen(event: event),
        );
      case RouteName.adminDestinationDetailScreen:
        final destination = settings.arguments as Destination;
        return MaterialPageRoute(
          builder: (_) =>
              AdminDestinationDetailScreen(destination: destination),
        );
      case RouteName.totalFriendScreen:
        return MaterialPageRoute(builder: (_) => ViewAllFriendScreen());
      case RouteName.acceptFriendScreen:
        return MaterialPageRoute(builder: (_) => AcceptFriendScreen());
      case RouteName.bookmarkScreen:
        return MaterialPageRoute(builder: (_) => BookmarkScreen());
      case RouteName.notificationScreen:
        return MaterialPageRoute(builder: (_) => NotificationScreen());

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
