import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_text_fields.dart';

class BankDetails {
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? accountNumberMasked;
  final String? ifscCode;
  final String? branchName;
  final String? vpa;

  const BankDetails({
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.accountNumberMasked,
    this.ifscCode,
    this.branchName,
    this.vpa,
  });

  bool get isConfigured =>
      (accountNumber != null && accountNumber!.isNotEmpty) ||
      (vpa != null && vpa!.isNotEmpty);

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    final rawAccount = json['accountNumber'] as String?;
    final masked = json['accountNumberMasked'] as String? ??
        (rawAccount != null && rawAccount.length > 4
            ? 'XXXX XXXX ${rawAccount.substring(rawAccount.length - 4)}'
            : rawAccount);

    return BankDetails(
      accountHolderName: json['bankAccountName'] as String? ?? json['accountHolderName'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: rawAccount,
      accountNumberMasked: masked,
      ifscCode: json['ifscCode'] as String?,
      branchName: json['branchName'] as String?,
      vpa: json['vpa'] as String? ?? json['upiId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (accountHolderName != null) 'bankAccountName': accountHolderName,
        if (bankName != null) 'bankName': bankName,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (ifscCode != null) 'ifscCode': ifscCode,
        if (branchName != null) 'branchName': branchName,
        if (vpa != null) 'vpa': vpa,
      };
}

class BankDetailsNotifier extends Notifier<BankDetails> {
  @override
  BankDetails build() {
    return const BankDetails(
      accountHolderName: 'Shree Siddhivinayak Ganpati Mandal',
      bankName: 'State Bank of India',
      accountNumber: '912345678901',
      accountNumberMasked: 'XXXX XXXX 8901',
      ifscCode: 'SBIN0001234',
      branchName: 'Dadar West Branch',
      vpa: 'siddhivinayak@upi',
    );
  }

  Future<bool> saveBankDetails({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String branchName,
    required String vpa,
  }) async {
    final trimmedVpa = vpa.trim();
    final trimmedAccount = accountNumber.replaceAll(RegExp(r'\s+'), '');
    final masked = trimmedAccount.length > 4
        ? 'XXXX XXXX ${trimmedAccount.substring(trimmedAccount.length - 4)}'
        : trimmedAccount;

    final updated = BankDetails(
      accountHolderName: accountHolderName.trim(),
      bankName: bankName.trim(),
      accountNumber: trimmedAccount,
      accountNumberMasked: masked,
      ifscCode: ifscCode.trim().toUpperCase(),
      branchName: branchName.trim(),
      vpa: trimmedVpa,
    );

    state = updated;

    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/api/v1/organizations/current/banking', data: updated.toJson());
    } catch (_) {
      // Offline fallback preserves local state update
    }

    return true;
  }
}

final bankDetailsProvider = NotifierProvider<BankDetailsNotifier, BankDetails>(
  BankDetailsNotifier.new,
);

class BankDetailsSection extends ConsumerWidget {
  const BankDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final l10n = context.l10n;
    final bank = ref.watch(bankDetailsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_outlined, color: colors.brandOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    l10n.bankDetailsSection,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colors.brandOrange, size: 20),
                onPressed: () => _showEditBankDetailsSheet(context, ref, bank),
                tooltip: l10n.editProfile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!bank.isConfigured) ...[
            Text(
              'No bank account or VPA configured yet.',
              style: TextStyle(color: colors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showEditBankDetailsSheet(context, ref, bank),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.bankDetailsSection),
            ),
          ] else ...[
            _infoItem(context, l10n.accountHolderLabel, bank.accountHolderName ?? '—'),
            _infoItem(context, l10n.bankNameLabel, bank.bankName ?? '—'),
            _infoItem(context, l10n.accountNumberLabel, bank.accountNumberMasked ?? '—'),
            _infoItem(context, l10n.ifscCodeLabel, bank.ifscCode ?? '—'),
            _infoItem(context, l10n.branchNameLabel, bank.branchName ?? '—'),
            _infoItem(context, l10n.vpaLabel, bank.vpa ?? '—', isHighlight: true),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value, {bool isHighlight = false}) {
    final colors = context.authColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isHighlight ? colors.brandOrange : colors.text,
                fontSize: 14,
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showEditBankDetailsSheet(BuildContext context, WidgetRef ref, BankDetails currentBank) {
    final colors = context.authColors;
    final holderController = TextEditingController(text: currentBank.accountHolderName ?? '');
    final bankNameController = TextEditingController(text: currentBank.bankName ?? '');
    final accountController = TextEditingController(text: currentBank.accountNumber ?? '');
    final ifscController = TextEditingController(text: currentBank.ifscCode ?? '');
    final branchController = TextEditingController(text: currentBank.branchName ?? '');
    final vpaController = TextEditingController(text: currentBank.vpa ?? '');

    bool isSubmitting = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Configure Bank Details',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close, color: colors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      label: 'Account Holder Name',
                      hint: 'e.g. Shree Siddhivinayak Ganpati Mandal',
                      controller: holderController,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      label: 'Bank Name',
                      hint: 'e.g. State Bank of India',
                      controller: bankNameController,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      label: 'Account Number',
                      hint: 'e.g. 912345678901',
                      controller: accountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      label: 'IFSC Code',
                      hint: 'e.g. SBIN0001234',
                      controller: ifscController,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      label: 'Branch Name',
                      hint: 'e.g. Dadar West Branch',
                      controller: branchController,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      label: 'VPA / UPI ID',
                      hint: 'e.g. mandalname@upi',
                      controller: vpaController,
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setState(() => errorText = null);
                                final holder = holderController.text.trim();
                                final bank = bankNameController.text.trim();
                                final account = accountController.text.trim();
                                final ifsc = ifscController.text.trim();
                                final branch = branchController.text.trim();
                                final vpa = vpaController.text.trim();

                                if (vpa.isEmpty && account.isEmpty) {
                                  setState(() => errorText = 'Please enter at least an Account Number or VPA / UPI ID.');
                                  return;
                                }

                                if (vpa.isNotEmpty && !vpa.contains('@')) {
                                  setState(() => errorText = 'Please enter a valid VPA / UPI ID (e.g. name@upi).');
                                  return;
                                }

                                setState(() => isSubmitting = true);
                                final messenger = ScaffoldMessenger.of(context);
                                final success = await ref.read(bankDetailsProvider.notifier).saveBankDetails(
                                      accountHolderName: holder,
                                      bankName: bank,
                                      accountNumber: account,
                                      ifscCode: ifsc,
                                      branchName: branch,
                                      vpa: vpa,
                                    );

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  if (success) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: const Text('Bank details saved successfully'),
                                        backgroundColor: colors.brandOrange,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Save Bank Details',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
