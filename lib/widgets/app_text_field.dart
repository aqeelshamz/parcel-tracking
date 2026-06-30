import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Labeled, rounded input with an optional trailing widget (e.g. scan button).
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Widget? trailing;
  final TextInputType keyboardType;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.trailing,
    this.keyboardType = TextInputType.text,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.c.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          cursorColor: AppColors.primary,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: context.c.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.c.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            filled: true,
            fillColor: context.c.surfaceMuted,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            suffixIcon: trailing,
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            enabledBorder: _border(context.c.border),
            focusedBorder: _border(AppColors.primary, width: 1.6),
            border: _border(context.c.border),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
