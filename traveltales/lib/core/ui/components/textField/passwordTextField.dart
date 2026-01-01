import 'package:flutter/material.dart';
import 'package:traveltales/core/ui/localization/sharedRes.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? compareWithController;
  final String labelText;
  final String hintText;
  final bool enabled;
  final bool isConfirmPassword;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.compareWithController,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.enabled = true,
    this.isConfirmPassword = false,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  String? _validator(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return SharedRes.strings(context).passwordRequired;
    }

    // Main password rules
    if (!widget.isConfirmPassword && value.length < 6) {
      return SharedRes
          .strings(context)
          .passwordMustBeAtLeast6Characters;
    }

    // Confirm password rule
    if (widget.isConfirmPassword) {
      final originalPassword = widget.compareWithController?.text ?? '';
      if (value != originalPassword) {
        return SharedRes
            .strings(context)
            .passwordAndConfirmPasswordMustMatch;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscureText,
          validator: (value) => _validator(context, value),
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
