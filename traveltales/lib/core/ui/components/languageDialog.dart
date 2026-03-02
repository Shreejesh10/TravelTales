import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';
import 'package:traveltales/traveltales.dart';

class AppLanguageDialog {
  static Future<void> show(BuildContext context) async {
    final currentCode = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      builder: (_) {
        String selected = currentCode;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              title: Text(SharedRes.strings(context).language),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: "en",
                    groupValue: selected,
                    title: const Text("English"),
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                  RadioListTile<String>(
                    value: "ne",
                    groupValue: selected,
                    title: const Text("नेपाली"),
                    onChanged: (v) => setState(() => selected = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(SharedRes.strings(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    TravelTales.setLocale(context, Locale(selected));
                    Navigator.pop(context);
                  },
                  child: Text(SharedRes.strings(context).save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}