// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get welcome => 'स्वागत छ';

  @override
  String get email => 'इमेल';

  @override
  String get enterEmail => 'आफ्नो इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get emailRequired => 'इमेल आवश्यक छ';

  @override
  String get enterValidEmail => 'वैध इमेल ठेगाना प्रविष्ट गर्नुहोस्';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterPassword => 'आफ्नो पासवर्ड प्रविष्ट गर्नुहोस्';

  @override
  String get passwordRequired => 'पासवर्ड आवश्यक छ';

  @override
  String get passwordMustBeAtLeast6Characters => 'पासवर्ड कम्तिमा ६ वर्णको हुनुपर्छ';

  @override
  String get dont_have_an_account => 'खाता छैन?';

  @override
  String get signup => 'साइन अप';

  @override
  String get login => 'लग इन गर्नुहोस्';
}
