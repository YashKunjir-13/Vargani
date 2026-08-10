import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pauti Pustak'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Ganpati Mandal Financial Manager'**
  String get appTagline;

  /// No description provided for @registerSelectType.
  ///
  /// In en, this message translates to:
  /// **'REGISTER — SELECT TYPE'**
  String get registerSelectType;

  /// No description provided for @trustRegistration.
  ///
  /// In en, this message translates to:
  /// **'Trust Registration'**
  String get trustRegistration;

  /// No description provided for @trustRegistrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Register as a Ganpati Mandal or Trust'**
  String get trustRegistrationDescription;

  /// No description provided for @donorRegistration.
  ///
  /// In en, this message translates to:
  /// **'Donor Registration'**
  String get donorRegistration;

  /// No description provided for @donorRegistrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Register as a donor / contributor'**
  String get donorRegistrationDescription;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @alreadyRegisteredLogin.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Login'**
  String get alreadyRegisteredLogin;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to\ncontinue'**
  String get loginDescription;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSent;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'OTP challenge expired'**
  String get otpExpired;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get invalidOtp;

  /// No description provided for @mobileVerified.
  ///
  /// In en, this message translates to:
  /// **'Mobile Verified'**
  String get mobileVerified;

  /// No description provided for @loginWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Password Login'**
  String get loginWithPassword;

  /// No description provided for @loginWithOtp.
  ///
  /// In en, this message translates to:
  /// **'OTP Login'**
  String get loginWithOtp;

  /// No description provided for @backToRegistration.
  ///
  /// In en, this message translates to:
  /// **'Back to Registration'**
  String get backToRegistration;

  /// No description provided for @mandalDetails.
  ///
  /// In en, this message translates to:
  /// **'Mandal Details'**
  String get mandalDetails;

  /// No description provided for @mandalTrustName.
  ///
  /// In en, this message translates to:
  /// **'Mandal / Trust Name'**
  String get mandalTrustName;

  /// No description provided for @mandalTrustNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Shree Siddhivinayak Ganpati Mandal'**
  String get mandalTrustNameHint;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @registrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CHAR/2018/12345'**
  String get registrationNumberHint;

  /// No description provided for @presidentHeadName.
  ///
  /// In en, this message translates to:
  /// **'President / Head Name'**
  String get presidentHeadName;

  /// No description provided for @presidentHeadNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mahesh Dattatray Kulkarni'**
  String get presidentHeadNameHint;

  /// No description provided for @festivalYear.
  ///
  /// In en, this message translates to:
  /// **'Festival Year'**
  String get festivalYear;

  /// No description provided for @continueToVerification.
  ///
  /// In en, this message translates to:
  /// **'Continue to Verification'**
  String get continueToVerification;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ramesh Shivaji Patil'**
  String get fullNameHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ramesh@email.com'**
  String get emailHint;

  /// No description provided for @panNumber.
  ///
  /// In en, this message translates to:
  /// **'PAN No.'**
  String get panNumber;

  /// No description provided for @panNumberHint.
  ///
  /// In en, this message translates to:
  /// **'AAAPD1234M (for 80G)'**
  String get panNumberHint;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street / Area'**
  String get addressHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mumbai'**
  String get cityHint;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @stateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Maharashtra'**
  String get stateHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @pinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'400028'**
  String get pinCodeHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'98765 43210'**
  String get phoneHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageMarathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get languageMarathi;

  /// No description provided for @errorRequiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorRequiredField;

  /// No description provided for @errorInvalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get errorInvalidPhoneNumber;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit PIN code.'**
  String get errorInvalidPinCode;

  /// No description provided for @errorInvalidPanNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid PAN number, e.g. AAAPD1234M.'**
  String get errorInvalidPanNumber;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @donorAccount.
  ///
  /// In en, this message translates to:
  /// **'Donor account'**
  String get donorAccount;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mandalDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Mandal Dashboard'**
  String get mandalDashboardTitle;

  /// No description provided for @donorDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Donor Dashboard'**
  String get donorDashboardTitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcomeBack;

  /// No description provided for @festivalOverview.
  ///
  /// In en, this message translates to:
  /// **'FESTIVAL OVERVIEW'**
  String get festivalOverview;

  /// No description provided for @totalCollections.
  ///
  /// In en, this message translates to:
  /// **'Total Collections'**
  String get totalCollections;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @todaysCollection.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Collection'**
  String get todaysCollection;

  /// No description provided for @pendingBills.
  ///
  /// In en, this message translates to:
  /// **'Pending Bills'**
  String get pendingBills;

  /// No description provided for @pendingReceipts.
  ///
  /// In en, this message translates to:
  /// **'Pending Receipts'**
  String get pendingReceipts;

  /// No description provided for @volunteersCount.
  ///
  /// In en, this message translates to:
  /// **'Volunteers'**
  String get volunteersCount;

  /// No description provided for @totalDonors.
  ///
  /// In en, this message translates to:
  /// **'Total Donors'**
  String get totalDonors;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @mainModules.
  ///
  /// In en, this message translates to:
  /// **'MAIN MODULES'**
  String get mainModules;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'RECENT TRANSACTIONS'**
  String get recentTransactions;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS'**
  String get analytics;

  /// No description provided for @incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// No description provided for @monthlyContributions.
  ///
  /// In en, this message translates to:
  /// **'Monthly Contributions'**
  String get monthlyContributions;

  /// No description provided for @topDonors.
  ///
  /// In en, this message translates to:
  /// **'Top Donors'**
  String get topDonors;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @budgetUtilization.
  ///
  /// In en, this message translates to:
  /// **'Budget Utilization'**
  String get budgetUtilization;

  /// No description provided for @collectDonation.
  ///
  /// In en, this message translates to:
  /// **'Collect Donation'**
  String get collectDonation;

  /// No description provided for @generateReceipt.
  ///
  /// In en, this message translates to:
  /// **'Generate Receipt'**
  String get generateReceipt;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @createBill.
  ///
  /// In en, this message translates to:
  /// **'Create Bill'**
  String get createBill;

  /// No description provided for @addVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Add Volunteer'**
  String get addVolunteer;

  /// No description provided for @addSponsor.
  ///
  /// In en, this message translates to:
  /// **'Add Sponsor'**
  String get addSponsor;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @totalDonations.
  ///
  /// In en, this message translates to:
  /// **'Total Donations'**
  String get totalDonations;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @lastDonation.
  ///
  /// In en, this message translates to:
  /// **'Last Donation'**
  String get lastDonation;

  /// No description provided for @favoriteMandal.
  ///
  /// In en, this message translates to:
  /// **'Favorite Mandal'**
  String get favoriteMandal;

  /// No description provided for @digitalReceipts.
  ///
  /// In en, this message translates to:
  /// **'Digital Receipts'**
  String get digitalReceipts;

  /// No description provided for @donateAgain.
  ///
  /// In en, this message translates to:
  /// **'Donate Again'**
  String get donateAgain;

  /// No description provided for @viewReceipts.
  ///
  /// In en, this message translates to:
  /// **'View Receipts'**
  String get viewReceipts;

  /// No description provided for @contributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution History'**
  String get contributionHistory;

  /// No description provided for @supportCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Support Campaigns'**
  String get supportCampaigns;

  /// No description provided for @favouriteMandals.
  ///
  /// In en, this message translates to:
  /// **'Favourite Mandals'**
  String get favouriteMandals;

  /// No description provided for @downloadReceiptPdf.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt PDF'**
  String get downloadReceiptPdf;

  /// No description provided for @recentDonations.
  ///
  /// In en, this message translates to:
  /// **'Recent Donations'**
  String get recentDonations;

  /// No description provided for @donationHistoryGraph.
  ///
  /// In en, this message translates to:
  /// **'Donation History Graph'**
  String get donationHistoryGraph;

  /// No description provided for @yearlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Yearly Contribution'**
  String get yearlyContribution;

  /// No description provided for @monthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly Contribution'**
  String get monthlyContribution;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacy;

  /// No description provided for @enterMpin.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-Digit MPIN'**
  String get enterMpin;

  /// No description provided for @createMpin.
  ///
  /// In en, this message translates to:
  /// **'Create 6-Digit MPIN'**
  String get createMpin;

  /// No description provided for @confirmMpin.
  ///
  /// In en, this message translates to:
  /// **'Confirm 6-Digit MPIN'**
  String get confirmMpin;

  /// No description provided for @createMpinDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a secure 6-digit MPIN for quick daily login'**
  String get createMpinDescription;

  /// No description provided for @errorMpinTooShort.
  ///
  /// In en, this message translates to:
  /// **'MPIN must be exactly 6 numeric digits.'**
  String get errorMpinTooShort;

  /// No description provided for @errorMpinMismatch.
  ///
  /// In en, this message translates to:
  /// **'MPINs do not match.'**
  String get errorMpinMismatch;

  /// No description provided for @loginWithMpin.
  ///
  /// In en, this message translates to:
  /// **'Login with MPIN'**
  String get loginWithMpin;

  /// No description provided for @forgotMpin.
  ///
  /// In en, this message translates to:
  /// **'Forgot MPIN?'**
  String get forgotMpin;

  /// No description provided for @resetMpin.
  ///
  /// In en, this message translates to:
  /// **'Reset MPIN'**
  String get resetMpin;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @createMpinButton.
  ///
  /// In en, this message translates to:
  /// **'Create MPIN & Finish'**
  String get createMpinButton;

  /// No description provided for @saveNewMpin.
  ///
  /// In en, this message translates to:
  /// **'Save New MPIN'**
  String get saveNewMpin;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @contributionsTab.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contributionsTab;

  /// No description provided for @billsTab.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get billsTab;

  /// No description provided for @reportsTab.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTab;

  /// No description provided for @receiptsTab.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receiptsTab;

  /// No description provided for @historyTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// No description provided for @paymentsTab.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTab;

  /// No description provided for @allRecordsTab.
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get allRecordsTab;

  /// No description provided for @quickSummarySection.
  ///
  /// In en, this message translates to:
  /// **'QUICK SUMMARY'**
  String get quickSummarySection;

  /// No description provided for @keyHighlightsSection.
  ///
  /// In en, this message translates to:
  /// **'KEY HIGHLIGHTS'**
  String get keyHighlightsSection;

  /// No description provided for @bankDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Bank Details & VPA'**
  String get bankDetailsSection;

  /// No description provided for @accountHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Holder'**
  String get accountHolderLabel;

  /// No description provided for @bankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankNameLabel;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumberLabel;

  /// No description provided for @ifscCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCodeLabel;

  /// No description provided for @branchNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchNameLabel;

  /// No description provided for @vpaLabel.
  ///
  /// In en, this message translates to:
  /// **'VPA / UPI ID'**
  String get vpaLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
