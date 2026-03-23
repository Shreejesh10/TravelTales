import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class CommonDropDownMenu extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const CommonDropDownMenu({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.items,
    this.enabled = true,
    this.onChanged,
    this.validator,
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
    final bool isWideScreen =
        kIsWeb || MediaQuery.of(context).size.width >= 700;

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

        DropdownButtonFormField<String>(
          dropdownColor: AppColors.getContainerBoxColor(context),
          value: controller.text.isNotEmpty ? controller.text : null,
          isExpanded: true,
          menuMaxHeight: 250,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled
              ? (value) {
            controller.text = value!;
            if (onChanged != null) {
              onChanged!(value);
            }
          }
              : null,
          validator: _validateText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: isWideScreen ? 16 : 16,

            ),
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 16 : 16,
              vertical: isWideScreen ? 16 : 16,
            ),
          ),
        ),
      ],
    );
  }
}