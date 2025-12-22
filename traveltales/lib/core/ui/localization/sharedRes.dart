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
}
