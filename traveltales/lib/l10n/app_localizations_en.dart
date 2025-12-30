// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';

  @override
  String get noAccount => 'Don\'t have an Account?';

  @override
  String get signup => 'Sign Up';

  @override
  String get login => 'Log in';
}
