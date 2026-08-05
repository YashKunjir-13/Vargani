// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'पौती पुस्तक';

  @override
  String get appTagline => 'गणपति मंडल वित्तीय प्रबंधक';

  @override
  String get registerSelectType => 'पंजीकरण — प्रकार चुनें';

  @override
  String get trustRegistration => 'ट्रस्ट पंजीकरण';

  @override
  String get trustRegistrationDescription =>
      'गणपति मंडल या ट्रस्ट के रूप में पंजीकरण करें';

  @override
  String get donorRegistration => 'दाता पंजीकरण';

  @override
  String get donorRegistrationDescription =>
      'दाता / योगदानकर्ता के रूप में पंजीकरण करें';

  @override
  String get or => 'या';

  @override
  String get alreadyRegisteredLogin => 'पहले से पंजीकृत हैं? लॉग इन करें';

  @override
  String get login => 'लॉग इन';

  @override
  String get loginDescription =>
      'जारी रखने के लिए अपना पंजीकृत\nमोबाइल नंबर दर्ज करें';

  @override
  String get sendOtp => 'ओटीपी भेजें';

  @override
  String get backToRegistration => 'पंजीकरण पर वापस जाएँ';

  @override
  String get otpNotAvailable => 'ओटीपी डिलीवरी भविष्य के चरण में जोड़ी जाएगी।';

  @override
  String get registrationNotAvailable =>
      'पंजीकरण सबमिशन भविष्य के चरण में जोड़ा जाएगा।';

  @override
  String get mandalDetails => 'मंडल विवरण';

  @override
  String get mandalTrustName => 'मंडल / ट्रस्ट का नाम';

  @override
  String get mandalTrustNameHint => 'जैसे श्री सिद्धिविनायक गणपति मंडल';

  @override
  String get registrationNumber => 'पंजीकरण संख्या';

  @override
  String get registrationNumberHint => 'जैसे CHAR/2018/12345';

  @override
  String get presidentHeadName => 'अध्यक्ष / प्रमुख का नाम';

  @override
  String get presidentHeadNameHint => 'जैसे महेश दत्तात्रय कुलकर्णी';

  @override
  String get festivalYear => 'उत्सव वर्ष';

  @override
  String get continueToVerification => 'सत्यापन के लिए जारी रखें';

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get fullNameHint => 'जैसे रमेश शिवाजी पाटिल';

  @override
  String get email => 'ईमेल';

  @override
  String get emailHint => 'जैसे ramesh@email.com';

  @override
  String get panNumber => 'पैन नंबर';

  @override
  String get panNumberHint => 'AAAPD1234M (80G के लिए)';

  @override
  String get location => 'स्थान';

  @override
  String get address => 'पता';

  @override
  String get addressHint => 'गली / क्षेत्र';

  @override
  String get city => 'शहर';

  @override
  String get cityHint => 'जैसे मुंबई';

  @override
  String get state => 'राज्य';

  @override
  String get stateHint => 'जैसे महाराष्ट्र';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordHint => 'कम से कम 8 अक्षर';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get confirmPasswordHint => 'अपना पासवर्ड फिर से दर्ज करें';

  @override
  String get errorPasswordMismatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get errorPasswordTooShort => 'पासवर्ड कम से कम 8 अक्षर का होना चाहिए।';

  @override
  String get pinCode => 'पिन कोड';

  @override
  String get pinCodeHint => '400028';

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get phoneHint => '98765 43210';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get back => 'वापस';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get errorRequiredField => 'यह फ़ील्ड आवश्यक है।';

  @override
  String get errorInvalidPhoneNumber =>
      'एक मान्य 10-अंकीय मोबाइल नंबर दर्ज करें।';

  @override
  String get errorInvalidEmail => 'एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get errorInvalidPinCode => 'एक मान्य 6-अंकीय पिन कोड दर्ज करें।';

  @override
  String get errorInvalidPanNumber =>
      'एक मान्य पैन नंबर दर्ज करें, जैसे AAAPD1234M।';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get donorAccount => 'दाता खाता';

  @override
  String get errorNetwork =>
      'सर्वर तक नहीं पहुंचा जा सका। अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get mandalDashboardTitle => 'मंडल डैशबोर्ड';

  @override
  String get donorDashboardTitle => 'दाता डैशबोर्ड';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodAfternoon => 'शुभ दोपहर';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get welcomeBack => 'स्वागत है,';

  @override
  String get festivalOverview => 'उत्सव अवलोकन';

  @override
  String get totalCollections => 'कुल संग्रह';

  @override
  String get currentBalance => 'वर्तमान शेष';

  @override
  String get todaysCollection => 'आज का संग्रह';

  @override
  String get pendingBills => 'बकाया बिल';

  @override
  String get pendingReceipts => 'बकाया रसीदें';

  @override
  String get volunteersCount => 'स्वयंसेवक';

  @override
  String get totalDonors => 'कुल दाता';

  @override
  String get upcomingEvents => 'आगामी कार्यक्रम';

  @override
  String get mainModules => 'मुख्य मॉड्यूल';

  @override
  String get recentTransactions => 'हाल के लेनदेन';

  @override
  String get quickActions => 'त्वरित कार्रवाइयाँ';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get incomeVsExpense => 'आय बनाम व्यय';

  @override
  String get monthlyContributions => 'मासिक योगदान';

  @override
  String get topDonors => 'शीर्ष दाता';

  @override
  String get pendingPayments => 'बकाया भुगतान';

  @override
  String get budgetUtilization => 'बजट उपयोग';

  @override
  String get collectDonation => 'दान एकत्र करें';

  @override
  String get generateReceipt => 'रसीद बनाएँ';

  @override
  String get addExpense => 'व्यय जोड़ें';

  @override
  String get createBill => 'बिल बनाएँ';

  @override
  String get addVolunteer => 'स्वयंसेवक जोड़ें';

  @override
  String get addSponsor => 'प्रायोजक जोड़ें';

  @override
  String get viewReports => 'रिपोर्ट देखें';

  @override
  String get totalDonations => 'कुल दान';

  @override
  String get thisYear => 'इस वर्ष';

  @override
  String get lastDonation => 'अंतिम दान';

  @override
  String get favoriteMandal => 'पसंदीदा मंडल';

  @override
  String get digitalReceipts => 'डिजिटल रसीदें';

  @override
  String get donateAgain => 'पुनः दान करें';

  @override
  String get viewReceipts => 'रसीदें देखें';

  @override
  String get contributionHistory => 'योगदान इतिहास';

  @override
  String get supportCampaigns => 'अभियान का समर्थन करें';

  @override
  String get favouriteMandals => 'पसंदीदा मंडल';

  @override
  String get downloadReceiptPdf => 'रसीद पीडीएफ डाउनलोड करें';

  @override
  String get recentDonations => 'हाल के दान';

  @override
  String get donationHistoryGraph => 'दान इतिहास ग्राफ';

  @override
  String get yearlyContribution => 'वार्षिक योगदान';

  @override
  String get monthlyContribution => 'मासिक योगदान';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get privacy => 'गोपनीयता और सुरक्षा';
}
