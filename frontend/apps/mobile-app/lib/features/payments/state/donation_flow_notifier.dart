import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/providers/dashboard_providers.dart';
import 'payments_notifier.dart';

class DonationFlowState {
  final int currentStep;
  final Map<String, dynamic>? selectedEvent;
  final Map<String, dynamic>?
      selectedDonor; // {donorType: 'existing'|'new', name, mobile, email, pan, address, id}
  final double amount;
  final String purpose;
  final bool is80GRequired;
  final String notes;
  final String
      paymentMethod; // UPI | CARD | NET_BANKING | CASH | CHEQUE | BANK_TRANSFER
  final String? paymentId;
  final String? razorpayOrderId;
  final String? receiptId;
  final String? receiptNumber;
  final String? idempotencyKey;
  final String? mockOutcome;
  final String? errorMessage;
  final bool isLoading;

  const DonationFlowState({
    this.currentStep = 1,
    this.selectedEvent,
    this.selectedDonor,
    this.amount = 1000.0,
    this.purpose = 'Ganesh Festival Donation',
    this.is80GRequired = false,
    this.notes = '',
    this.paymentMethod = 'UPI',
    this.paymentId,
    this.razorpayOrderId,
    this.receiptId,
    this.receiptNumber,
    this.idempotencyKey,
    this.mockOutcome,
    this.errorMessage,
    this.isLoading = false,
  });

  DonationFlowState copyWith({
    int? currentStep,
    Map<String, dynamic>? selectedEvent,
    Map<String, dynamic>? selectedDonor,
    double? amount,
    String? purpose,
    bool? is80GRequired,
    String? notes,
    String? paymentMethod,
    String? paymentId,
    String? razorpayOrderId,
    String? receiptId,
    String? receiptNumber,
    String? idempotencyKey,
    String? mockOutcome,
    String? errorMessage,
    bool? isLoading,
  }) {
    return DonationFlowState(
      currentStep: currentStep ?? this.currentStep,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      selectedDonor: selectedDonor ?? this.selectedDonor,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      is80GRequired: is80GRequired ?? this.is80GRequired,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      receiptId: receiptId ?? this.receiptId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      mockOutcome: mockOutcome ?? this.mockOutcome,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DonationFlowNotifier extends Notifier<DonationFlowState> {
  @override
  DonationFlowState build() {
    return DonationFlowState(
      idempotencyKey: 'IDEM-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  void selectEvent(Map<String, dynamic> event) {
    state = state.copyWith(selectedEvent: event, currentStep: 2);
  }

  void selectDonor(Map<String, dynamic> donor) {
    state = state.copyWith(selectedDonor: donor, currentStep: 3);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount, currentStep: 4);
  }

  void setDetails({
    required String purpose,
    required bool is80GRequired,
    required String notes,
  }) {
    state = state.copyWith(
      purpose: purpose,
      is80GRequired: is80GRequired,
      notes: notes,
      currentStep: 5,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method, currentStep: 6);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  Future<bool> createPaymentOrder() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      final donorName =
          state.selectedDonor?['name'] as String? ?? 'Contributor';
      final donorId = state.selectedDonor?['id'] as String?;
      final amountPaise = (state.amount * 100).round();

      if (state.paymentMethod == 'CASH' ||
          state.paymentMethod == 'CHEQUE' ||
          state.paymentMethod == 'BANK_TRANSFER') {
        // Direct offline collection
        final res = await dataSource.collectDonation(
          donorName: donorName,
          contact: state.selectedDonor?['mobile'] as String?,
          address: state.selectedDonor?['address'] as String?,
          amount: state.amount,
          paymentMethod: state.paymentMethod,
        );
        final payment = res['payment'] as Map<String, dynamic>?;
        final receipt = res['receipt'] as Map<String, dynamic>?;

        // Immediately reflect on Mandal Dashboard
        ref.read(mandalDashboardProvider.notifier).addDonation(
              amountPaise: amountPaise,
              paymentMethod: state.paymentMethod,
              donorName: donorName,
            );
        ref.read(mandalDashboardProvider.notifier).refresh();

        state = state.copyWith(
          paymentId: payment?['id'] as String?,
          receiptId: receipt?['id'] as String?,
          receiptNumber: receipt?['receiptNumber'] as String?,
          isLoading: false,
          currentStep: 9, // Success
          mockOutcome: 'SUCCESS',
        );
        return true;
      }

      // Online mock payment order
      final res = await dataSource.createPaymentOrder(
        amountPaise: amountPaise,
        donorNameSnapshot: donorName,
        donorId: donorId,
        idempotencyKey: state.idempotencyKey,
      );

      state = state.copyWith(
        paymentId: res['paymentId'] as String?,
        razorpayOrderId: res['razorpayOrderId'] as String?,
        isLoading: false,
        currentStep: 7, // Processing
      );
      return true;
    } catch (e) {
      String msg = 'Failed to create payment order.';
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          msg = resData['message'].toString();
        } else if (resData is String && resData.isNotEmpty) {
          msg = resData;
        } else if (e.message != null) {
          msg = e.message!;
        }
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> processMockOutcome(String outcome, {String? reason}) async {
    if (state.paymentId == null) return false;
    state = state.copyWith(
        isLoading: true, errorMessage: null, mockOutcome: outcome);

    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      final res = await dataSource.processMockPayment(
        paymentId: state.paymentId!,
        outcome: outcome,
        idempotencyKey: state.idempotencyKey,
        reason: reason,
      );

      final receipt = res['receipt'] as Map<String, dynamic>?;

      if (outcome == 'SUCCESS') {
        final donorName =
            state.selectedDonor?['name'] as String? ?? 'Contributor';
        final amountPaise = (state.amount * 100).round();

        // Immediately reflect on Mandal Dashboard
        ref.read(mandalDashboardProvider.notifier).addDonation(
              amountPaise: amountPaise,
              paymentMethod: state.paymentMethod,
              donorName: donorName,
            );
        ref.read(mandalDashboardProvider.notifier).refresh();
      }

      state = state.copyWith(
        receiptId: receipt?['id'] as String?,
        receiptNumber: receipt?['receiptNumber'] as String? ??
            'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        isLoading: false,
        currentStep: 9, // Result step
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process mock payment.',
      );
      return false;
    }
  }

  Future<void> retryPayment() async {
    if (state.paymentId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final dataSource = ref.read(paymentsRemoteDataSourceProvider);
      await dataSource.retryPayment(state.paymentId!);
      state = state.copyWith(isLoading: false, currentStep: 6);
    } catch (_) {
      state = state.copyWith(isLoading: false, currentStep: 6);
    }
  }

  void reset() {
    state = DonationFlowState(
      idempotencyKey: 'IDEM-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

final donationFlowProvider =
    NotifierProvider<DonationFlowNotifier, DonationFlowState>(() {
  return DonationFlowNotifier();
});
