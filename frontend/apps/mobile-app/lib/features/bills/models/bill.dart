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

  factory Bill.fromJson(Map<String, dynamic> json) {
    BillStatus parseStatus(String? statusStr) {
      switch (statusStr) {
        case 'DRAFT':
          return BillStatus.draft;
        case 'PENDING_APPROVAL':
          return BillStatus.pendingApproval;
        case 'APPROVED':
          return BillStatus.approved;
        case 'PAID':
          return BillStatus.paid;
        case 'CANCELLED':
          return BillStatus.cancelled;
        default:
          return BillStatus.draft;
      }
    }

    BillPaymentMode? parsePaymentMode(String? modeStr) {
      if (modeStr == null) return null;
      switch (modeStr) {
        case 'CASH':
          return BillPaymentMode.cash;
        case 'BANK_TRANSFER':
          return BillPaymentMode.bankTransfer;
        case 'UPI':
          return BillPaymentMode.upi;
        case 'CHEQUE':
          return BillPaymentMode.cheque;
        default:
          return null;
      }
    }

    final rawAmount = json['amount'];
    final double amountVal = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

    return Bill(
      id: json['id'] as String? ?? '',
      billNumber: json['billNumber'] as String? ?? '',
      receiverName: json['receiverNameSnapshot'] as String? ??
          json['receiverName'] as String? ??
          '',
      contact: json['contactSnapshot'] as String? ?? json['contact'] as String?,
      amount: amountVal,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      taskOrField: json['taskOrField'] as String? ?? '',
      isRegisteredVendor: json['vendorId'] != null ||
          (json['isRegisteredVendor'] as bool? ?? false),
      status: parseStatus(json['status'] as String?),
      createdBy: json['createdByUserId'] as String? ??
          json['createdBy'] as String? ??
          '',
      approvedBy:
          json['approvedByUserId'] as String? ?? json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      paymentMode: parsePaymentMode(json['paymentMode'] as String?),
      cancelReason: json['cancelReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString(BillStatus status) {
      switch (status) {
        case BillStatus.draft:
          return 'DRAFT';
        case BillStatus.pendingApproval:
          return 'PENDING_APPROVAL';
        case BillStatus.approved:
          return 'APPROVED';
        case BillStatus.paid:
          return 'PAID';
        case BillStatus.cancelled:
          return 'CANCELLED';
      }
    }

    String? paymentModeToString(BillPaymentMode? mode) {
      if (mode == null) return null;
      switch (mode) {
        case BillPaymentMode.cash:
          return 'CASH';
        case BillPaymentMode.bankTransfer:
          return 'BANK_TRANSFER';
        case BillPaymentMode.upi:
          return 'UPI';
        case BillPaymentMode.cheque:
          return 'CHEQUE';
      }
    }

    return {
      'id': id,
      'billNumber': billNumber,
      'receiverNameSnapshot': receiverName,
      'contactSnapshot': contact,
      'amount': amount,
      'date': date.toIso8601String(),
      'taskOrField': taskOrField,
      'status': statusToString(status),
      'createdByUserId': createdBy,
      'approvedByUserId': approvedBy,
      'rejectionReason': rejectionReason,
      'paymentMode': paymentModeToString(paymentMode),
      'cancelReason': cancelReason,
    };
  }

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
