import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:traveltales/core/ui/localization/sharedRes.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const EmailTextField({
    super.key,
    required this.controller,
    this.labelText = 'Email',
    this.hintText = 'Enter your email',
    this.enabled = true,
    this.onChanged,
  });

  String? _validateEmail(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return SharedRes.strings(context).emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return SharedRes.strings(context).enterValidEmail;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: isWeb ? 14 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => _validateEmail(context, value),
          onChanged: onChanged,
          style: TextStyle(
            fontSize: isWeb ? 16 : 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 16 : 16,
              vertical: isWeb ? 18 : 16,
            ),
            hintStyle: TextStyle(
              fontSize: isWeb ? 16 : 16,
            ),
          ),
        ),
      ],
    );
  }
}