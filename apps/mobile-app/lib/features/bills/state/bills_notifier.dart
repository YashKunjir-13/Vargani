import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_controller.dart';
import '../data/bills_mock_data.dart';
import '../data/bills_remote_datasource.dart';
import '../models/bill.dart';

/// Thrown when the same user who created/submitted a bill tries to approve
/// it -- mirrors BillsService's self-approval defense-in-depth, which runs
/// regardless of whether that user's role also grants approval rights.
class SelfApprovalException implements Exception {
  final String message;
  const SelfApprovalException(this.message);
}

final billsRemoteDataSourceProvider = Provider<BillsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return BillsRemoteDataSource(dio);
});

class BillsNotifier extends Notifier<List<Bill>> {
  @override
  List<Bill> build() {
    fetchRemote();
    return const [];
  }

  Future<void> fetchRemote() async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final fetched = await remote.fetchBills();
      state = fetched;
    } catch (_) {}
  }

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

    // Fire & forget async sync to remote API if available
    _createRemote(receiverName: receiverName, contact: contact, amount: amount, taskOrField: taskOrField, localId: bill.id);

    return bill;
  }

  Future<void> _createRemote({
    required String receiverName,
    String? contact,
    required double amount,
    required String taskOrField,
    required String localId,
  }) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    try {
      final created = await remote.createBill(
        receiverName: receiverName,
        contact: contact,
        amount: amount,
        taskOrField: taskOrField,
      );
      state = [
        for (final b in state) if (b.id == localId) created else b,
      ];
      await fetchRemote();
    } catch (_) {}
  }

  void update(String id, {double? amount, String? receiverName, String? taskOrField}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.draft)
          b.copyWith(amount: amount, receiverName: receiverName, taskOrField: taskOrField)
        else
          b,
    ];
    _updateRemote(id, amount: amount, receiverName: receiverName, taskOrField: taskOrField);
  }

  Future<void> _updateRemote(String id, {double? amount, String? receiverName, String? taskOrField}) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      await remote.updateBill(id, amount: amount, receiverName: receiverName, taskOrField: taskOrField);
    } catch (_) {}
  }

  void submit(String id) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.draft) b.copyWith(status: BillStatus.pendingApproval) else b,
    ];
    _submitRemote(id);
  }

  Future<void> _submitRemote(String id) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final updated = await remote.submitBill(id);
      state = [for (final b in state) if (b.id == id) updated else b];
    } catch (_) {}
  }

  /// Throws SelfApprovalException if approvedBy == the bill's own creator,
  /// even though the Treasurer role holds both bill.create and bill.approve.
  void approve(String id, {required String approvedBy}) {
    final bill = state.firstWhere((b) => b.id == id, orElse: () => throw Exception('Bill not found'));
    if (bill.createdBy == approvedBy) {
      throw const SelfApprovalException('A bill cannot be approved by the same user who created/submitted it');
    }
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.pendingApproval) b.copyWith(status: BillStatus.approved, approvedBy: approvedBy) else b,
    ];
    _approveRemote(id, approvedBy: approvedBy);
  }

  Future<void> _approveRemote(String id, {required String approvedBy}) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final updated = await remote.approveBill(id);
      state = [for (final b in state) if (b.id == id) updated else b];
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw SelfApprovalException(e.response?.data['message']?.toString() ?? 'A bill cannot be approved by the same user who created/submitted it');
      }
    } catch (_) {}
  }

  void reject(String id, {required String reason}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.pendingApproval)
          b.copyWith(status: BillStatus.draft, rejectionReason: reason)
        else
          b,
    ];
    _rejectRemote(id, reason: reason);
  }

  Future<void> _rejectRemote(String id, {required String reason}) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final updated = await remote.rejectBill(id, reason: reason);
      state = [for (final b in state) if (b.id == id) updated else b];
    } catch (_) {}
  }

  void markPaid(String id, {required BillPaymentMode paymentMode}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status == BillStatus.approved) b.copyWith(status: BillStatus.paid, paymentMode: paymentMode) else b,
    ];
    _markPaidRemote(id, paymentMode: paymentMode);
  }

  Future<void> _markPaidRemote(String id, {required BillPaymentMode paymentMode}) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final updated = await remote.markPaidBill(id, paymentMode: paymentMode);
      state = [for (final b in state) if (b.id == id) updated else b];
    } catch (_) {}
  }

  void cancel(String id, {required String reason}) {
    state = [
      for (final b in state)
        if (b.id == id && b.status != BillStatus.cancelled) b.copyWith(status: BillStatus.cancelled, cancelReason: reason) else b,
    ];
    _cancelRemote(id, reason: reason);
  }

  Future<void> _cancelRemote(String id, {required String reason}) async {
    final remote = ref.read(billsRemoteDataSourceProvider);
    if (remote == null) return;
    try {
      final updated = await remote.cancelBill(id, reason: reason);
      state = [for (final b in state) if (b.id == id) updated else b];
    } catch (_) {}
  }
}

final billsProvider = NotifierProvider<BillsNotifier, List<Bill>>(BillsNotifier.new);

