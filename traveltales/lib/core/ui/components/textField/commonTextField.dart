import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

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
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
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
    final bool isWideScreen = kIsWeb || MediaQuery.of(context).size.width >= 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: isWideScreen ? 14 : 14,
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
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: isWideScreen ? 16 : 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 16 : 16,
              vertical: maxLines > 1
                  ? (isWideScreen ? 16 : 16)
                  : (isWideScreen ? 18 : 16),
            ),
            hintStyle: TextStyle(
              fontSize: isWideScreen ? 16 : 16,
            ),
            suffixIconConstraints: BoxConstraints(
              minHeight: isWideScreen ? 48 : 48,
              minWidth: isWideScreen ? 48 : 48,
            ),
          ),
        ),
      ],
    );
  }
}
