import 'package:flutter/widgets.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

extension LocalizationBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String get languageCode => Localizations.localeOf(this).languageCode;

  String get allRecords {
    switch (languageCode) {
      case 'hi':
        return 'सभी रिकॉर्ड';
      case 'mr':
        return 'सर्व नोंदी';
      default:
        return 'All Records';
    }
  }

  String get browseByCategory {
    switch (languageCode) {
      case 'hi':
        return 'श्रेणी अनुसार ब्राउज़ करें';
      case 'mr':
        return 'वर्गवारीनुसार ब्राउझ करा';
      default:
        return 'Browse by category';
    }
  }

  String get sponsors {
    switch (languageCode) {
      case 'hi':
        return 'प्रायोजक';
      case 'mr':
        return 'प्रायोजक';
      default:
        return 'Sponsors';
    }
  }

  String get sponsorsDesc {
    switch (languageCode) {
      case 'hi':
        return 'संकल्प और पुष्टि जीवनचक्र के साथ प्रायोजन रिकॉर्ड';
      case 'mr':
        return 'संकल्प व निश्चितीसह प्रायोजकत्व नोंदी';
      default:
        return 'Tiered sponsorship records with pledge & confirmation lifecycle';
    }
  }

  String get advertisements {
    switch (languageCode) {
      case 'hi':
        return 'विज्ञापन';
      case 'mr':
        return 'जाहिराती';
      default:
        return 'Advertisements';
    }
  }

  String get advertisementsDesc {
    switch (languageCode) {
      case 'hi':
        return 'स्थान बुकिंग और विज्ञापन रिकॉर्ड';
      case 'mr':
        return 'जाहिरात बुकिंग आणि जागा नोंदी';
      default:
        return 'Placement bookings and space advertisement records';
    }
  }

  String get donors {
    switch (languageCode) {
      case 'hi':
        return 'दाता';
      case 'mr':
        return 'देणगीदार';
      default:
        return 'Donors';
    }
  }

  String get donorsDesc {
    switch (languageCode) {
      case 'hi':
        return 'अंशदान इतिहास के साथ योगदानकर्ता खाते';
      case 'mr':
        return 'वर्गणी इतिहासासह योगदानकर्ता खाती';
      default:
        return 'Contributor accounts with contribution history';
    }
  }

  String get volunteers {
    switch (languageCode) {
      case 'hi':
        return 'स्वयंसेवक';
      case 'mr':
        return 'स्वयंसेवक';
      default:
        return 'Volunteers';
    }
  }

  String get volunteersDesc {
    switch (languageCode) {
      case 'hi':
        return 'स्वयंसेवक कार्य और क्षेत्र कार्यकर्ता रिकॉर्ड';
      case 'mr':
        return 'स्वयंसेवक कर्तव्य आणि मैदान कार्य नोंदी';
      default:
        return 'Volunteer assignments and field worker records';
    }
  }

  String get vendors {
    switch (languageCode) {
      case 'hi':
        return 'विक्रेता';
      case 'mr':
        return 'विक्रेते';
      default:
        return 'Vendors';
    }
  }

  String get vendorsDesc {
    switch (languageCode) {
      case 'hi':
        return 'विक्रेता बिल, व्यय ट्रैकिंग और अनुबंध रिकॉर्ड';
      case 'mr':
        return 'विक्रेता बिले, खर्च मागोवा आणि करार नोंदी';
      default:
        return 'Vendor bills, expense tracking, and contract records';
    }
  }

  String get searchSponsorsHint {
    switch (languageCode) {
      case 'hi':
        return 'प्रायोजक खोजें';
      case 'mr':
        return 'प्रायोजक शोधा';
      default:
        return 'Search sponsors';
    }
  }

  String get searchAdsHint {
    switch (languageCode) {
      case 'hi':
        return 'विज्ञापन खोजें';
      case 'mr':
        return 'जाहिरात शोधा';
      default:
        return 'Search advertisements';
    }
  }

  String get searchDonorsHint {
    switch (languageCode) {
      case 'hi':
        return 'दाता खोजें';
      case 'mr':
        return 'देणगीदार शोधा';
      default:
        return 'Search donors';
    }
  }

  String get searchVolunteersHint {
    switch (languageCode) {
      case 'hi':
        return 'स्वयंसेवक खोजें';
      case 'mr':
        return 'स्वयंसेवक शोधा';
      default:
        return 'Search volunteers';
    }
  }

  String get searchVendorsHint {
    switch (languageCode) {
      case 'hi':
        return 'विक्रेता खोजें';
      case 'mr':
        return 'विक्रेते शोधा';
      default:
        return 'Search vendors';
    }
  }

  String get confirmedLabel {
    switch (languageCode) {
      case 'hi':
        return 'पुष्ट';
      case 'mr':
        return 'निश्चित';
      default:
        return 'Confirmed';
    }
  }

  String get pledgedLabel {
    switch (languageCode) {
      case 'hi':
        return 'संकल्पित';
      case 'mr':
        return 'संकल्पित';
      default:
        return 'Pledged';
    }
  }

  String get pendingLabel {
    switch (languageCode) {
      case 'hi':
        return 'बकाया';
      case 'mr':
        return 'प्रलंबित';
      default:
        return 'Pending';
    }
  }

  String get totalVendorsLabel {
    switch (languageCode) {
      case 'hi':
        return 'कुल विक्रेता';
      case 'mr':
        return 'एकूण विक्रेते';
      default:
        return 'Total Vendors';
    }
  }

  String get outstandingLabel {
    switch (languageCode) {
      case 'hi':
        return 'बकाया राशि';
      case 'mr':
        return 'थकबाकी';
      default:
        return 'Outstanding';
    }
  }

  String get statusLabel {
    switch (languageCode) {
      case 'hi':
        return 'स्थिति';
      case 'mr':
        return 'स्थिती';
      default:
        return 'Status';
    }
  }

  String get typeLabel {
    switch (languageCode) {
      case 'hi':
        return 'प्रकार';
      case 'mr':
        return 'प्रकार';
      default:
        return 'Type';
    }
  }

  String get allLabel {
    switch (languageCode) {
      case 'hi':
        return 'सभी';
      case 'mr':
        return 'सर्व';
      default:
        return 'All';
    }
  }

  String get addSponsorBtn {
    switch (languageCode) {
      case 'hi':
        return 'प्रायोजक जोड़ें';
      case 'mr':
        return 'प्रायोजक जोडा';
      default:
        return 'Add Sponsor';
    }
  }

  String get bookAdBtn {
    switch (languageCode) {
      case 'hi':
        return 'विज्ञापन बुक करें';
      case 'mr':
        return 'जाहिरात बुक करा';
      default:
        return 'Book Advertisement';
    }
  }

  String get addBtn {
    switch (languageCode) {
      case 'hi':
        return 'जोड़ें';
      case 'mr':
        return 'जोडा';
      default:
        return 'Add';
    }
  }

  String get addBillBtn {
    switch (languageCode) {
      case 'hi':
        return '+ बिल';
      case 'mr':
        return '+ बिल';
      default:
        return '+ Bill';
    }
  }
}
