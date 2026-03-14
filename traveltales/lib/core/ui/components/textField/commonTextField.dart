import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool enabled;
  final bool readOnly;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
  });

  String? _validateText(String? value) {
    if (validator != null) {
      return validator!(value);
    }

    if (value == null || value.trim().isEmpty) {
      return '$labelText is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: _validateText,
          onChanged: onChanged,
          maxLines: maxLines,
          onTap: onTap,
          decoration:  InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            suffixIcon: suffixIcon

          ),
        ),
      ],
    );
  }
}