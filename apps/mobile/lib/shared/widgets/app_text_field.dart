import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Shared form text field matching Pauti Pustak design system.
/// Visibly marks optional fields with a themed badge.
class AppTextField extends StatelessWidget {
  final String label;
  final bool isOptional;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final dynamic suffixIcon;
  final int maxLines;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.isOptional = false,
    String? hintText,
    String? hint,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
  }) : hintText = hintText ?? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? suffixWidget;
    if (suffixIcon is Widget) {
      suffixWidget = suffixIcon as Widget;
    } else if (suffixIcon is IconData) {
      suffixWidget = Icon(suffixIcon as IconData, size: 20);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.optionalTagBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.optionalTagText.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(
                    color: AppColors.optionalTagText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          obscureText: obscureText,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label',
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            suffixIcon: suffixWidget,
          ),
        ),
      ],
    );
  }
}

