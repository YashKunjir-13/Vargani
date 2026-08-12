import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

import 'auth_buttons.dart';
import 'auth_design_tokens.dart';
import 'auth_error_banner.dart';
import 'registration_widgets.dart';

class MpinInputWidget extends StatefulWidget {
  const MpinInputWidget({
    super.key,
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.onSubmit,
    this.requireConfirm = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String title;
  final String description;
  final String submitLabel;
  final Future<void> Function(String mpin) onSubmit;
  final bool requireConfirm;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<MpinInputWidget> createState() => _MpinInputWidgetState();
}

class _MpinInputWidgetState extends State<MpinInputWidget> {
  final _mpinController = TextEditingController();
  final _confirmMpinController = TextEditingController();
  bool _obscureMpin = true;
  bool _obscureConfirm = true;
  String? _localError;

  @override
  void dispose() {
    _mpinController.dispose();
    _confirmMpinController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final mpin = _mpinController.text.trim();
    if (mpin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(mpin)) {
      setState(() => _localError = context.l10n.errorMpinTooShort);
      return;
    }
    if (widget.requireConfirm) {
      final confirm = _confirmMpinController.text.trim();
      if (confirm != mpin) {
        setState(() => _localError = context.l10n.errorMpinMismatch);
        return;
      }
    }
    setState(() => _localError = null);
    widget.onSubmit(mpin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.authColors;

    final displayError = _localError ?? widget.errorMessage;

    return FormSectionCard(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.description,
            style: TextStyle(fontSize: 14, color: colors.secondaryText),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mpinController,
            keyboardType: TextInputType.number,
            obscureText: _obscureMpin,
            maxLength: 6,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                color: colors.text),
            decoration: InputDecoration(
              labelText: widget.title,
              hintText: '••••••',
              counterText: '',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureMpin ? Icons.visibility_off : Icons.visibility,
                    color: colors.secondaryText),
                onPressed: () => setState(() => _obscureMpin = !_obscureMpin),
              ),
            ),
            onChanged: (_) => setState(() => _localError = null),
          ),
          if (widget.requireConfirm) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _confirmMpinController,
              keyboardType: TextInputType.number,
              obscureText: _obscureConfirm,
              maxLength: 6,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: colors.text),
              decoration: InputDecoration(
                labelText: l10n.confirmMpin,
                hintText: '••••••',
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: colors.secondaryText),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              onChanged: (_) => setState(() => _localError = null),
            ),
          ],
          if (displayError != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(message: displayError, onRetry: _handleSubmit),
          ],
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: widget.submitLabel,
            icon: Icons.check,
            onPressed: widget.isSubmitting ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}
