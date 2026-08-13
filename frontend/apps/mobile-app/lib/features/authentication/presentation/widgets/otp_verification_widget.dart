import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

import 'auth_buttons.dart';
import 'auth_design_tokens.dart';
import 'auth_error_banner.dart';
import 'registration_widgets.dart';

class OtpVerificationWidget extends StatefulWidget {
  const OtpVerificationWidget({
    super.key,
    required this.phoneNumber,
    required this.onVerify,
    required this.onResend,
    this.debugOtp,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String phoneNumber;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;
  final String? debugOtp;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    if (widget.debugOtp != null && widget.debugOtp!.length == 6) {
      _applyOtp(widget.debugOtp!);
    }
  }

  @override
  void didUpdateWidget(covariant OtpVerificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.debugOtp != oldWidget.debugOtp &&
        widget.debugOtp != null &&
        widget.debugOtp!.length == 6) {
      _applyOtp(widget.debugOtp!);
    }
  }

  void _applyOtp(String code) {
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          widget.onVerify(_otpCode);
        }
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.authColors;

    return FormSectionCard(
      title: l10n.verifyOtp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${l10n.enterOtp} sent to ${widget.phoneNumber}',
            style: TextStyle(fontSize: 14, color: colors.secondaryText),
          ),
          if (widget.debugOtp != null && widget.debugOtp!.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _applyOtp(widget.debugOtp!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.surfaceMutedBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.developer_mode,
                        size: 20, color: colors.brandOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dev Mode OTP: ${widget.debugOtp} (Tap to autofill)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.brandOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 44,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colors.brandOrange, width: 2),
                    ),
                  ),
                  onChanged: (val) => _onDigitChanged(index, val),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          if (widget.errorMessage != null) ...[
            AuthErrorBanner(
                message: widget.errorMessage!,
                onRetry: () => widget.onVerify(_otpCode)),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _canResend
                    ? ''
                    : '${l10n.resendCodeIn} $_secondsRemaining ${l10n.seconds}',
                style: TextStyle(fontSize: 13, color: colors.secondaryText),
              ),
              TextButton(
                onPressed: _canResend && !widget.isSubmitting
                    ? () async {
                        await widget.onResend();
                        _startCountdown();
                      }
                    : null,
                child: Text(
                  l10n.resendOtp,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _canResend
                        ? colors.brandOrange
                        : colors.secondaryText.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AuthPrimaryButton(
            label: l10n.verifyOtp,
            icon: Icons.check_circle_outline,
            onPressed: (_otpCode.length == 6 && !widget.isSubmitting)
                ? () => widget.onVerify(_otpCode)
                : null,
          ),
        ],
      ),
    );
  }
}
