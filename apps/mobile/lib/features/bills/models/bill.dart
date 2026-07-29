/// Mirrors backend BillStatus (apps/api/src/bills). Rejected is reserved
/// for data-model fidelity but never actually assigned -- reject() goes
/// straight back to Draft, same as the real backend.
enum BillStatus { draft, pendingApproval, approved, paid, cancelled }

enum BillPaymentMode { cash, bankTransfer, upi, cheque }

extension BillStatusLabel on BillStatus {
  String get label => switch (this) {
        BillStatus.draft => 'Draft',
        BillStatus.pendingApproval => 'Pending Approval',
        BillStatus.approved => 'Approved',
        BillStatus.paid => 'Paid',
        BillStatus.cancelled => 'Cancelled',
      };
}

extension BillPaymentModeLabel on BillPaymentMode {
  String get label => switch (this) {
        BillPaymentMode.cash => 'Cash',
        BillPaymentMode.bankTransfer => 'Bank Transfer',
        BillPaymentMode.upi => 'UPI',
        BillPaymentMode.cheque => 'Cheque',
      };
}

class Bill {
  final String id;
  final String billNumber;
  final String receiverName;
  final String? contact;
  final double amount;
  final DateTime date;
  final String taskOrField;
  final bool isRegisteredVendor;
  final BillStatus status;
  final String createdBy;
  final String? approvedBy;
  final String? rejectionReason;
  final BillPaymentMode? paymentMode;
  final String? cancelReason;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.receiverName,
    this.contact,
    required this.amount,
    required this.date,
    required this.taskOrField,
    this.isRegisteredVendor = false,
    required this.status,
    required this.createdBy,
    this.approvedBy,
    this.rejectionReason,
    this.paymentMode,
    this.cancelReason,
  });

  Bill copyWith({
    BillStatus? status,
    String? approvedBy,
    String? rejectionReason,
    BillPaymentMode? paymentMode,
    String? cancelReason,
    double? amount,
    String? receiverName,
    String? taskOrField,
  }) {
    return Bill(
      id: id,
      billNumber: billNumber,
      receiverName: receiverName ?? this.receiverName,
      contact: contact,
      amount: amount ?? this.amount,
      date: date,
      taskOrField: taskOrField ?? this.taskOrField,
      isRegisteredVendor: isRegisteredVendor,
      status: status ?? this.status,
      createdBy: createdBy,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      paymentMode: paymentMode ?? this.paymentMode,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
