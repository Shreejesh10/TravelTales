import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email'**
  String get enterEmail;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your Password'**
  String get enterPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Confirm Password'**
  String get enterConfirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordAndConfirmPasswordMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Password and Confirm Password must match'**
  String get passwordAndConfirmPasswordMustMatch;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search Destination'**
  String get searchDestination;

  /// No description provided for @mountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get mountain;

  /// No description provided for @camping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get camping;

  /// No description provided for @trekking.
  ///
  /// In en, this message translates to:
  /// **'Trekking'**
  String get trekking;

  /// No description provided for @hiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get hiking;

  /// No description provided for @bestPlaceToVisit.
  ///
  /// In en, this message translates to:
  /// **'Best Places to Visit Now'**
  String get bestPlaceToVisit;

  /// No description provided for @adventureAwaitsLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Adventure Awaits Let\'s Go'**
  String get adventureAwaitsLetsGo;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore!'**
  String get explore;

  /// No description provided for @selectTheCategories.
  ///
  /// In en, this message translates to:
  /// **'Select the categories you\nwant to explore'**
  String get selectTheCategories;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account?'**
  String get noAccount;

  /// No description provided for @alreadyGotAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already got an account?'**
  String get alreadyGotAnAccount;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @recentBookedEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Booked Events'**
  String get recentBookedEvents;

  /// No description provided for @accountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get accountSetting;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @totalFriends.
  ///
  /// In en, this message translates to:
  /// **'Total\nFriends'**
  String get totalFriends;

  /// No description provided for @eventsBooked.
  ///
  /// In en, this message translates to:
  /// **'Events\nBooked'**
  String get eventsBooked;

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Request Pending'**
  String get requestPending;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// No description provided for @changePasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your password?'**
  String get changePasswordMessage;

  /// No description provided for @aboutThePlace.
  ///
  /// In en, this message translates to:
  /// **'About This Place'**
  String get aboutThePlace;

  /// No description provided for @bestSeason.
  ///
  /// In en, this message translates to:
  /// **'Best Season'**
  String get bestSeason;

  /// No description provided for @attraction.
  ///
  /// In en, this message translates to:
  /// **'Attraction: '**
  String get attraction;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation: '**
  String get transportation;

  /// No description provided for @accommodation.
  ///
  /// In en, this message translates to:
  /// **'Accommodation: '**
  String get accommodation;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights: '**
  String get highlights;

  /// No description provided for @elevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get elevation;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety Tips: '**
  String get safetyTips;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @jungle.
  ///
  /// In en, this message translates to:
  /// **'Jungle'**
  String get jungle;

  /// No description provided for @lakeside.
  ///
  /// In en, this message translates to:
  /// **'Lakeside'**
  String get lakeside;

  /// No description provided for @waterfall.
  ///
  /// In en, this message translates to:
  /// **'Waterfall'**
  String get waterfall;

  /// No description provided for @religious.
  ///
  /// In en, this message translates to:
  /// **'Religious'**
  String get religious;

  /// No description provided for @wildlife.
  ///
  /// In en, this message translates to:
  /// **'Wildlife'**
  String get wildlife;

  /// No description provided for @rafting.
  ///
  /// In en, this message translates to:
  /// **'Rafting'**
  String get rafting;

  /// No description provided for @paragliding.
  ///
  /// In en, this message translates to:
  /// **'Paragliding'**
  String get paragliding;

  /// No description provided for @photographySpot.
  ///
  /// In en, this message translates to:
  /// **'Photography Spot'**
  String get photographySpot;

  /// No description provided for @changePreference.
  ///
  /// In en, this message translates to:
  /// **'Change Preference'**
  String get changePreference;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ne': return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
