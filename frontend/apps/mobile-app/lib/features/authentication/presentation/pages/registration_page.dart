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
import '../widgets/language_selector.dart';
import '../widgets/mpin_input_widget.dart';
import '../widgets/otp_verification_widget.dart';
import '../widgets/registration_widgets.dart';
import '../../data/models/auth_models.dart';

enum _RegistrationType { trust, donor }

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key, this.onLoginRequested});

  final VoidCallback? onLoginRequested;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  _RegistrationType? _type;

  @override
  Widget build(BuildContext context) => switch (_type) {
        _RegistrationType.trust =>
          _TrustRegistrationForm(onBack: () => setState(() => _type = null)),
        _RegistrationType.donor =>
          _DonorRegistrationForm(onBack: () => setState(() => _type = null)),
        null => _RegistrationTypeSelector(
            onTrustSelected: () =>
                setState(() => _type = _RegistrationType.trust),
            onDonorSelected: () =>
                setState(() => _type = _RegistrationType.donor),
            onLoginRequested: widget.onLoginRequested,
          ),
      };
}

class _RegistrationTypeSelector extends StatefulWidget {
  const _RegistrationTypeSelector({
    required this.onTrustSelected,
    required this.onDonorSelected,
    this.onLoginRequested,
  });

  final VoidCallback onTrustSelected;
  final VoidCallback onDonorSelected;
  final VoidCallback? onLoginRequested;

  @override
  State<_RegistrationTypeSelector> createState() =>
      _RegistrationTypeSelectorState();
}

class _RegistrationTypeSelectorState extends State<_RegistrationTypeSelector> {
  _RegistrationType? _selectedType;

  void _handleSelection(_RegistrationType type) {
    setState(() => _selectedType = type);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (type == _RegistrationType.trust) {
        widget.onTrustSelected();
      } else {
        widget.onDonorSelected();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.authColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AuthSpacing.page),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: constraints.maxWidth > 500 ? 50 : 24,
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AuthThemeToggle(),
                            SizedBox(width: 12),
                            AuthLanguageSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.appName,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 44),
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.registerSelectType,
                              style: TextStyle(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 28),
                            RegistrationTypeCard(
                              title: l10n.trustRegistration,
                              description: l10n.trustRegistrationDescription,
                              icon: Icons.account_balance_outlined,
                              isSelected:
                                  _selectedType == _RegistrationType.trust,
                              onTap: () =>
                                  _handleSelection(_RegistrationType.trust),
                            ),
                            const SizedBox(height: 18),
                            RegistrationTypeCard(
                              title: l10n.donorRegistration,
                              description: l10n.donorRegistrationDescription,
                              icon: Icons.favorite_border,
                              isSelected:
                                  _selectedType == _RegistrationType.donor,
                              onTap: () =>
                                  _handleSelection(_RegistrationType.donor),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(child: Divider(color: colors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    l10n.or,
                                    style: TextStyle(
                                      color: colors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: colors.border)),
                              ],
                            ),
                            const SizedBox(height: 22),
                            AuthSecondaryButton(
                              label: l10n.alreadyRegisteredLogin,
                              icon: Icons.lock_outline,
                              onPressed: widget.onLoginRequested ?? () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustRegistrationForm extends ConsumerStatefulWidget {
  const _TrustRegistrationForm({required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<_TrustRegistrationForm> createState() =>
      _TrustRegistrationFormState();
}

enum _RegistrationStep { mobile, otp, details, mpin }

class _TrustRegistrationFormState
    extends ConsumerState<_TrustRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _mandalName = TextEditingController();
  final _registrationNumber = TextEditingController();
  final _presidentName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pinCode = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  int? _year;

  _RegistrationStep _step = _RegistrationStep.mobile;
  bool _canContinue = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _debugOtp;
  AuthUser? _registeredUser;

  @override
  void dispose() {
    _mandalName.dispose();
    _registrationNumber.dispose();
    _presidentName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pinCode.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _revalidate() {
    final l10n = context.l10n;
    if (_step == _RegistrationStep.mobile) {
      final isValid = AuthValidators.phone(l10n)(_phone.text) == null;
      if (isValid != _canContinue) setState(() => _canContinue = isValid);
      return;
    }
    final isValid = AuthValidators.allValid([
      AuthValidators.required(l10n)(_mandalName.text),
      AuthValidators.required(l10n)(_presidentName.text),
      AuthValidators.phone(l10n)(_phone.text),
      AuthValidators.required(l10n)(_city.text),
      AuthValidators.required(l10n)(_state.text),
      AuthValidators.pinCodeRequired(l10n)(_pinCode.text),
    ]);
    if (isValid != _canContinue) {
      setState(() => _canContinue = isValid);
    }
  }

  Future<void> _handleRequestOtp() async {
    final l10n = context.l10n;
    if (AuthValidators.phone(l10n)(_phone.text) != null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).requestOtp(
            phoneNumber: _phone.text.trim(),
            purpose: OtpPurpose.VERIFY_MOBILE,
          );
      if (!mounted) return;
      setState(() {
        _debugOtp = result.debugOtp;
        _step = _RegistrationStep.otp;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleVerifyOtp(String otp) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
            phoneNumber: _phone.text.trim(),
            otp: otp,
            purpose: OtpPurpose.VERIFY_MOBILE,
            role: LoginRole.mandal,
          );
      if (!mounted) return;
      setState(() {
        _step = _RegistrationStep.details;
        _revalidate();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSubmitDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_year == null) {
      setState(() => _errorMessage = 'Please select Festival Year.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final locale = context.l10n.localeName.toUpperCase();
      final user = await ref.read(authRepositoryProvider).registerTrust(
            mandalTrustName: _mandalName.text.trim(),
            registrationNumber: _registrationNumber.text.trim(),
            presidentHeadName: _presidentName.text.trim(),
            addressLine1: _address.text.trim(),
            city: _city.text.trim(),
            state: _state.text.trim(),
            postalCode: _pinCode.text.trim(),
            festivalYear: _year!,
            phoneNumber: _phone.text.trim(),
            password: _password.text.isNotEmpty ? _password.text : null,
            preferredLanguage: locale,
          );
      if (!mounted) return;
      setState(() {
        _registeredUser = user;
        _step = _RegistrationStep.mpin;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleCreateMpin(String mpin) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).createMpin(mpin: mpin);
      if (!mounted) return;
      if (_registeredUser != null) {
        ref
            .read(sessionControllerProvider.notifier)
            .setAuthenticated(_registeredUser!, LoginRole.mandal);
      }
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

    if (_step == _RegistrationStep.otp) {
      return _RegistrationFormScaffold(
        title: l10n.verifyOtp,
        onBack: () => setState(() => _step = _RegistrationStep.mobile),
        formKey: GlobalKey<FormState>(),
        intro: RegistrationIntroCard(
          title: l10n.verifyOtp,
          description: '${l10n.enterOtp} sent to ${_phone.text}',
          icon: Icons.mark_email_read_outlined,
        ),
        children: [
          OtpVerificationWidget(
            phoneNumber: _phone.text.trim(),
            debugOtp: _debugOtp,
            onVerify: _handleVerifyOtp,
            onResend: _handleRequestOtp,
            isSubmitting: _isSubmitting,
            errorMessage: _errorMessage,
          ),
        ],
      );
    }

    if (_step == _RegistrationStep.mpin) {
      return _RegistrationFormScaffold(
        title: l10n.createMpin,
        onBack: () => setState(() => _step = _RegistrationStep.details),
        formKey: GlobalKey<FormState>(),
        intro: RegistrationIntroCard(
          title: l10n.createMpin,
          description: l10n.createMpinDescription,
          icon: Icons.lock_outline,
        ),
        children: [
          MpinInputWidget(
            title: l10n.createMpin,
            description: l10n.createMpinDescription,
            submitLabel: l10n.createMpinButton,
            onSubmit: _handleCreateMpin,
            requireConfirm: true,
            isSubmitting: _isSubmitting,
            errorMessage: _errorMessage,
          ),
        ],
      );
    }

    if (_step == _RegistrationStep.mobile) {
      return _RegistrationFormScaffold(
        title: l10n.trustRegistration,
        onBack: widget.onBack,
        formKey: _formKey,
        intro: RegistrationIntroCard(
          title: l10n.trustRegistration,
          description: l10n.trustRegistrationDescription,
          icon: Icons.account_balance_outlined,
        ),
        children: [
          FormSectionCard(
            title: l10n.trustRegistration,
            child: Column(
              children: [
                AuthPhoneField(
                  hint: l10n.phoneHint,
                  controller: _phone,
                  onChanged: (_) => _revalidate(),
                  validator: AuthValidators.phone(l10n),
                ),
                const SizedBox(height: AuthSpacing.section),
                if (_errorMessage != null)
                  AuthErrorBanner(
                      message: _errorMessage!, onRetry: _handleRequestOtp),
                AuthPrimaryButton(
                  label: l10n.sendOtp,
                  icon: Icons.arrow_forward,
                  onPressed: (_canContinue && !_isSubmitting)
                      ? _handleRequestOtp
                      : null,
                ),
                if (_isSubmitting) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return _RegistrationFormScaffold(
      title: l10n.trustRegistration,
      onBack: () => setState(() => _step = _RegistrationStep.mobile),
      formKey: _formKey,
      intro: RegistrationIntroCard(
        title: l10n.trustRegistration,
        description: l10n.trustRegistrationDescription,
        icon: Icons.account_balance_outlined,
      ),
      children: [
        FormSectionCard(
          title: l10n.mandalDetails,
          child: Column(
            children: [
              AuthTextField(
                label: l10n.mandalTrustName,
                hint: l10n.mandalTrustNameHint,
                controller: _mandalName,
                onChanged: (_) => _revalidate(),
                validator: AuthValidators.required(l10n),
              ),
              const SizedBox(height: AuthSpacing.field),
              AuthTextField(
                label: l10n.registrationNumber,
                hint: l10n.registrationNumberHint,
                controller: _registrationNumber,
                optional: true,
              ),
              const SizedBox(height: AuthSpacing.field),
              AuthTextField(
                label: l10n.presidentHeadName,
                hint: l10n.presidentHeadNameHint,
                controller: _presidentName,
                onChanged: (_) => _revalidate(),
                validator: AuthValidators.required(l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthSpacing.section),
        LocationFormSection(
          addressController: _address,
          cityController: _city,
          pinCodeController: _pinCode,
          onChanged: (_) => _revalidate(),
          pinCodeOptional: false,
          extraField: AuthTextField(
            label: l10n.state,
            hint: l10n.stateHint,
            controller: _state,
            onChanged: (_) => _revalidate(),
            validator: AuthValidators.required(l10n),
          ),
        ),
        const SizedBox(height: AuthSpacing.section),
        FormSectionCard(
          title: l10n.festivalYear,
          child: YearSelectionControl(
            selectedYear: _year,
            onChanged: (value) => setState(() => _year = value),
          ),
        ),
        const SizedBox(height: AuthSpacing.section),
        if (_errorMessage != null)
          AuthErrorBanner(
              message: _errorMessage!, onRetry: _handleSubmitDetails),
        AuthPrimaryButton(
          label: l10n.continueToVerification,
          icon: Icons.arrow_forward,
          onPressed:
              (_canContinue && !_isSubmitting) ? _handleSubmitDetails : null,
        ),
        if (_isSubmitting) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _DonorRegistrationForm extends ConsumerStatefulWidget {
  const _DonorRegistrationForm({required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<_DonorRegistrationForm> createState() =>
      _DonorRegistrationFormState();
}

class _DonorRegistrationFormState
    extends ConsumerState<_DonorRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _pan = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _pinCode = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  _RegistrationStep _step = _RegistrationStep.mobile;
  bool _canContinue = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _debugOtp;
  AuthUser? _registeredUser;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _pan.dispose();
    _address.dispose();
    _city.dispose();
    _pinCode.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _revalidate() {
    final l10n = context.l10n;
    if (_step == _RegistrationStep.mobile) {
      final isValid = AuthValidators.phone(l10n)(_phone.text) == null;
      if (isValid != _canContinue) setState(() => _canContinue = isValid);
      return;
    }
    final isValid = AuthValidators.allValid([
      AuthValidators.required(l10n)(_fullName.text),
      AuthValidators.phone(l10n)(_phone.text),
      AuthValidators.required(l10n)(_city.text),
    ]);
    if (isValid != _canContinue) {
      setState(() => _canContinue = isValid);
    }
  }

  Future<void> _handleRequestOtp() async {
    final l10n = context.l10n;
    if (AuthValidators.phone(l10n)(_phone.text) != null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final result = await ref.read(authRepositoryProvider).requestOtp(
            phoneNumber: _phone.text.trim(),
            purpose: OtpPurpose.VERIFY_MOBILE,
          );
      if (!mounted) return;
      setState(() {
        _debugOtp = result.debugOtp;
        _step = _RegistrationStep.otp;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleVerifyOtp(String otp) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyOtp(
            phoneNumber: _phone.text.trim(),
            otp: otp,
            purpose: OtpPurpose.VERIFY_MOBILE,
            role: LoginRole.donor,
          );
      if (!mounted) return;
      setState(() {
        _step = _RegistrationStep.details;
        _revalidate();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleSubmitDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final locale = context.l10n.localeName.toUpperCase();
      final user = await ref.read(authRepositoryProvider).registerDonor(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            panNumber: _pan.text.trim(),
            addressLine1: _address.text.trim(),
            city: _city.text.trim(),
            postalCode: _pinCode.text.trim(),
            phoneNumber: _phone.text.trim(),
            password: _password.text.isNotEmpty ? _password.text : null,
            preferredLanguage: locale,
          );
      if (!mounted) return;
      setState(() {
        _registeredUser = user;
        _step = _RegistrationStep.mpin;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = describeApiException(context, error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleCreateMpin(String mpin) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).createMpin(mpin: mpin);
      if (!mounted) return;
      if (_registeredUser != null) {
        ref
            .read(sessionControllerProvider.notifier)
            .setAuthenticated(_registeredUser!, LoginRole.donor);
      }
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

    if (_step == _RegistrationStep.otp) {
      return _RegistrationFormScaffold(
        title: l10n.verifyOtp,
        onBack: () => setState(() => _step = _RegistrationStep.mobile),
        formKey: GlobalKey<FormState>(),
        intro: RegistrationIntroCard(
          title: l10n.verifyOtp,
          description: '${l10n.enterOtp} sent to ${_phone.text}',
          icon: Icons.mark_email_read_outlined,
        ),
        children: [
          OtpVerificationWidget(
            phoneNumber: _phone.text.trim(),
            debugOtp: _debugOtp,
            onVerify: _handleVerifyOtp,
            onResend: _handleRequestOtp,
            isSubmitting: _isSubmitting,
            errorMessage: _errorMessage,
          ),
        ],
      );
    }

    if (_step == _RegistrationStep.mpin) {
      return _RegistrationFormScaffold(
        title: l10n.createMpin,
        onBack: () => setState(() => _step = _RegistrationStep.details),
        formKey: GlobalKey<FormState>(),
        intro: RegistrationIntroCard(
          title: l10n.createMpin,
          description: l10n.createMpinDescription,
          icon: Icons.lock_outline,
        ),
        children: [
          MpinInputWidget(
            title: l10n.createMpin,
            description: l10n.createMpinDescription,
            submitLabel: l10n.createMpinButton,
            onSubmit: _handleCreateMpin,
            requireConfirm: true,
            isSubmitting: _isSubmitting,
            errorMessage: _errorMessage,
          ),
        ],
      );
    }

    if (_step == _RegistrationStep.mobile) {
      return _RegistrationFormScaffold(
        title: l10n.donorRegistration,
        onBack: widget.onBack,
        formKey: _formKey,
        intro: RegistrationIntroCard(
          title: l10n.donorRegistration,
          description: l10n.donorRegistrationDescription,
          icon: Icons.favorite_border,
        ),
        children: [
          FormSectionCard(
            title: l10n.donorRegistration,
            child: Column(
              children: [
                AuthPhoneField(
                  hint: l10n.phoneHint,
                  controller: _phone,
                  onChanged: (_) => _revalidate(),
                  validator: AuthValidators.phone(l10n),
                ),
                const SizedBox(height: AuthSpacing.section),
                if (_errorMessage != null)
                  AuthErrorBanner(
                      message: _errorMessage!, onRetry: _handleRequestOtp),
                AuthPrimaryButton(
                  label: l10n.sendOtp,
                  icon: Icons.arrow_forward,
                  onPressed: (_canContinue && !_isSubmitting)
                      ? _handleRequestOtp
                      : null,
                ),
                if (_isSubmitting) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return _RegistrationFormScaffold(
      title: l10n.donorRegistration,
      onBack: () => setState(() => _step = _RegistrationStep.mobile),
      formKey: _formKey,
      intro: RegistrationIntroCard(
        title: l10n.donorRegistration,
        description: l10n.donorRegistrationDescription,
        icon: Icons.favorite_border,
      ),
      children: [
        FormSectionCard(
          title: l10n.personalDetails,
          child: Column(
            children: [
              AuthTextField(
                label: l10n.fullName,
                hint: l10n.fullNameHint,
                controller: _fullName,
                onChanged: (_) => _revalidate(),
                validator: AuthValidators.required(l10n),
              ),
              const SizedBox(height: AuthSpacing.field),
              AuthTextField(
                label: l10n.email,
                hint: l10n.emailHint,
                controller: _email,
                optional: true,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidators.optionalEmail(l10n),
              ),
              const SizedBox(height: AuthSpacing.field),
              AuthTextField(
                label: l10n.panNumber,
                hint: l10n.panNumberHint,
                controller: _pan,
                optional: true,
                validator: AuthValidators.optionalPan(l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthSpacing.section),
        LocationFormSection(
          addressController: _address,
          cityController: _city,
          pinCodeController: _pinCode,
          onChanged: (_) => _revalidate(),
        ),
        const SizedBox(height: AuthSpacing.section),
        if (_errorMessage != null)
          AuthErrorBanner(
              message: _errorMessage!, onRetry: _handleSubmitDetails),
        AuthPrimaryButton(
          label: l10n.continueToVerification,
          icon: Icons.arrow_forward,
          onPressed:
              (_canContinue && !_isSubmitting) ? _handleSubmitDetails : null,
        ),
        if (_isSubmitting) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _RegistrationFormScaffold extends StatelessWidget {
  const _RegistrationFormScaffold({
    required this.title,
    required this.onBack,
    required this.formKey,
    required this.intro,
    required this.children,
  });

  final String title;
  final VoidCallback onBack;
  final GlobalKey<FormState> formKey;
  final Widget intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.authColors.background,
        appBar: AuthAppBar(title: title, onBack: onBack, step: 1),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AuthSpacing.page),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [intro, const SizedBox(height: 28), ...children],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
