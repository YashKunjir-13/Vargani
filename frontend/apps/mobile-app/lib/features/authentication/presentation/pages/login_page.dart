import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/network/api_exception.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../widgets/auth_buttons.dart';
import '../widgets/auth_design_tokens.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_error_presenter.dart';
import '../widgets/auth_text_fields.dart';
import '../widgets/auth_validators.dart';
import '../widgets/logo_section.dart';
import '../widgets/mpin_input_widget.dart';
import '../widgets/otp_verification_widget.dart';
import '../widgets/registration_widgets.dart';
import '../../data/models/auth_models.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.onBackToRegistration});

  final VoidCallback? onBackToRegistration;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _mpinController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginRole _selectedRole = LoginRole.mandal;
  bool _usePasswordLogin = false;
  bool _canSubmit = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _mpinController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _revalidate() {
    final l10n = context.l10n;
    final phoneValid = AuthValidators.phone(l10n)(_mobileController.text) == null;
    final credValid = _usePasswordLogin
        ? AuthValidators.required(l10n)(_passwordController.text) == null
        : RegExp(r'^\d{6}$').hasMatch(_mpinController.text.trim());

    final isValid = phoneValid && credValid;
    if (isValid != _canSubmit) {
      setState(() => _canSubmit = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.authColors.background,
      appBar: AuthAppBar(title: l10n.login, onBack: widget.onBackToRegistration),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AuthSpacing.page),
            child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (AuthSpacing.page * 2),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LogoSection(
                              compact: true,
                              title: l10n.login,
                              subtitle: l10n.loginDescription,
                              icon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 32),
                            _buildRoleToggle(context),
                            const SizedBox(height: 24),
                            AuthPhoneNumberField(
                              controller: _mobileController,
                              hint: l10n.phoneHint,
                              onChanged: (_) => _revalidate(),
                              validator: AuthValidators.phone(l10n),
                            ),
                            const SizedBox(height: 20),
                            if (_usePasswordLogin) ...[
                              AuthPasswordField(
                                label: l10n.password,
                                hint: l10n.passwordHint,
                                controller: _passwordController,
                                onChanged: (_) => _revalidate(),
                                validator: AuthValidators.required(l10n),
                              ),
                            ] else ...[
                              TextField(
                                controller: _mpinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 6,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.authColors.text),
                                decoration: InputDecoration(
                                  labelText: l10n.enterMpin,
                                  hintText: '••••••',
                                  counterText: '',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onChanged: (_) => _revalidate(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotMpinSheet,
                                  child: Text(
                                    l10n.forgotMpin,
                                    style: TextStyle(color: context.authColors.brandOrange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (_errorMessage != null)
                              AuthErrorBanner(message: _errorMessage!, onRetry: _handleLogin),
                            AuthPrimaryButton(
                              label: l10n.login,
                              icon: Icons.login,
                              onPressed: (_canSubmit && !_isSubmitting) ? _handleLogin : null,
                            ),
                            if (_isSubmitting) ...[
                              const SizedBox(height: 16),
                              const CircularProgressIndicator(),
                            ],
                            if (_usePasswordLogin) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _usePasswordLogin = false;
                                    _errorMessage = null;
                                    _revalidate();
                                  });
                                },
                                child: Text(
                                  l10n.loginWithMpin,
                                  style: TextStyle(color: context.authColors.brandOrange, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                            const SizedBox(height: 26),
                            AuthTextButton(
                              label: l10n.backToRegistration,
                              icon: Icons.arrow_back,
                              onPressed: widget.onBackToRegistration ??
                                  () => Navigator.maybePop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle(BuildContext context) {
    final colors = context.authColors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Login As', // TODO: localized
          style: TextStyle(
            color: colors.secondaryText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = LoginRole.mandal),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedRole == LoginRole.mandal ? colors.brandOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.trustRegistration.replaceAll(' Registration', ''), // Hack to get 'Mandal / Trust' or similar
                      style: TextStyle(
                        color: _selectedRole == LoginRole.mandal ? Colors.white : colors.text,
                        fontWeight: _selectedRole == LoginRole.mandal ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = LoginRole.donor),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedRole == LoginRole.donor ? colors.brandOrange : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.donorRegistration.replaceAll(' Registration', ''), // Hack to get 'Donor'
                      style: TextStyle(
                        color: _selectedRole == LoginRole.donor ? Colors.white : colors.text,
                        fontWeight: _selectedRole == LoginRole.donor ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final phone = _mobileController.text.trim();
      final AuthUser user;
      if (_usePasswordLogin) {
        user = await ref.read(authRepositoryProvider).login(
              phoneNumber: phone,
              password: _passwordController.text,
              role: _selectedRole,
            );
      } else {
        user = await ref.read(authRepositoryProvider).loginMpin(
              phoneNumber: phone,
              mpin: _mpinController.text.trim(),
              role: _selectedRole,
            );
      }
      if (!mounted) return;
      ref.read(sessionControllerProvider.notifier).setAuthenticated(user, _selectedRole);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showForgotMpinSheet() {
    final phone = _mobileController.text.trim();
    final l10n = context.l10n;
    if (phone.isEmpty || AuthValidators.phone(l10n)(phone) != null) {
      setState(() => _errorMessage = l10n.errorInvalidPhoneNumber);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ForgotMpinSheet(
        phoneNumber: phone,
        role: _selectedRole,
      ),
    );
  }
}

class _ForgotMpinSheet extends ConsumerStatefulWidget {
  const _ForgotMpinSheet({required this.phoneNumber, required this.role});

  final String phoneNumber;
  final LoginRole role;

  @override
  ConsumerState<_ForgotMpinSheet> createState() => _ForgotMpinSheetState();
}

class _ForgotMpinSheetState extends ConsumerState<_ForgotMpinSheet> {
  int _step = 1; // 1: Request OTP, 2: OTP + New MPIN
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _debugOtp;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _requestOtp();
  }

  Future<void> _requestOtp() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).forgotMpin(phoneNumber: widget.phoneNumber);
      if (!mounted) return;
      setState(() {
        _debugOtp = result.debugOtp;
        _step = 2;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleVerifyMpinReset(String newMpin) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).verifyMpinReset(
            phoneNumber: widget.phoneNumber,
            otp: _otpCode,
            newMpin: newMpin,
            role: widget.role,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ref.read(sessionControllerProvider.notifier).setAuthenticated(user, widget.role);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.authColors;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.resetMpin,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.text),
            ),
            const SizedBox(height: 16),
            if (_step == 1) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_otpCode.isEmpty) ...[
              OtpVerificationWidget(
                phoneNumber: widget.phoneNumber,
                debugOtp: _debugOtp,
                onVerify: (otp) async {
                  setState(() => _otpCode = otp);
                },
                onResend: _requestOtp,
                isSubmitting: _isSubmitting,
                errorMessage: _errorMessage,
              ),
            ] else ...[
              MpinInputWidget(
                title: l10n.resetMpin,
                description: l10n.createMpinDescription,
                submitLabel: l10n.saveNewMpin,
                onSubmit: _handleVerifyMpinReset,
                requireConfirm: true,
                isSubmitting: _isSubmitting,
                errorMessage: _errorMessage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
