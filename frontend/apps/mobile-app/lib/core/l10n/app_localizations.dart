import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  english('en', 'English'),
  marathi('mr', 'मराठी'),
  hindi('hi', 'हिंदी');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.english;

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(AppLanguageNotifier.new);

/// Centralized localization strings for Pauti Pustak.
class L10n {
  static final Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.english: {
      'app_title': 'Pauti Pustak',
      'mandal_name': 'Shree Ganesh Mandal',
      'festival_year': 'Festival Year 2026',
      'template_calibration': 'Template Calibration',
      'payment_collection': 'Payment Collection',
      'receipts': 'Receipts',
      'bill_generation': 'Bill Generation',
      'contributions': 'Contributions',
      'contribution_receipts': 'Contribution Receipts',
      'record_payment': 'Record Payment',
      'donor_name': 'Donor Name',
      'amount': 'Amount (₹)',
      'address': 'Address',
      'contact': 'Contact Number',
      'optional': '(Optional)',
      'submit': 'Submit',
      'confirm_match': 'Confirm Match',
      'void': 'Void Payment',
      'approve': 'Approve',
      'reject': 'Reject',
      'mark_paid': 'Mark as Paid',
      'activate_template': 'Activate Template',
      'upload_template': 'Upload Template',
      'donation_type': 'Donation Type',
      'gold_silver_fields': 'Gold / Silver Specification',
      'weight_grams': 'Weight (Grams)',
      'estimated_value': 'Estimated Value (₹)',
      'item_description': 'Item Description',
      'certificate_photo': 'Certificate / Purity Photo',
      'bill_photo_ocr': 'Bill Photo & OCR Prefill',
      'scan_bill': 'Scan & Extract Bill',
      'roles': 'User Role',
    },
    AppLanguage.marathi: {
      'app_title': 'पावती पुस्तक',
      'mandal_name': 'श्री गणेश मंडळ',
      'festival_year': 'उत्सव वर्ष २०२६',
      'template_calibration': 'पावती नमुना कॅलिब्रेशन',
      'payment_collection': 'वर्गणी संकलन',
      'receipts': 'पावत्या',
      'bill_generation': 'बिल निर्मिती',
      'contributions': 'ऐच्छिक वस्तू व योगदान',
      'contribution_receipts': 'योगदान पावत्या',
      'record_payment': 'वर्गणी नोंदवा',
      'donor_name': 'देणगीदाराचे नाव',
      'amount': 'रक्कम (₹)',
      'address': 'पत्ता',
      'contact': 'संपर्क क्रमांक',
      'optional': '(ऐच्छिक)',
      'submit': 'सादर करा',
      'confirm_match': 'जुळणी निश्चित करा',
      'void': 'रद्द करा',
      'approve': 'मंजूर करा',
      'reject': 'नाकारा',
      'mark_paid': 'भरणा पूर्ण झाला',
      'activate_template': 'नमुना सक्रिय करा',
      'upload_template': 'नमुना अपलोड करा',
      'donation_type': 'देणगीचा प्रकार',
      'gold_silver_fields': 'सोने / चांदी तपशील',
      'weight_grams': 'वजन (ग्रॅम)',
      'estimated_value': 'अंदाजित मूल्य (₹)',
      'item_description': 'वस्तूचे वर्णन',
      'certificate_photo': 'प्रमाणपत्र / शुद्धता फोटो',
      'bill_photo_ocr': 'बिल फोटो आणि ओसीआर प्रिफिल',
      'scan_bill': 'बिल स्कॅन करा',
      'roles': 'वापरकर्ता भूमिका',
    },
    AppLanguage.hindi: {
      'app_title': 'पावती पुस्तक',
      'mandal_name': 'श्री गणेश मंडल',
      'festival_year': 'उत्सव वर्ष २०२६',
      'template_calibration': 'रसीद टेम्पलेट कैलिब्रेशन',
      'payment_collection': 'चंदा संग्रह',
      'receipts': 'रसीदें',
      'bill_generation': 'बिल निर्माण',
      'contributions': 'वस्तु व सेवा योगदान',
      'contribution_receipts': 'योगदान रसीदें',
      'record_payment': 'चंदा दर्ज करें',
      'donor_name': 'दाता का नाम',
      'amount': 'राशि (₹)',
      'address': 'पता',
      'contact': 'संपर्क नंबर',
      'optional': '(वैकल्पिक)',
      'submit': 'जमा करें',
      'confirm_match': 'मैच की पुष्टि करें',
      'void': 'रद्द करें',
      'approve': 'स्वीकृत करें',
      'reject': 'अस्वीकृत करें',
      'mark_paid': 'भुगतान पूर्ण',
      'activate_template': 'टेम्पलेट सक्रिय करें',
      'upload_template': 'टेम्पलेट अपलोड करें',
      'donation_type': 'दान का प्रकार',
      'gold_silver_fields': 'सोना / चांदी विवरण',
      'weight_grams': 'वजन (ग्राम)',
      'estimated_value': 'अनुमानित मूल्य (₹)',
      'item_description': 'वस्तु का विवरण',
      'certificate_photo': 'प्रमाणपत्र / शुद्धता फोटो',
      'bill_photo_ocr': 'बिल फोटो एवं ओसीआर प्रीफिल',
      'scan_bill': 'बिल स्कैन करें',
      'roles': 'उपयोगकर्ता भूमिका',
    },
  };

  static String tr(WidgetRef ref, String key) {
    final lang = ref.watch(appLanguageProvider);
    return _translations[lang]?[key] ?? _translations[AppLanguage.english]?[key] ?? key;
  }

  static String trContext(BuildContext context, WidgetRef ref, String key) {
    return tr(ref, key);
  }
}
