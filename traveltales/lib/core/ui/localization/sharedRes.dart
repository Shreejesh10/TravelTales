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

}
