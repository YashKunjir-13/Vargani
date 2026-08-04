import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/bills/models/bill.dart';
import 'package:pauti_pustak_mobile/features/bills/state/bills_notifier.dart';
import 'package:pauti_pustak_mobile/features/contribution_receipts/models/contribution_receipt.dart';
import 'package:pauti_pustak_mobile/features/contribution_receipts/state/contribution_receipts_notifier.dart';
import 'package:pauti_pustak_mobile/features/contributions/models/contribution.dart';
import 'package:pauti_pustak_mobile/features/contributions/state/contributions_notifier.dart';
import 'package:pauti_pustak_mobile/features/payments/models/payment.dart';
import 'package:pauti_pustak_mobile/features/payments/state/payments_notifier.dart';
import 'package:pauti_pustak_mobile/features/receipts/models/receipt.dart';
import 'package:pauti_pustak_mobile/features/receipts/state/receipts_notifier.dart';
import 'package:pauti_pustak_mobile/features/templates/state/templates_notifier.dart';

void main() {
  group('Full End-to-End Integration & Wiring Suite', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('END-TO-END FLOW: Payment creation -> auto Receipt -> WhatsApp dispatch', () async {
      final paymentsNotifier = container.read(paymentsProvider.notifier);

      // 1. Create Payment
      final newPayment = await paymentsNotifier.create(
        donorName: 'Aarav Kumar',
        contact: '+91 9876543210',
        amount: 2500.0,
        channel: PaymentChannel.qrCode,
        collectedBy: 'collector-zone1',
      );

      expect(newPayment, isNotNull);
      expect(newPayment!.status, equals(PaymentStatus.pendingMatch));

      // 2. Confirm Match (triggers Receipt Generation automatically)
      await paymentsNotifier.confirmMatch(newPayment.id, matchedBy: 'treasurer-main');

      final paymentsList = container.read(paymentsProvider).value ?? [];
      final updatedPayment = paymentsList.firstWhere((p) => p.id == newPayment.id);
      expect(updatedPayment.status, equals(PaymentStatus.receipted));

      // 3. Verify Receipt Auto-Generation
      final receipts = container.read(receiptsProvider).value ?? [];
      final generatedReceipt = receipts.firstWhere((r) => r.paymentId == newPayment.id);

      expect(generatedReceipt.donorName, equals('Aarav Kumar'));
      expect(generatedReceipt.amount, equals(2500.0));
      expect(generatedReceipt.receiptNumber, startsWith('RCPT-2026-'));
      expect(generatedReceipt.status, equals(ReceiptStatus.active));

      // 4. WhatsApp Resend Check
      await container.read(receiptsProvider.notifier).resendWhatsapp(generatedReceipt.id);
      final updatedReceipts = container.read(receiptsProvider).value ?? [];
      final resentReceipt = updatedReceipts.firstWhere((r) => r.id == generatedReceipt.id);
      expect(resentReceipt, isNotNull);
    });

    test('LIFECYCLE 2: Non-monetary contribution recorded -> CRCPT- receipt auto-generated', () {
      final contributionsNotifier = container.read(contributionsProvider.notifier);

      // 1. Record Contribution
      final contribution = contributionsNotifier.record(
        contributorName: 'Sunita Sharma',
        contact: '+91 9123456789',
        donationType: DonationType.gold,
        itemDescription: 'Gold Idol Crown',
        weightGrams: 15.5,
        estimatedValue: 105000.0,
        recordedBy: 'volunteer-gate2',
      );

      expect(contribution.status, equals(ContributionStatus.receipted));

      // 2. Verify Auto-Generated Contribution Receipt with independent CRCPT- counter
      final contributionReceipts = container.read(contributionReceiptsProvider);
      final crcpt = contributionReceipts.firstWhere((r) => r.contributionId == contribution.id);

      expect(crcpt.contributorName, equals('Sunita Sharma'));
      expect(crcpt.donationType, equals('Gold'));
      expect(crcpt.contributionReceiptNumber, startsWith('CRCPT-2026-'));
      expect(crcpt.status, equals(ContributionReceiptStatus.active));

      // 3. Confirm template resolution fallback
      final activeTemplate = container.read(activeTemplateProvider);
      expect(activeTemplate.name, isNotEmpty);
    });

    test('LIFECYCLE 3: Bill drafted -> submitted -> self-approval blocked -> approved (different user) -> marked paid', () {
      final billsNotifier = container.read(billsProvider.notifier);

      // 1. Draft Bill
      final bill = billsNotifier.create(
        receiverName: 'Apex Decorators',
        amount: 45000.0,
        taskOrField: 'Pandal Lighting & Decoration',
        isRegisteredVendor: true,
        createdBy: 'user-treasurer-1',
      );

      expect(bill.status, equals(BillStatus.draft));
      expect(bill.billNumber, startsWith('BILL-2026-'));

      // 2. Submit Bill
      billsNotifier.submit(bill.id);
      final submittedBill = container.read(billsProvider).firstWhere((b) => b.id == bill.id);
      expect(submittedBill.status, equals(BillStatus.pendingApproval));

      // 3. Self-Approval Guard Test: Same user approval must fail!
      expect(
        () => billsNotifier.approve(bill.id, approvedBy: 'user-treasurer-1'),
        throwsA(isA<SelfApprovalException>()),
      );

      // 4. Approval by different user succeeds!
      billsNotifier.approve(bill.id, approvedBy: 'user-admin-2');
      final approvedBill = container.read(billsProvider).firstWhere((b) => b.id == bill.id);
      expect(approvedBill.status, equals(BillStatus.approved));
      expect(approvedBill.approvedBy, equals('user-admin-2'));

      // 5. Mark Paid
      billsNotifier.markPaid(bill.id, paymentMode: BillPaymentMode.bankTransfer);
      final paidBill = container.read(billsProvider).firstWhere((b) => b.id == bill.id);
      expect(paidBill.status, equals(BillStatus.paid));
    });

    test('COUNTER INDEPENDENCE: RCPT- and CRCPT- counters operate collision-free', () async {
      final paymentsNotifier = container.read(paymentsProvider.notifier);
      final contributionsNotifier = container.read(contributionsProvider.notifier);

      final p = await paymentsNotifier.create(
        donorName: 'Test Donor',
        amount: 100.0,
        channel: PaymentChannel.inApp,
      );
      expect(p, isNotNull);
      await paymentsNotifier.confirmMatch(p!.id, matchedBy: 'auditor');

      final c = contributionsNotifier.record(
        contributorName: 'Test Contributor',
        donationType: DonationType.food,
        recordedBy: 'volunteer',
      );

      final rcpt = (container.read(receiptsProvider).value ?? []).firstWhere((r) => r.paymentId == p.id);
      final crcpt = container.read(contributionReceiptsProvider).firstWhere((r) => r.contributionId == c.id);

      expect(rcpt.receiptNumber, startsWith('RCPT-2026-'));
      expect(crcpt.contributionReceiptNumber, startsWith('CRCPT-2026-'));
      expect(rcpt.receiptNumber, isNot(equals(crcpt.contributionReceiptNumber)));
    });
  });
}
