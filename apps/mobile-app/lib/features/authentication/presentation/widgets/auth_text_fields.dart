import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

import 'auth_design_tokens.dart';
import 'auth_validators.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.optional = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool optional;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FieldValidator? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: label, optional: optional),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: keyboardType == TextInputType.emailAddress
              ? const [AutofillHints.email]
              : null,
          style: TextStyle(
            color: context.authColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: _decoration(context, hint),
        ),
      ],
    );
  }
}

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FieldValidator? validator;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: widget.label),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: _obscureText,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          style: TextStyle(color: colors.text, fontSize: 18),
          decoration: _decoration(context, widget.hint).copyWith(
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureText = !_obscureText),
              icon: Icon(_obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              color: colors.secondaryText,
              tooltip: _obscureText
                  ? context.l10n.showPassword
                  : context.l10n.hidePassword,
            ),
          ),
        ),
      ],
    );
  }
}

typedef AuthPhoneField = AuthPhoneNumberField;

class AuthPhoneNumberField extends StatelessWidget {
  const AuthPhoneNumberField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final FieldValidator? validator;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          width: 78,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            border: Border.all(color: colors.surfaceMutedBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+91',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
            autofillHints: const [AutofillHints.telephoneNumber],
            style: TextStyle(
              color: colors.text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
            decoration: _decoration(context, hint),
          ),
        ),
      ],
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label, this.optional = false});

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: colors.text,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: label),
          if (optional)
            TextSpan(
              text: ' (${context.l10n.optional})',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration _decoration(BuildContext context, String hint) {
  final colors = context.authColors;
  final outline = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: colors.border),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.secondaryText, fontSize: 18),
    filled: true,
    fillColor: colors.inputSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: outline,
    enabledBorder: outline,
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: colors.brandOrange, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.red, width: 1.4),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  );
}
