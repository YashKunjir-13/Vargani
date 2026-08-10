import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/profile/widgets/bank_details_section.dart';

void main() {
  group('BankDetails Model & Validation', () {
    test('parses bank details JSON correctly and masks account number', () {
      final json = {
        'bankAccountName': 'Shree Siddhivinayak Ganpati Mandal',
        'bankName': 'State Bank of India',
        'accountNumber': '912345678901',
        'ifscCode': 'SBIN0001234',
        'branchName': 'Dadar West Branch',
        'vpa': 'siddhivinayak@upi',
      };

      final bank = BankDetails.fromJson(json);

      expect(bank.accountHolderName, 'Shree Siddhivinayak Ganpati Mandal');
      expect(bank.bankName, 'State Bank of India');
      expect(bank.accountNumber, '912345678901');
      expect(bank.accountNumberMasked, 'XXXX XXXX 8901');
      expect(bank.ifscCode, 'SBIN0001234');
      expect(bank.branchName, 'Dadar West Branch');
      expect(bank.vpa, 'siddhivinayak@upi');
      expect(bank.isConfigured, isTrue);
    });

    test('serializes to JSON accurately', () {
      const bank = BankDetails(
        accountHolderName: 'Ganesh Mandal',
        bankName: 'HDFC Bank',
        accountNumber: '123456789',
        ifscCode: 'HDFC0001234',
        vpa: 'ganesh@upi',
      );

      final json = bank.toJson();

      expect(json['bankAccountName'], 'Ganesh Mandal');
      expect(json['bankName'], 'HDFC Bank');
      expect(json['accountNumber'], '123456789');
      expect(json['ifscCode'], 'HDFC0001234');
      expect(json['vpa'], 'ganesh@upi');
    });
  });
}
