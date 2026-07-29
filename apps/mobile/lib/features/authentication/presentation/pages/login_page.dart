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
  final _passwordController = TextEditingController();
  LoginRole _selectedRole = LoginRole.mandal;
  bool _canSubmit = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _revalidate() {
    final l10n = context.l10n;
    final isValid = AuthValidators.allValid([
      AuthValidators.phone(l10n)(_mobileController.text),
      AuthValidators.required(l10n)(_passwordController.text),
    ]);
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
                            AuthPasswordField(
                              label: l10n.password,
                              hint: l10n.passwordHint,
                              controller: _passwordController,
                              onChanged: (_) => _revalidate(),
                              validator: AuthValidators.required(l10n),
                            ),
                            const SizedBox(height: 24),
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
      final user = await ref.read(authRepositoryProvider).login(
            phoneNumber: _mobileController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          );
      if (!mounted) return;
      ref.read(sessionControllerProvider.notifier).setAuthenticated(user, _selectedRole);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
