import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bills_mock_data.dart';
import '../models/bill.dart';

/// Thrown when the same user who created/submitted a bill tries to approve
/// it -- mirrors BillsService's self-approval defense-in-depth, which runs
/// regardless of whether that user's role also grants approval rights.
class SelfApprovalException implements Exception {
  final String message;
  const SelfApprovalException(this.message);
}

/// Local, in-memory stand-in for BillsService (apps/api/src/bills).
class BillsNotifier extends Notifier<List<Bill>> {
  @override
  List<Bill> build() => buildMockBills();

  Bill create({
    required String receiverName,
    String? contact,
    required double amount,
    required String taskOrField,
    bool isRegisteredVendor = false,
    required String createdBy,
  }) {
    final bill = Bill(
      id: 'bill-${DateTime.now().microsecondsSinceEpoch}',
      billNumber: 'BILL-2026-${(state.length + 14).toString().padLeft(6, '0')}',
      receiverName: receiverName,
      contact: contact,
      amount: amount,
      date: DateTime.now(),
      taskOrField: taskOrField,
      isRegisteredVendor: isRegisteredVendor,
      status: BillStatus.draft,
      createdBy: createdBy,
    );
    state = [bill, ...state];
    return bill;
  }

  void update(String id, {double? amount, String? receiverName, String? taskOrField}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.draft)
          b.copyWith(amount: amount, receiverName: receiverName, taskOrField: taskOrField)
        else
          b,
    ];
  }

  void submit(String id) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.draft) b.copyWith(status: BillStatus.pendingApproval) else b,
    ];
  }

  /// Throws SelfApprovalException if approvedBy == the bill's own creator,
  /// even though the Treasurer role holds both bill.create and bill.approve.
  void approve(String id, {required String approvedBy}) {
    final bill = state.firstWhere((b) => b.id == id);
    if (bill.createdBy == approvedBy) {
      throw const SelfApprovalException('A bill cannot be approved by the same user who created/submitted it');
    }
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.pendingApproval) b.copyWith(status: BillStatus.approved, approvedBy: approvedBy) else b,
    ];
  }

  void reject(String id, {required String reason}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.pendingApproval)
          b.copyWith(status: BillStatus.draft, rejectionReason: reason)
        else
          b,
    ];
  }

  void markPaid(String id, {required BillPaymentMode paymentMode}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.approved) b.copyWith(status: BillStatus.paid, paymentMode: paymentMode) else b,
    ];
  }

  void cancel(String id, {required String reason}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status != BillStatus.cancelled) b.copyWith(status: BillStatus.cancelled, cancelReason: reason) else b,
    ];
  }
}

final billsProvider = NotifierProvider<BillsNotifier, List<Bill>>(BillsNotifier.new);
