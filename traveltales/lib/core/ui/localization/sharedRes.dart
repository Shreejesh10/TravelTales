import 'package:flutter/cupertino.dart';
import 'package:traveltales/l10n/app_localizations.dart';

class SharedRes {
  static Strings strings(BuildContext context) {

    final appLocalizations = AppLocalizations.of(context);
    if (appLocalizations == null) {

      throw Exception("AppLocalizations not found in the context");
    }
    return Strings(appLocalizations);
  }
}

class Strings {
  final AppLocalizations _l10n;

  Strings(this._l10n);

  String get welcome => _l10n.welcome;
  String get email => _l10n.email;
  String get enterEmail => _l10n.enterEmail;
  String get emailRequired => _l10n.emailRequired;
  String get enterValidEmail => _l10n.enterValidEmail;
  String get password => _l10n.password;
  String get enterPassword => _l10n.enterPassword;
  String get passwordRequired => _l10n.passwordRequired;
  String get passwordMustBeAtLeast6Characters => _l10n.passwordMustBeAtLeast6Characters;
  String get noAccount => _l10n.noAccount;
  String get alreadyGotAnAccount => _l10n.alreadyGotAnAccount;
  String get signup => _l10n.signup;
  String get login => _l10n.login;
  String get confirmPassword => _l10n.confirmPassword;
  String get confirmPasswordRequired => _l10n.confirmPasswordRequired;
  String get passwordAndConfirmPasswordMustMatch => _l10n.passwordAndConfirmPasswordMustMatch;
  String get enterConfirmPassword => _l10n.enterConfirmPassword;
  String get recommendedForYou => _l10n.recommendedForYou;
  String get viewAll => _l10n.viewAll;
  String get searchDestination => _l10n.searchDestination;
  String get mountain => _l10n.mountain;
  String get camping => _l10n.camping;
  String get trekking => _l10n.trekking;
  String get hiking => _l10n.hiking;
  String get bestPlaceToVisit => _l10n.bestPlaceToVisit;
  String get adventureAwaitsLetsGo => _l10n.adventureAwaitsLetsGo;
  String get explore => _l10n.explore;
  String get selectTheCategories => _l10n.selectTheCategories;
  String get logout => _l10n.logout;
  String get settings => _l10n.settings;
  String get recentBookedEvents => _l10n.recentBookedEvents;
  String get accountSetting => _l10n.accountSetting;
  String get language => _l10n.language;
  String get changePassword => _l10n.changePassword;
  String get theme => _l10n.theme;
  String get totalFriends => _l10n.totalFriends;
  String get eventsBooked => _l10n.eventsBooked;
  String get requestPending => _l10n.requestPending;
  String get save => _l10n.save;
  String get cancel => _l10n.cancel;
  String get ok => _l10n.ok;
  String get selectLanguage => _l10n.selectLanguage;
  String get selectTheme => _l10n.selectTheme;
  String get logoutMessage => _l10n.logoutMessage;
  String get changePasswordMessage => _l10n.changePasswordMessage;
  String get aboutThePlace => _l10n.aboutThePlace;
  String get bestSeason => _l10n.bestSeason;
  String get attraction => _l10n.attraction;
  String get transportation => _l10n.transportation;
  String get accommodation => _l10n.accommodation;
  String get highlights => _l10n.highlights;
  String get elevation => _l10n.elevation;
  String get duration => _l10n.duration;
  String get safetyTips => _l10n.safetyTips;
  String get all => _l10n.all;
  String get sunset => _l10n.sunset;
  String get sunrise => _l10n.sunrise;
  String get jungle => _l10n.jungle;
  String get lakeside => _l10n.lakeside;
  String get waterfall => _l10n.waterfall;
  String get religious => _l10n.religious;
  String get wildlife => _l10n.wildlife;
  String get rafting => _l10n.rafting;
  String get paragliding => _l10n.paragliding;
  String get photographySpot => _l10n.photographySpot;
  String get changePreference => _l10n.changePreference;



}
