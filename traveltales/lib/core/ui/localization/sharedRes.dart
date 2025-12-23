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
  String get dont_have_an_account => _l10n.dont_have_an_account;
  String get signup => _l10n.signup;
  String get login => _l10n.login;
}
