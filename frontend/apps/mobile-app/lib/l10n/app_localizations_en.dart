// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pauti Pustak';

  @override
  String get appTagline => 'Ganpati Mandal Financial Manager';

  @override
  String get registerSelectType => 'REGISTER — SELECT TYPE';

  @override
  String get trustRegistration => 'Trust Registration';

  @override
  String get trustRegistrationDescription =>
      'Register as a Ganpati Mandal or Trust';

  @override
  String get donorRegistration => 'Donor Registration';

  @override
  String get donorRegistrationDescription =>
      'Register as a donor / contributor';

  @override
  String get or => 'OR';

  @override
  String get alreadyRegisteredLogin => 'Already registered? Login';

  @override
  String get login => 'Login';

  @override
  String get loginDescription =>
      'Enter your registered mobile number to\ncontinue';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get enterOtp => 'Enter 6-digit OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpSent => 'OTP sent successfully';

  @override
  String get otpExpired => 'OTP challenge expired';

  @override
  String get invalidOtp => 'Invalid OTP code';

  @override
  String get mobileVerified => 'Mobile Verified';

  @override
  String get loginWithPassword => 'Password Login';

  @override
  String get loginWithOtp => 'OTP Login';

  @override
  String get backToRegistration => 'Back to Registration';

  @override
  String get mandalDetails => 'Mandal Details';

  @override
  String get mandalTrustName => 'Mandal / Trust Name';

  @override
  String get mandalTrustNameHint => 'e.g. Shree Siddhivinayak Ganpati Mandal';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get registrationNumberHint => 'e.g. CHAR/2018/12345';

  @override
  String get presidentHeadName => 'President / Head Name';

  @override
  String get presidentHeadNameHint => 'e.g. Mahesh Dattatray Kulkarni';

  @override
  String get festivalYear => 'Festival Year';

  @override
  String get continueToVerification => 'Continue to Verification';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'e.g. Ramesh Shivaji Patil';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'e.g. ramesh@email.com';

  @override
  String get panNumber => 'PAN No.';

  @override
  String get panNumberHint => 'AAAPD1234M (for 80G)';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Street / Area';

  @override
  String get city => 'City';

  @override
  String get cityHint => 'e.g. Mumbai';

  @override
  String get state => 'State';

  @override
  String get stateHint => 'e.g. Maharashtra';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters.';

  @override
  String get pinCode => 'PIN Code';

  @override
  String get pinCodeHint => '400028';

  @override
  String get optional => 'optional';

  @override
  String get phoneHint => '98765 43210';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get back => 'Back';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageMarathi => 'Marathi';

  @override
  String get errorRequiredField => 'This field is required.';

  @override
  String get errorInvalidPhoneNumber => 'Enter a valid 10-digit mobile number.';

  @override
  String get errorInvalidEmail => 'Enter a valid email address.';

  @override
  String get errorInvalidPinCode => 'Enter a valid 6-digit PIN code.';

  @override
  String get errorInvalidPanNumber =>
      'Enter a valid PAN number, e.g. AAAPD1234M.';

  @override
  String get logout => 'Logout';

  @override
  String get donorAccount => 'Donor account';

  @override
  String get errorNetwork =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get mandalDashboardTitle => 'Mandal Dashboard';

  @override
  String get donorDashboardTitle => 'Donor Dashboard';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get welcomeBack => 'Welcome,';

  @override
  String get festivalOverview => 'FESTIVAL OVERVIEW';

  @override
  String get totalCollections => 'Total Collections';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get todaysCollection => 'Today\'s Collection';

  @override
  String get pendingBills => 'Pending Bills';

  @override
  String get pendingReceipts => 'Pending Receipts';

  @override
  String get volunteersCount => 'Volunteers';

  @override
  String get totalDonors => 'Total Donors';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get mainModules => 'MAIN MODULES';

  @override
  String get recentTransactions => 'RECENT TRANSACTIONS';

  @override
  String get quickActions => 'QUICK ACTIONS';

  @override
  String get analytics => 'ANALYTICS';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get monthlyContributions => 'Monthly Contributions';

  @override
  String get topDonors => 'Top Donors';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get budgetUtilization => 'Budget Utilization';

  @override
  String get collectDonation => 'Collect Donation';

  @override
  String get generateReceipt => 'Generate Receipt';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get createBill => 'Create Bill';

  @override
  String get addVolunteer => 'Add Volunteer';

  @override
  String get addSponsor => 'Add Sponsor';

  @override
  String get viewReports => 'View Reports';

  @override
  String get totalDonations => 'Total Donations';

  @override
  String get thisYear => 'This Year';

  @override
  String get lastDonation => 'Last Donation';

  @override
  String get favoriteMandal => 'Favorite Mandal';

  @override
  String get digitalReceipts => 'Digital Receipts';

  @override
  String get donateAgain => 'Donate Again';

  @override
  String get viewReceipts => 'View Receipts';

  @override
  String get contributionHistory => 'Contribution History';

  @override
  String get supportCampaigns => 'Support Campaigns';

  @override
  String get favouriteMandals => 'Favourite Mandals';

  @override
  String get downloadReceiptPdf => 'Download Receipt PDF';

  @override
  String get recentDonations => 'Recent Donations';

  @override
  String get donationHistoryGraph => 'Donation History Graph';

  @override
  String get yearlyContribution => 'Yearly Contribution';

  @override
  String get monthlyContribution => 'Monthly Contribution';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy & Security';

  @override
  String get enterMpin => 'Enter 6-Digit MPIN';

  @override
  String get createMpin => 'Create 6-Digit MPIN';

  @override
  String get confirmMpin => 'Confirm 6-Digit MPIN';

  @override
  String get createMpinDescription =>
      'Set a secure 6-digit MPIN for quick daily login';

  @override
  String get errorMpinTooShort => 'MPIN must be exactly 6 numeric digits.';

  @override
  String get errorMpinMismatch => 'MPINs do not match.';

  @override
  String get loginWithMpin => 'Login with MPIN';

  @override
  String get forgotMpin => 'Forgot MPIN?';

  @override
  String get resetMpin => 'Reset MPIN';

  @override
  String get resendCodeIn => 'Resend code in';

  @override
  String get seconds => 'seconds';

  @override
  String get createMpinButton => 'Create MPIN & Finish';

  @override
  String get saveNewMpin => 'Save New MPIN';
}
