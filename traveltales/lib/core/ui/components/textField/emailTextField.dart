import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool enabled;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
    );
  }
}
