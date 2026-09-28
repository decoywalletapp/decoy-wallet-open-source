import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @msgCameraAccessRequiredForQrScan.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to scan QR codes. You can enable it in device settings.'**
  String get msgCameraAccessRequiredForQrScan;

  /// No description provided for @msgCouldNotOpenQrScanner.
  ///
  /// In en, this message translates to:
  /// **'Could not open the QR scanner. Please try again or paste the text.'**
  String get msgCouldNotOpenQrScanner;

  /// No description provided for @msgComplete.
  ///
  /// In en, this message translates to:
  /// **' % Complete'**
  String get msgComplete;

  /// No description provided for @msgControl.
  ///
  /// In en, this message translates to:
  /// **' Control'**
  String get msgControl;

  /// No description provided for @msgDaysLeft.
  ///
  /// In en, this message translates to:
  /// **' DAYS LEFT'**
  String get msgDaysLeft;

  /// No description provided for @msgSettingsControlCenter.
  ///
  /// In en, this message translates to:
  /// **' Settings > Control Center'**
  String get msgSettingsControlCenter;

  /// No description provided for @msgSignUpHere.
  ///
  /// In en, this message translates to:
  /// **' Sign Up here'**
  String get msgSignUpHere;

  /// No description provided for @msgAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get msgAnd;

  /// No description provided for @msgByNavigatingTo.
  ///
  /// In en, this message translates to:
  /// **' by navigating to '**
  String get msgByNavigatingTo;

  /// No description provided for @msgOutlinedByDecoyWalletLlc.
  ///
  /// In en, this message translates to:
  /// **' outlined by DECOY WALLET LLC'**
  String get msgOutlinedByDecoyWalletLlc;

  /// No description provided for @msgSeconds.
  ///
  /// In en, this message translates to:
  /// **' seconds'**
  String get msgSeconds;

  /// No description provided for @msg0TradedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'\$0 traded this month'**
  String get msg0TradedThisMonth;

  /// No description provided for @msg1000ToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'\$1,000 to next level'**
  String get msg1000ToNextLevel;

  /// No description provided for @msg5551234567Or447700900123.
  ///
  /// In en, this message translates to:
  /// **'(555) 123-4567 or +44 7700 900123'**
  String get msg5551234567Or447700900123;

  /// No description provided for @msg15551234567Or33612.
  ///
  /// In en, this message translates to:
  /// **'+1 555 123 4567 or +33 6 12 34 56 78'**
  String get msg15551234567Or33612;

  /// No description provided for @msgEnterItBelowToVerifyYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'. Enter it below to verify your phone number.'**
  String get msgEnterItBelowToVerifyYourPhoneNumber;

  /// No description provided for @msg0Btc.
  ///
  /// In en, this message translates to:
  /// **'0 BTC'**
  String get msg0Btc;

  /// No description provided for @msg10kBtc.
  ///
  /// In en, this message translates to:
  /// **'10K BTC'**
  String get msg10kBtc;

  /// No description provided for @msg123OceanDr.
  ///
  /// In en, this message translates to:
  /// **'123 Ocean Dr.'**
  String get msg123OceanDr;

  /// No description provided for @msg2MonthsFree.
  ///
  /// In en, this message translates to:
  /// **'2 months free'**
  String get msg2MonthsFree;

  /// No description provided for @msg911Trigger.
  ///
  /// In en, this message translates to:
  /// **'911 Trigger'**
  String get msg911Trigger;

  /// No description provided for @msgAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get msgAccount;

  /// No description provided for @msgActivated.
  ///
  /// In en, this message translates to:
  /// **'ACTIVATED'**
  String get msgActivated;

  /// No description provided for @msgArmToActivelyMonitorOutboundTransactions.
  ///
  /// In en, this message translates to:
  /// **'ARM TO ACTIVELY MONITOR OUTBOUND TRANSACTIONS'**
  String get msgArmToActivelyMonitorOutboundTransactions;

  /// No description provided for @msgAcceptDecoySeedPhrase.
  ///
  /// In en, this message translates to:
  /// **'Accept Decoy Seed Phrase'**
  String get msgAcceptDecoySeedPhrase;

  /// No description provided for @msgAccountSubscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Subscription Status:  '**
  String get msgAccountSubscriptionStatus;

  /// No description provided for @msgAccountSubscriptionAccessAndActiveStripeBilling.
  ///
  /// In en, this message translates to:
  /// **'Account subscription access and active Stripe billing'**
  String get msgAccountSubscriptionAccessAndActiveStripeBilling;

  /// No description provided for @msgAcknowledgements.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get msgAcknowledgements;

  /// No description provided for @msgAddYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add Your Phone Number'**
  String get msgAddYourPhoneNumber;

  /// No description provided for @msgAddAWatchOnlyWalletKeyOrSpecific.
  ///
  /// In en, this message translates to:
  /// **'Add a watch-only wallet key or specific receive addresses to monitor for outbound activity.'**
  String get msgAddAWatchOnlyWalletKeyOrSpecific;

  /// No description provided for @msgAdjustBalance.
  ///
  /// In en, this message translates to:
  /// **'Adjust balance'**
  String get msgAdjustBalance;

  /// No description provided for @msgAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get msgAdvanced;

  /// No description provided for @msgAdvancedMonitorControls.
  ///
  /// In en, this message translates to:
  /// **'Advanced Monitor Controls'**
  String get msgAdvancedMonitorControls;

  /// No description provided for @msgAgreements.
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get msgAgreements;

  /// No description provided for @msgAllowSubscriptionAlertsDirectlyToYourDevice.
  ///
  /// In en, this message translates to:
  /// **'Allow subscription alerts directly to your device'**
  String get msgAllowSubscriptionAlertsDirectlyToYourDevice;

  /// No description provided for @msgAllowYourLocationToBeIncludedAutomaticallyDuring.
  ///
  /// In en, this message translates to:
  /// **'Allow your location to be included automatically during an emergency so trusted contacts and responders can act faster. Location is never tracked in the background and is only accessed if an emergency is triggered.'**
  String get msgAllowYourLocationToBeIncludedAutomaticallyDuring;

  /// No description provided for @msgAlreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get msgAlreadyHaveAnAccount;

  /// No description provided for @msgAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get msgAmount;

  /// No description provided for @msgApartmentUnitOptional.
  ///
  /// In en, this message translates to:
  /// **'Apartment/Unit (Optional)'**
  String get msgApartmentUnitOptional;

  /// No description provided for @msgAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get msgAppLock;

  /// No description provided for @msgAppPreferencesAndConfigurations.
  ///
  /// In en, this message translates to:
  /// **'App preferences and configurations'**
  String get msgAppPreferencesAndConfigurations;

  /// No description provided for @msgApt4b.
  ///
  /// In en, this message translates to:
  /// **'Apt 4B'**
  String get msgApt4b;

  /// No description provided for @msgAutoWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Auto Withdraw'**
  String get msgAutoWithdraw;

  /// No description provided for @msgAutoWithdrawBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Auto-withdraw bitcoin'**
  String get msgAutoWithdrawBitcoin;

  /// No description provided for @msgAutomaticallySendPurchasedBitcoinToYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Automatically send purchased Bitcoin to your wallet.'**
  String get msgAutomaticallySendPurchasedBitcoinToYourWallet;

  /// No description provided for @msgAwaitingConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmations'**
  String get msgAwaitingConfirmations;

  /// No description provided for @msgBtc.
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get msgBtc;

  /// No description provided for @msgBtcUsd.
  ///
  /// In en, this message translates to:
  /// **'BTC/USD'**
  String get msgBtcUsd;

  /// No description provided for @msgBtcpayInvoiceInYourBrowser.
  ///
  /// In en, this message translates to:
  /// **'BTCPay invoice in your browser'**
  String get msgBtcpayInvoiceInYourBrowser;

  /// No description provided for @msgBiometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get msgBiometricAuthentication;

  /// No description provided for @msgBiometricVerification.
  ///
  /// In en, this message translates to:
  /// **'Biometric Verification'**
  String get msgBiometricVerification;

  /// No description provided for @msgBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get msgBitcoin;

  /// No description provided for @msgBitcoinBalance.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin Balance'**
  String get msgBitcoinBalance;

  /// No description provided for @msgBitcoinPay.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin Pay'**
  String get msgBitcoinPay;

  /// No description provided for @msgBitcoinAddressOrPaymentUri.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin address or payment URI'**
  String get msgBitcoinAddressOrPaymentUri;

  /// No description provided for @msgBitcoinBalanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin balance updated.'**
  String get msgBitcoinBalanceUpdated;

  /// No description provided for @msgBitcoinPaymentConfirmingFullProtectionActivatesAfterConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin payment confirming. Full protection activates after confirmation.'**
  String
      get msgBitcoinPaymentConfirmingFullProtectionActivatesAfterConfirmation;

  /// No description provided for @msgBroadcastedToNetwork.
  ///
  /// In en, this message translates to:
  /// **'Broadcasted to network'**
  String get msgBroadcastedToNetwork;

  /// No description provided for @msgByContinuingYouAgreeToReceiveAutomatedText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to receive automated text messages from Decoy Wallet about your account, safety alerts, emergency contact status, subscription reminders, and wallet alerts.\nMessage frequency varies. Msg & data rates may apply.\nReply STOP to opt out. Reply HELP for help.'**
  String get msgByContinuingYouAgreeToReceiveAutomatedText;

  /// No description provided for @msgByCreatingADecoyWalletYouAuthorizeDecoy.
  ///
  /// In en, this message translates to:
  /// **'By creating a Decoy Wallet, you authorize Decoy Wallet to send one time, user initiated emergency alerts to your selected contacts if you trigger an emergency event.'**
  String get msgByCreatingADecoyWalletYouAuthorizeDecoy;

  /// No description provided for @msgCannotBeTheSameAsDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'CANNOT BE THE SAME AS DECOY PIN'**
  String get msgCannotBeTheSameAsDecoyPin;

  /// No description provided for @msgChooseAccess.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE ACCESS'**
  String get msgChooseAccess;

  /// No description provided for @msgComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON !!!'**
  String get msgComingSoon;

  /// No description provided for @msgContacts.
  ///
  /// In en, this message translates to:
  /// **'CONTACTS'**
  String get msgContacts;

  /// No description provided for @msgCancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get msgCancelSubscription;

  /// No description provided for @msgCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get msgCenter;

  /// No description provided for @msgCenter2.
  ///
  /// In en, this message translates to:
  /// **'Center '**
  String get msgCenter2;

  /// No description provided for @msgChangeAccountEntryPin.
  ///
  /// In en, this message translates to:
  /// **'Change Account Entry PIN'**
  String get msgChangeAccountEntryPin;

  /// No description provided for @msgChangeTheseSettingsAnytimeInThe.
  ///
  /// In en, this message translates to:
  /// **'Change these settings anytime in the '**
  String get msgChangeTheseSettingsAnytimeInThe;

  /// No description provided for @msgCheckYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get msgCheckYourEmail;

  /// No description provided for @msgChooseFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Choose From Contacts'**
  String get msgChooseFromContacts;

  /// No description provided for @msgChooseATargetPriceForYourNextBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Choose a target price for your next Bitcoin purchase.'**
  String get msgChooseATargetPriceForYourNextBitcoin;

  /// No description provided for @msgChooseWord.
  ///
  /// In en, this message translates to:
  /// **'Choose word '**
  String get msgChooseWord;

  /// No description provided for @msgCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get msgCity;

  /// No description provided for @msgClickTheLinkInTheEmailToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Click the link in the email to confirm your account. If you don\'t see the email, check your spam folder.'**
  String get msgClickTheLinkInTheEmailToConfirm;

  /// No description provided for @msgCompleteTheRequiredDetailsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Complete the required details to continue.'**
  String get msgCompleteTheRequiredDetailsToContinue;

  /// No description provided for @msgConfigureBitcoinBalance.
  ///
  /// In en, this message translates to:
  /// **'Configure Bitcoin Balance'**
  String get msgConfigureBitcoinBalance;

  /// No description provided for @msgConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get msgConfirm;

  /// No description provided for @msgConfirmDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm DECOY PIN'**
  String get msgConfirmDecoyPin;

  /// No description provided for @msgConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get msgConfirmPin;

  /// No description provided for @msgConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get msgConfirmPassword;

  /// No description provided for @msgConfirmTransaction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transaction'**
  String get msgConfirmTransaction;

  /// No description provided for @msgConfirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get msgConfirmNewPin;

  /// No description provided for @msgConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get msgConfirmNewPassword;

  /// No description provided for @msgConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Confirmations'**
  String get msgConfirmations;

  /// No description provided for @msgContact1.
  ///
  /// In en, this message translates to:
  /// **'Contact 1'**
  String get msgContact1;

  /// No description provided for @msgContact2.
  ///
  /// In en, this message translates to:
  /// **'Contact 2'**
  String get msgContact2;

  /// No description provided for @msgContact3.
  ///
  /// In en, this message translates to:
  /// **'Contact 3'**
  String get msgContact3;

  /// No description provided for @msgContact4.
  ///
  /// In en, this message translates to:
  /// **'Contact 4'**
  String get msgContact4;

  /// No description provided for @msgContact5.
  ///
  /// In en, this message translates to:
  /// **'Contact 5'**
  String get msgContact5;

  /// No description provided for @msgContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get msgContactUs;

  /// No description provided for @msgContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get msgContinue;

  /// No description provided for @msgControl2.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get msgControl2;

  /// No description provided for @msgControlCenter.
  ///
  /// In en, this message translates to:
  /// **'Control Center'**
  String get msgControlCenter;

  /// No description provided for @msgCouldNotOpenContactsEnterContactManually.
  ///
  /// In en, this message translates to:
  /// **'Could not open contacts. Enter contact manually.'**
  String get msgCouldNotOpenContactsEnterContactManually;

  /// No description provided for @msgCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get msgCountry;

  /// No description provided for @msgCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get msgCreateAccount;

  /// No description provided for @msgCreateEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Create Emergency Contacts'**
  String get msgCreateEmergencyContacts;

  /// No description provided for @msgCreateYourPinToAccessYourDashboard.
  ///
  /// In en, this message translates to:
  /// **'Create Your PIN to Access Your Dashboard'**
  String get msgCreateYourPinToAccessYourDashboard;

  /// No description provided for @msgCreateADecoyPinForEmergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Create a DECOY PIN for Emergency Services'**
  String get msgCreateADecoyPinForEmergencyServices;

  /// No description provided for @msgCreateAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get msgCreateAnAccount;

  /// No description provided for @msgCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get msgCurrency;

  /// No description provided for @msgCurrentlyDisabledInDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Currently Disabled in Device Settings !!!'**
  String get msgCurrentlyDisabledInDeviceSettings;

  /// No description provided for @msgDeactivated.
  ///
  /// In en, this message translates to:
  /// **'DEACTIVATED'**
  String get msgDeactivated;

  /// No description provided for @msgDecoyEmergency.
  ///
  /// In en, this message translates to:
  /// **'DECOY EMERGENCY'**
  String get msgDecoyEmergency;

  /// No description provided for @msgDecoyPinCannotBeTheSameAsAccount.
  ///
  /// In en, this message translates to:
  /// **'DECOY PIN CANNOT BE THE SAME AS ACCOUNT ENTRY PIN'**
  String get msgDecoyPinCannotBeTheSameAsAccount;

  /// No description provided for @msgDecoySeed.
  ///
  /// In en, this message translates to:
  /// **'DECOY SEED'**
  String get msgDecoySeed;

  /// No description provided for @msgDecoyWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'DECOY WALLET BALANCE'**
  String get msgDecoyWalletBalance;

  /// No description provided for @msgDisable.
  ///
  /// In en, this message translates to:
  /// **'DISABLE'**
  String get msgDisable;

  /// No description provided for @msgDecoyContacts.
  ///
  /// In en, this message translates to:
  /// **'Decoy Contacts'**
  String get msgDecoyContacts;

  /// No description provided for @msgDecoyKeys.
  ///
  /// In en, this message translates to:
  /// **'Decoy Keys'**
  String get msgDecoyKeys;

  /// No description provided for @msgDecoyKeysTriggers.
  ///
  /// In en, this message translates to:
  /// **'Decoy Keys Triggers'**
  String get msgDecoyKeysTriggers;

  /// No description provided for @msgDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'Decoy PIN'**
  String get msgDecoyPin;

  /// No description provided for @msgDecoyPinTriggers.
  ///
  /// In en, this message translates to:
  /// **'Decoy PIN Triggers'**
  String get msgDecoyPinTriggers;

  /// No description provided for @msgDecoyWalletUsesNotificationsForSubscriptionAlertsDirectly.
  ///
  /// In en, this message translates to:
  /// **'Decoy Wallet uses notifications for subscription alerts directly to your device'**
  String get msgDecoyWalletUsesNotificationsForSubscriptionAlertsDirectly;

  /// No description provided for @msgDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get msgDelete;

  /// No description provided for @msgDeleteUserAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete User Account'**
  String get msgDeleteUserAccount;

  /// No description provided for @msgDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get msgDeleteMyAccount;

  /// No description provided for @msgDeletingYourDecoyWalletAccountWillPermanentlyRemove.
  ///
  /// In en, this message translates to:
  /// **'Deleting your Decoy Wallet account will permanently remove your account, emergency contacts, alert routing settings, and all app configurations. Any active Stripe subscription connected to this account will be canceled first. This action cannot be undone.'**
  String get msgDeletingYourDecoyWalletAccountWillPermanentlyRemove;

  /// No description provided for @msgDidnTReceiveTheCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get msgDidnTReceiveTheCode;

  /// No description provided for @msgDonTHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get msgDonTHaveAnAccount;

  /// No description provided for @msgEmergency.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY'**
  String get msgEmergency;

  /// No description provided for @msgEnable.
  ///
  /// In en, this message translates to:
  /// **'ENABLE'**
  String get msgEnable;

  /// No description provided for @msgEnterPin.
  ///
  /// In en, this message translates to:
  /// **'ENTER PIN'**
  String get msgEnterPin;

  /// No description provided for @msgEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'ENTER VALID PHONE NUMBER'**
  String get msgEnterValidPhoneNumber;

  /// No description provided for @msgError001PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #001 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError001PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError002PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #002 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError002PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError003PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #003 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError003PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError004PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #004 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError004PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError005PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #005 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError005PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError006PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #006 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError006PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError008PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #008 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError008PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError009PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #009 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError009PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError010PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #010 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError010PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError011PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #011 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError011PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError012PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #012 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError012PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError013PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #013 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError013PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError014PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #014 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError014PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError015PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #015 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError015PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError016PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #016 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError016PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError020PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #020 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError020PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError021PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #021 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError021PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError024PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #024 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError024PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError025PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #025 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError025PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError029PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #029 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError029PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgError030PleaseScreenshotContactDecoySupport.
  ///
  /// In en, this message translates to:
  /// **'ERROR #030 - PLEASE SCREENSHOT & CONTACT DECOY SUPPORT'**
  String get msgError030PleaseScreenshotContactDecoySupport;

  /// No description provided for @msgEta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get msgEta;

  /// No description provided for @msgEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get msgEmail;

  /// No description provided for @msgEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required!'**
  String get msgEmailRequired;

  /// No description provided for @msgEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get msgEmergencyContacts;

  /// No description provided for @msgEmergencyContactsTrigger.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts Trigger'**
  String get msgEmergencyContactsTrigger;

  /// No description provided for @msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications.
  ///
  /// In en, this message translates to:
  /// **'Emergency alerts, wallet monitoring, and emergency-contact notifications require an active paid subscription.'**
  String get msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications;

  /// No description provided for @msgEmergencyContactsAndAlertSettings.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts and alert settings'**
  String get msgEmergencyContactsAndAlertSettings;

  /// No description provided for @msgEmergencyContactsReceiveAlertsOnlyBecauseYouVoluntarily.
  ///
  /// In en, this message translates to:
  /// **'Emergency contacts receive alerts only because you voluntarily provide their phone number.\n\nInformation may be shared with emergency service providers or third parties as described in the Privacy Policy.'**
  String get msgEmergencyContactsReceiveAlertsOnlyBecauseYouVoluntarily;

  /// No description provided for @msgEnableBiometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Authentication'**
  String get msgEnableBiometricAuthentication;

  /// No description provided for @msgEnableCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Current Location'**
  String get msgEnableCurrentLocation;

  /// No description provided for @msgEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable Location\nServices'**
  String get msgEnableLocationServices;

  /// No description provided for @msgEnableLocationServices2.
  ///
  /// In en, this message translates to:
  /// **'Enable Location Services'**
  String get msgEnableLocationServices2;

  /// No description provided for @msgEnablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Push\nNotifications'**
  String get msgEnablePushNotifications;

  /// No description provided for @msgEnablePushNotifications2.
  ///
  /// In en, this message translates to:
  /// **'Enable Push Notifications'**
  String get msgEnablePushNotifications2;

  /// No description provided for @msgEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get msgEnter;

  /// No description provided for @msgEnterCurrentAccountEntryPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Current Account Entry PIN'**
  String get msgEnterCurrentAccountEntryPin;

  /// No description provided for @msgEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get msgEnterManually;

  /// No description provided for @msgEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get msgEnterVerificationCode;

  /// No description provided for @msgEnterA48DigitDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4 - 8 digit DECOY PIN '**
  String get msgEnterA48DigitDecoyPin;

  /// No description provided for @msgEnterA48DigitPinToSecure.
  ///
  /// In en, this message translates to:
  /// **'Enter a 4 - 8 digit PIN to secure your account'**
  String get msgEnterA48DigitPinToSecure;

  /// No description provided for @msgEnterANewPinToAccessYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter a new PIN to access your account'**
  String get msgEnterANewPinToAccessYourAccount;

  /// No description provided for @msgEnterAnyValueFrom0To21000.
  ///
  /// In en, this message translates to:
  /// **'Enter any value from 0 to 21,000,000 BTC'**
  String get msgEnterAnyValueFrom0To21000;

  /// No description provided for @msgEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get msgEnterEmail;

  /// No description provided for @msgEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get msgEnterFirstName;

  /// No description provided for @msgEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get msgEnterLastName;

  /// No description provided for @msgEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get msgEnterNewPassword;

  /// No description provided for @msgEnterTheAmountYouWantToSend.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount you want to send'**
  String get msgEnterTheAmountYouWantToSend;

  /// No description provided for @msgEnterTheCurrentPinYouUseToAccess.
  ///
  /// In en, this message translates to:
  /// **'Enter the current PIN you use to access your account'**
  String get msgEnterTheCurrentPinYouUseToAccess;

  /// No description provided for @msgEnterTheSame48DigitsToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4 - 8 digits to confirm your DECOY PIN'**
  String get msgEnterTheSame48DigitsToConfirm;

  /// No description provided for @msgEnterTheSame48DigitsToConfirm2.
  ///
  /// In en, this message translates to:
  /// **'Enter the same 4 - 8 digits to confirm your access PIN'**
  String get msgEnterTheSame48DigitsToConfirm2;

  /// No description provided for @msgEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email...'**
  String get msgEnterYourEmail;

  /// No description provided for @msgEnterYourEventCodeInYourBrowser.
  ///
  /// In en, this message translates to:
  /// **'Enter your event code in your browser'**
  String get msgEnterYourEventCodeInYourBrowser;

  /// No description provided for @msgExactBitcoinAmount.
  ///
  /// In en, this message translates to:
  /// **'Exact Bitcoin amount'**
  String get msgExactBitcoinAmount;

  /// No description provided for @msgFl.
  ///
  /// In en, this message translates to:
  /// **'FL'**
  String get msgFl;

  /// No description provided for @msgFollowDecoyWallet.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW DECOY WALLET'**
  String get msgFollowDecoyWallet;

  /// No description provided for @msgFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get msgFirstName;

  /// No description provided for @msgFixTheMoneyFixTheWorld.
  ///
  /// In en, this message translates to:
  /// **'Fix the money, fix the world.'**
  String get msgFixTheMoneyFixTheWorld;

  /// No description provided for @msgFlexibleAccess.
  ///
  /// In en, this message translates to:
  /// **'Flexible access'**
  String get msgFlexibleAccess;

  /// No description provided for @msgForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get msgForgotPassword;

  /// No description provided for @msgForgotPassword2.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get msgForgotPassword2;

  /// No description provided for @msgGenerated.
  ///
  /// In en, this message translates to:
  /// **'GENERATED'**
  String get msgGenerated;

  /// No description provided for @msgGenerateSeedPhrase.
  ///
  /// In en, this message translates to:
  /// **'Generate Seed Phrase'**
  String get msgGenerateSeedPhrase;

  /// No description provided for @msgGetPaidInBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Get paid in Bitcoin'**
  String get msgGetPaidInBitcoin;

  /// No description provided for @msgHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get msgHomeAddress;

  /// No description provided for @msgHowToChangeAccountEntryPin.
  ///
  /// In en, this message translates to:
  /// **'How to Change Account Entry PIN'**
  String get msgHowToChangeAccountEntryPin;

  /// No description provided for @msgHowToChangeDecoyKeys.
  ///
  /// In en, this message translates to:
  /// **'How to Change Decoy Keys'**
  String get msgHowToChangeDecoyKeys;

  /// No description provided for @msgHowToChangeDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'How to Change Decoy PIN'**
  String get msgHowToChangeDecoyPin;

  /// No description provided for @msgHowToChangePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'How to Change Phone Number'**
  String get msgHowToChangePhoneNumber;

  /// No description provided for @msgHowToChangeYourEmail.
  ///
  /// In en, this message translates to:
  /// **'How to Change Your Email'**
  String get msgHowToChangeYourEmail;

  /// No description provided for @msgHowToDeleteUserAccount.
  ///
  /// In en, this message translates to:
  /// **'How to Delete User Account'**
  String get msgHowToDeleteUserAccount;

  /// No description provided for @msgHowToEnterContactInformation.
  ///
  /// In en, this message translates to:
  /// **'How to Enter Contact Information'**
  String get msgHowToEnterContactInformation;

  /// No description provided for @msgHowToManageControlCenter.
  ///
  /// In en, this message translates to:
  /// **'How to Manage Control Center'**
  String get msgHowToManageControlCenter;

  /// No description provided for @msgIAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get msgIAgreeToThe;

  /// No description provided for @msgIUnderstandDecoyPinAlertsRelyOnMy.
  ///
  /// In en, this message translates to:
  /// **'I understand Decoy PIN alerts rely on my device permissions, network connection, and saved alert settings, and I am responsible for keeping those settings ready and current.'**
  String get msgIUnderstandDecoyPinAlertsRelyOnMy;

  /// No description provided for @msgIUnderstandDecoySeedAlertsAreDesignedFor.
  ///
  /// In en, this message translates to:
  /// **'I understand Decoy Seed alerts are designed for on-chain activity from my armed Decoy Seed wallet, and I am responsible for keeping my seed alert settings ready and current.'**
  String get msgIUnderstandDecoySeedAlertsAreDesignedFor;

  /// No description provided for @msgIUnderstandThatDecoyWalletDoesNotHold.
  ///
  /// In en, this message translates to:
  /// **'I understand that Decoy Wallet does not hold or protect my funds, cannot prevent loss, and I am fully responsible for any outcomes resulting from use or misuse of this feature.'**
  String get msgIUnderstandThatDecoyWalletDoesNotHold;

  /// No description provided for @msgIUnderstandThatEnteringMyDecoyPinWill.
  ///
  /// In en, this message translates to:
  /// **'I understand that entering my Decoy PIN will activate an emergency trigger and may notify my emergency contacts, third party services, or public safety agencies.'**
  String get msgIUnderstandThatEnteringMyDecoyPinWill;

  /// No description provided for @msgIUnderstandThatUsingMyDecoyWalletMay.
  ///
  /// In en, this message translates to:
  /// **'I understand that using my Decoy Wallet may trigger emergency alerts to my contacts, third party services, or public safety agencies.'**
  String get msgIUnderstandThatUsingMyDecoyWalletMay;

  /// No description provided for @msgIUnderstandThisActionIsPermanentAndCannot.
  ///
  /// In en, this message translates to:
  /// **'I understand this action is permanent and cannot be undone'**
  String get msgIUnderstandThisActionIsPermanentAndCannot;

  /// No description provided for @msgIUnderstandThisFeatureIsOnlyForReal.
  ///
  /// In en, this message translates to:
  /// **'I understand this feature is only for real emergency situations, and I am responsible for any false alerts, fees, or consequences caused by misuse.'**
  String get msgIUnderstandThisFeatureIsOnlyForReal;

  /// No description provided for @msgInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get msgInactive;

  /// No description provided for @msgIncorrectPin.
  ///
  /// In en, this message translates to:
  /// **'INCORRECT PIN'**
  String get msgIncorrectPin;

  /// No description provided for @msgInvalidLogin.
  ///
  /// In en, this message translates to:
  /// **'INVALID LOGIN'**
  String get msgInvalidLogin;

  /// No description provided for @msgInvalidPasswordMustBeAtLeast10Characters.
  ///
  /// In en, this message translates to:
  /// **'INVALID PASSWORD - MUST BE AT LEAST 10 CHARACTERS'**
  String get msgInvalidPasswordMustBeAtLeast10Characters;

  /// No description provided for @msgInvalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'INVALID PHONE NUMBER'**
  String get msgInvalidPhoneNumber;

  /// No description provided for @msgInvalidPinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'INVALID PIN - TRY AGAIN'**
  String get msgInvalidPinTryAgain;

  /// No description provided for @msgImportantToEnableTheDecoyPinFeatureYou.
  ///
  /// In en, this message translates to:
  /// **'Important: To enable the Decoy PIN feature, you must confirm all of the acknowledgements below.\nIf you do not agree with every statement, do not continue.'**
  String get msgImportantToEnableTheDecoyPinFeatureYou;

  /// No description provided for @msgInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get msgInstagram;

  /// No description provided for @msgInvalidCodePleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get msgInvalidCodePleaseTryAgain;

  /// No description provided for @msgLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get msgLegal;

  /// No description provided for @msgLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get msgLive;

  /// No description provided for @msgLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get msgLastName;

  /// No description provided for @msgLetSGetStartedByFillingOutThe.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started by filling out the form below.'**
  String get msgLetSGetStartedByFillingOutThe;

  /// No description provided for @msgLimitOrder.
  ///
  /// In en, this message translates to:
  /// **'Limit Order'**
  String get msgLimitOrder;

  /// No description provided for @msgLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get msgLocationServices;

  /// No description provided for @msgLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get msgLogOut;

  /// No description provided for @msgLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get msgLogIn;

  /// No description provided for @msgManageAccess.
  ///
  /// In en, this message translates to:
  /// **'MANAGE ACCESS'**
  String get msgManageAccess;

  /// No description provided for @msgMethod.
  ///
  /// In en, this message translates to:
  /// **'METHOD'**
  String get msgMethod;

  /// No description provided for @msgMustBeAtLeast4Digits.
  ///
  /// In en, this message translates to:
  /// **'MUST BE AT LEAST 4 DIGITS'**
  String get msgMustBeAtLeast4Digits;

  /// No description provided for @msgManageYourWalletPreferencesAndSession.
  ///
  /// In en, this message translates to:
  /// **'Manage your wallet preferences and session.'**
  String get msgManageYourWalletPreferencesAndSession;

  /// No description provided for @msgManualAddress.
  ///
  /// In en, this message translates to:
  /// **'Manual address'**
  String get msgManualAddress;

  /// No description provided for @msgMasterStatus.
  ///
  /// In en, this message translates to:
  /// **'Master Status:'**
  String get msgMasterStatus;

  /// No description provided for @msgMessage.
  ///
  /// In en, this message translates to:
  /// **'Message '**
  String get msgMessage;

  /// No description provided for @msgMiamiBeach.
  ///
  /// In en, this message translates to:
  /// **'Miami Beach'**
  String get msgMiamiBeach;

  /// No description provided for @msgMonitorExistingWallet.
  ///
  /// In en, this message translates to:
  /// **'Monitor Existing Wallet'**
  String get msgMonitorExistingWallet;

  /// No description provided for @msgMonitorStatus.
  ///
  /// In en, this message translates to:
  /// **'Monitor Status:'**
  String get msgMonitorStatus;

  /// No description provided for @msgMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get msgMonthly;

  /// No description provided for @msgMySubscription.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get msgMySubscription;

  /// No description provided for @msgNotQuiteTryAgain.
  ///
  /// In en, this message translates to:
  /// **'NOT QUITE - TRY AGAIN'**
  String get msgNotQuiteTryAgain;

  /// No description provided for @msgNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get msgNetwork;

  /// No description provided for @msgNetworkFee.
  ///
  /// In en, this message translates to:
  /// **'Network Fee'**
  String get msgNetworkFee;

  /// No description provided for @msgNetworkProgress.
  ///
  /// In en, this message translates to:
  /// **'Network Progress'**
  String get msgNetworkProgress;

  /// No description provided for @msgNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get msgNext;

  /// No description provided for @msgNoDecoyKeysMonitorsFoundYet.
  ///
  /// In en, this message translates to:
  /// **'No Decoy Keys monitors found yet.'**
  String get msgNoDecoyKeysMonitorsFoundYet;

  /// No description provided for @msgOpenDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Device Settings'**
  String get msgOpenDeviceSettings;

  /// No description provided for @msgOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get msgOrderDetails;

  /// No description provided for @msgPasswordUpdateFailedTryADifferentPassword.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD UPDATE FAILED - TRY A DIFFERENT PASSWORD'**
  String get msgPasswordUpdateFailedTryADifferentPassword;

  /// No description provided for @msgPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PASSWORDS DO NOT MATCH'**
  String get msgPasswordsDoNotMatch;

  /// No description provided for @msgPasswordsDoNotMatchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'PASSWORDS DO NOT MATCH - TRY AGAIN'**
  String get msgPasswordsDoNotMatchTryAgain;

  /// No description provided for @msgPhoneNumberAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER ALREADY IN USE'**
  String get msgPhoneNumberAlreadyInUse;

  /// No description provided for @msgPinMustBeAtLeast4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN MUST BE AT LEAST 4 DIGITS'**
  String get msgPinMustBeAtLeast4Digits;

  /// No description provided for @msgPinsDidNotMatchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'PINS DID NOT MATCH - TRY AGAIN'**
  String get msgPinsDidNotMatchTryAgain;

  /// No description provided for @msgPinsDoNotMatchPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'PINS DO NOT MATCH - PLEASE TRY AGAIN'**
  String get msgPinsDoNotMatchPleaseTryAgain;

  /// No description provided for @msgPleaseEnterAtLeast4Digits.
  ///
  /// In en, this message translates to:
  /// **'PLEASE ENTER AT LEAST 4 DIGITS'**
  String get msgPleaseEnterAtLeast4Digits;

  /// No description provided for @msgPleaseEnterAtLeast4DigitsToContinue.
  ///
  /// In en, this message translates to:
  /// **'PLEASE ENTER AT LEAST 4 DIGITS TO CONTINUE'**
  String get msgPleaseEnterAtLeast4DigitsToContinue;

  /// No description provided for @msgPleaseEnterAtLeastFourDigits.
  ///
  /// In en, this message translates to:
  /// **'PLEASE ENTER AT LEAST FOUR DIGITS'**
  String get msgPleaseEnterAtLeastFourDigits;

  /// No description provided for @msgProgress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get msgProgress;

  /// No description provided for @msgPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get msgPassword;

  /// No description provided for @msgPasswordMustBeAtLeast10Characters.
  ///
  /// In en, this message translates to:
  /// **'Password Must Be At Least 10 Characters'**
  String get msgPasswordMustBeAtLeast10Characters;

  /// No description provided for @msgPasteOnlyWatchOnlyPublicDataNeverPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste only watch-only public data. Never paste a seed phrase, private key, xprv, or zprv.'**
  String get msgPasteOnlyWatchOnlyPublicDataNeverPaste;

  /// No description provided for @msgPasteOrEnterWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Paste or enter wallet address'**
  String get msgPasteOrEnterWalletAddress;

  /// No description provided for @msgPayForDecoyWithBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Pay for Decoy with Bitcoin'**
  String get msgPayForDecoyWithBitcoin;

  /// No description provided for @msgPayForDecoyWithCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Pay for Decoy with Credit Card'**
  String get msgPayForDecoyWithCreditCard;

  /// No description provided for @msgPayWithBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Pay with Bitcoin'**
  String get msgPayWithBitcoin;

  /// No description provided for @msgPayWithCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card'**
  String get msgPayWithCard;

  /// No description provided for @msgPaymentSetup.
  ///
  /// In en, this message translates to:
  /// **'Payment setup'**
  String get msgPaymentSetup;

  /// No description provided for @msgPersonalContact.
  ///
  /// In en, this message translates to:
  /// **'Personal Contact'**
  String get msgPersonalContact;

  /// No description provided for @msgPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get msgPhoneNumber;

  /// No description provided for @msgPhoneNumberCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Phone number (+country code)'**
  String get msgPhoneNumberCountryCode;

  /// No description provided for @msgPlaceALimitOrder.
  ///
  /// In en, this message translates to:
  /// **'Place a limit order'**
  String get msgPlaceALimitOrder;

  /// No description provided for @msgPleaseAuthenticateToEnableBiometricUnlockForDecoy.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to enable biometric unlock for Decoy Wallet'**
  String get msgPleaseAuthenticateToEnableBiometricUnlockForDecoy;

  /// No description provided for @msgPleaseAuthenticateToUnlockYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to unlock your wallet'**
  String get msgPleaseAuthenticateToUnlockYourWallet;

  /// No description provided for @msgPrimal.
  ///
  /// In en, this message translates to:
  /// **'Primal'**
  String get msgPrimal;

  /// No description provided for @msgPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get msgPrivacy;

  /// No description provided for @msgPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get msgPrivacyPolicy;

  /// No description provided for @msgPurchaseSchedule.
  ///
  /// In en, this message translates to:
  /// **'Purchase schedule'**
  String get msgPurchaseSchedule;

  /// No description provided for @msgPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get msgPushNotifications;

  /// No description provided for @msgQuizTime.
  ///
  /// In en, this message translates to:
  /// **'QUIZ TIME!'**
  String get msgQuizTime;

  /// No description provided for @msgResetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD EMAIL SENT'**
  String get msgResetPasswordEmailSent;

  /// No description provided for @msgReceive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get msgReceive;

  /// No description provided for @msgReceivePartOfYourPaycheckDirectlyInBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Receive part of your paycheck directly in Bitcoin.'**
  String get msgReceivePartOfYourPaycheckDirectlyInBitcoin;

  /// No description provided for @msgRecipientQr.
  ///
  /// In en, this message translates to:
  /// **'Recipient QR'**
  String get msgRecipientQr;

  /// No description provided for @msgRecurringBuy.
  ///
  /// In en, this message translates to:
  /// **'Recurring Buy'**
  String get msgRecurringBuy;

  /// No description provided for @msgRedeemCode.
  ///
  /// In en, this message translates to:
  /// **'Redeem Code'**
  String get msgRedeemCode;

  /// No description provided for @msgRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get msgRefresh;

  /// No description provided for @msgResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get msgResendCode;

  /// No description provided for @msgRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get msgRetry;

  /// No description provided for @msgReturnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get msgReturnToHome;

  /// No description provided for @msgReviewDetailsBeforeBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Review details before broadcast'**
  String get msgReviewDetailsBeforeBroadcast;

  /// No description provided for @msgRumble.
  ///
  /// In en, this message translates to:
  /// **'Rumble'**
  String get msgRumble;

  /// No description provided for @msgSafetySupport.
  ///
  /// In en, this message translates to:
  /// **'SAFETY & SUPPORT'**
  String get msgSafetySupport;

  /// No description provided for @msgSetup.
  ///
  /// In en, this message translates to:
  /// **'SETUP'**
  String get msgSetup;

  /// No description provided for @msgSmsTerms.
  ///
  /// In en, this message translates to:
  /// **'SMS Terms'**
  String get msgSmsTerms;

  /// No description provided for @msgSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT TICKET'**
  String get msgSupportTicket;

  /// No description provided for @msgSaveExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get msgSaveExit;

  /// No description provided for @msgSaveGoBack.
  ///
  /// In en, this message translates to:
  /// **'Save & Go Back'**
  String get msgSaveGoBack;

  /// No description provided for @msgSaveGoHome.
  ///
  /// In en, this message translates to:
  /// **'Save & Go Home'**
  String get msgSaveGoHome;

  /// No description provided for @msgSavePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Save Phone Number'**
  String get msgSavePhoneNumber;

  /// No description provided for @msgScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get msgScan;

  /// No description provided for @msgScanOrPasteARecipientAddress.
  ///
  /// In en, this message translates to:
  /// **'Scan or paste a recipient address'**
  String get msgScanOrPasteARecipientAddress;

  /// No description provided for @msgSee.
  ///
  /// In en, this message translates to:
  /// **'See '**
  String get msgSee;

  /// No description provided for @msgSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get msgSend;

  /// No description provided for @msgSendAmount.
  ///
  /// In en, this message translates to:
  /// **'Send Amount'**
  String get msgSendAmount;

  /// No description provided for @msgSendBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Send Bitcoin'**
  String get msgSendBitcoin;

  /// No description provided for @msgSendFunds.
  ///
  /// In en, this message translates to:
  /// **'Send Funds'**
  String get msgSendFunds;

  /// No description provided for @msgSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get msgSendLink;

  /// No description provided for @msgSendMax.
  ///
  /// In en, this message translates to:
  /// **'Send Max'**
  String get msgSendMax;

  /// No description provided for @msgSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get msgSet;

  /// No description provided for @msgSetUpDecoyKeys.
  ///
  /// In en, this message translates to:
  /// **'Set Up Decoy Keys'**
  String get msgSetUpDecoyKeys;

  /// No description provided for @msgSetARecurringBuy.
  ///
  /// In en, this message translates to:
  /// **'Set a recurring buy'**
  String get msgSetARecurringBuy;

  /// No description provided for @msgSetAScheduleForAutomaticBitcoinPurchases.
  ///
  /// In en, this message translates to:
  /// **'Set a schedule for automatic Bitcoin purchases.'**
  String get msgSetAScheduleForAutomaticBitcoinPurchases;

  /// No description provided for @msgSettingUpYourDecoyKeys.
  ///
  /// In en, this message translates to:
  /// **'Setting Up Your Decoy Keys'**
  String get msgSettingUpYourDecoyKeys;

  /// No description provided for @msgSettingUpYourDecoyPin.
  ///
  /// In en, this message translates to:
  /// **'Setting Up Your Decoy PIN'**
  String get msgSettingUpYourDecoyPin;

  /// No description provided for @msgSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get msgSettings;

  /// No description provided for @msgSettingsControlCenter2.
  ///
  /// In en, this message translates to:
  /// **'Settings > Control Center'**
  String get msgSettingsControlCenter2;

  /// No description provided for @msgSignInHere.
  ///
  /// In en, this message translates to:
  /// **'Sign In here'**
  String get msgSignInHere;

  /// No description provided for @msgSignedInDevice.
  ///
  /// In en, this message translates to:
  /// **'Signed-in device'**
  String get msgSignedInDevice;

  /// No description provided for @msgSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get msgSkipForNow;

  /// No description provided for @msgSlideForAQuickEstimateOrEnterAn.
  ///
  /// In en, this message translates to:
  /// **'Slide for a quick estimate, or enter an exact amount below.'**
  String get msgSlideForAQuickEstimateOrEnterAn;

  /// No description provided for @msgSlideToSignAndSend.
  ///
  /// In en, this message translates to:
  /// **'Slide to Sign and Send'**
  String get msgSlideToSignAndSend;

  /// No description provided for @msgState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get msgState;

  /// No description provided for @msgStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get msgStatus;

  /// No description provided for @msgStatus2.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get msgStatus2;

  /// No description provided for @msgStreetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get msgStreetAddress;

  /// No description provided for @msgStripeCheckoutInYourBrowser.
  ///
  /// In en, this message translates to:
  /// **'Stripe checkout in your browser'**
  String get msgStripeCheckoutInYourBrowser;

  /// No description provided for @msgStripeWillTakeOverOn.
  ///
  /// In en, this message translates to:
  /// **'Stripe will take over on  '**
  String get msgStripeWillTakeOverOn;

  /// No description provided for @msgSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject '**
  String get msgSubject;

  /// No description provided for @msgSubmitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get msgSubmitTicket;

  /// No description provided for @msgSubscriptionRequiredToChangeValues.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required to Change Values'**
  String get msgSubscriptionRequiredToChangeValues;

  /// No description provided for @msgSupportTicketSentToDecoyTeam.
  ///
  /// In en, this message translates to:
  /// **'Support Ticket Sent to Decoy Team'**
  String get msgSupportTicketSentToDecoyTeam;

  /// No description provided for @msgSwitchValue.
  ///
  /// In en, this message translates to:
  /// **'Switch Value:'**
  String get msgSwitchValue;

  /// No description provided for @msgSyncMarket.
  ///
  /// In en, this message translates to:
  /// **'Sync market'**
  String get msgSyncMarket;

  /// No description provided for @msgSystemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status:'**
  String get msgSystemStatus;

  /// No description provided for @msgTimeToGetAccess.
  ///
  /// In en, this message translates to:
  /// **'TIME TO GET ACCESS!'**
  String get msgTimeToGetAccess;

  /// No description provided for @msgTapToOpenQrScanner.
  ///
  /// In en, this message translates to:
  /// **'Tap to open QR scanner'**
  String get msgTapToOpenQrScanner;

  /// No description provided for @msgTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get msgTerms;

  /// No description provided for @msgTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get msgTermsConditions;

  /// No description provided for @msgTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get msgTermsOfService;

  /// No description provided for @msgTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get msgTermsOfUse;

  /// No description provided for @msgThisActionIsPermanent.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent'**
  String get msgThisActionIsPermanent;

  /// No description provided for @msgThisSeedPhraseWillNotBeStoredOn.
  ///
  /// In en, this message translates to:
  /// **'This seed phrase will not be stored on this device. Write it down and keep it secure.'**
  String get msgThisSeedPhraseWillNotBeStoredOn;

  /// No description provided for @msgTitleTheProblemYouAreExperiencing.
  ///
  /// In en, this message translates to:
  /// **'Title the problem you are experiencing'**
  String get msgTitleTheProblemYouAreExperiencing;

  /// No description provided for @msgTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get msgTo;

  /// No description provided for @msgToAddress.
  ///
  /// In en, this message translates to:
  /// **'To Address'**
  String get msgToAddress;

  /// No description provided for @msgToggleOnToEnableDecoyPinToContact.
  ///
  /// In en, this message translates to:
  /// **'Toggle ON to enable DECOY PIN to contact emergency contacts'**
  String get msgToggleOnToEnableDecoyPinToContact;

  /// No description provided for @msgTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get msgTotalAmount;

  /// No description provided for @msgTransactionComplete.
  ///
  /// In en, this message translates to:
  /// **'Transaction complete'**
  String get msgTransactionComplete;

  /// No description provided for @msgTransactionInitiated.
  ///
  /// In en, this message translates to:
  /// **'Transaction initiated'**
  String get msgTransactionInitiated;

  /// No description provided for @msgTriggerDecoyKeysAlerts.
  ///
  /// In en, this message translates to:
  /// **'Trigger Decoy Keys Alerts'**
  String get msgTriggerDecoyKeysAlerts;

  /// No description provided for @msgTriggerDecoyPinAlerts.
  ///
  /// In en, this message translates to:
  /// **'Trigger Decoy PIN Alerts'**
  String get msgTriggerDecoyPinAlerts;

  /// No description provided for @msgTriggerStatus.
  ///
  /// In en, this message translates to:
  /// **'Trigger Status:'**
  String get msgTriggerStatus;

  /// No description provided for @msgTutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get msgTutorials;

  /// No description provided for @msgUsa.
  ///
  /// In en, this message translates to:
  /// **'USA'**
  String get msgUsa;

  /// No description provided for @msgUnlockDecoyWallet.
  ///
  /// In en, this message translates to:
  /// **'Unlock Decoy Wallet'**
  String get msgUnlockDecoyWallet;

  /// No description provided for @msgUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get msgUpdatePassword;

  /// No description provided for @msgUseFingerprintOrFaceRecognitionForSecureAccess.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face recognition for secure access'**
  String get msgUseFingerprintOrFaceRecognitionForSecureAccess;

  /// No description provided for @msgUseXpubForLegacy1AddressWalletsZpub.
  ///
  /// In en, this message translates to:
  /// **'Use xpub for legacy 1-address wallets, zpub for native SegWit bc1 wallets, or paste specific receive addresses.'**
  String get msgUseXpubForLegacy1AddressWalletsZpub;

  /// No description provided for @msgUseYourFingerprintOrFaceIdToQuickly.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or Face ID to quickly and securely access your account'**
  String get msgUseYourFingerprintOrFaceIdToQuickly;

  /// No description provided for @msgUseYourLocationToSupportEmergencyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Use your location to support emergency alerts'**
  String get msgUseYourLocationToSupportEmergencyAlerts;

  /// No description provided for @msgUsingADecoyPinWillTriggerEmergencyBehavior.
  ///
  /// In en, this message translates to:
  /// **'Using a Decoy PIN will trigger emergency behavior inside Decoy Wallet, including notifying contacts or emergency services.\n\nThis feature is designed for real duress situations only.'**
  String get msgUsingADecoyPinWillTriggerEmergencyBehavior;

  /// No description provided for @msgVerifyingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Verifying... Please Wait!'**
  String get msgVerifyingPleaseWait;

  /// No description provided for @msgWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get msgWallet;

  /// No description provided for @msgWalletActivityMonitor.
  ///
  /// In en, this message translates to:
  /// **'Wallet Activity Monitor'**
  String get msgWalletActivityMonitor;

  /// No description provided for @msgWalletSeedPhrasesAndPrivateKeys.
  ///
  /// In en, this message translates to:
  /// **'Wallet seed phrases and private keys'**
  String get msgWalletSeedPhrasesAndPrivateKeys;

  /// No description provided for @msgWatchOnlyWalletImportIsAvailableInEnabled.
  ///
  /// In en, this message translates to:
  /// **'Watch-only wallet import is available in enabled test builds only.'**
  String get msgWatchOnlyWalletImportIsAvailableInEnabled;

  /// No description provided for @msgWeSentA6DigitCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get msgWeSentA6DigitCodeTo;

  /// No description provided for @msgWeWillSendYouAnEmailWithA.
  ///
  /// In en, this message translates to:
  /// **'We will send you an email with a link to reset your password, please enter the email associated with your account below.'**
  String get msgWeWillSendYouAnEmailWithA;

  /// No description provided for @msgWeReHereToHelpSubmitASupport.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help! Submit a support ticket and we\'ll get back to you as soon as possible.'**
  String get msgWeReHereToHelpSubmitASupport;

  /// No description provided for @msgWeVeSentAConfirmationLinkTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a confirmation link to:'**
  String get msgWeVeSentAConfirmationLinkTo;

  /// No description provided for @msgWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get msgWebsite;

  /// No description provided for @msgWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get msgWelcomeBack;

  /// No description provided for @msgWhatWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'What will be deleted'**
  String get msgWhatWillBeDeleted;

  /// No description provided for @msgWhatWillNotBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'What will not be deleted'**
  String get msgWhatWillNotBeDeleted;

  /// No description provided for @msgWithdrawalSettings.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal settings'**
  String get msgWithdrawalSettings;

  /// No description provided for @msgWriteADetailedDescriptionOfTheProblemYou.
  ///
  /// In en, this message translates to:
  /// **'Write a detailed description of the problem you are experiencing'**
  String get msgWriteADetailedDescriptionOfTheProblemYou;

  /// No description provided for @msgYourDecoySeed.
  ///
  /// In en, this message translates to:
  /// **'YOUR DECOY SEED'**
  String get msgYourDecoySeed;

  /// No description provided for @msgYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get msgYearly;

  /// No description provided for @msgYouCanRequestANewCodeIn.
  ///
  /// In en, this message translates to:
  /// **'You can request a new code in '**
  String get msgYouCanRequestANewCodeIn;

  /// No description provided for @msgYouMayAlsoReachOutTo.
  ///
  /// In en, this message translates to:
  /// **'You may also reach out to '**
  String get msgYouMayAlsoReachOutTo;

  /// No description provided for @msgYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get msgYoutube;

  /// No description provided for @msgYourBitcoinFundsRemainSafeInYourExternal.
  ///
  /// In en, this message translates to:
  /// **'Your Bitcoin funds remain safe in your external wallet'**
  String get msgYourBitcoinFundsRemainSafeInYourExternal;

  /// No description provided for @msgYourDecoyWalletAccountAndProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Decoy Wallet account and profile'**
  String get msgYourDecoyWalletAccountAndProfile;

  /// No description provided for @msgYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Your email address...'**
  String get msgYourEmailAddress;

  /// No description provided for @msgZipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get msgZipCode;

  /// No description provided for @msgByNavigatingTo2.
  ///
  /// In en, this message translates to:
  /// **'by navigating to '**
  String get msgByNavigatingTo2;

  /// No description provided for @msgForFurtherAssistance.
  ///
  /// In en, this message translates to:
  /// **'for further assistance'**
  String get msgForFurtherAssistance;

  /// No description provided for @msgZpubXpubOrReceiveAddresses.
  ///
  /// In en, this message translates to:
  /// **'zpub, xpub, or receive addresses'**
  String get msgZpubXpubOrReceiveAddresses;

  /// No description provided for @msgZpubOrBc1qBc1p1.
  ///
  /// In en, this message translates to:
  /// **'zpub...\n\nor\nbc1q...\nbc1p...\n1...'**
  String get msgZpubOrBc1qBc1p1;

  /// No description provided for @msgItcoinWallet.
  ///
  /// In en, this message translates to:
  /// **'₿itcoin Wallet'**
  String get msgItcoinWallet;

  /// No description provided for @msgLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get msgLanguage;

  /// No description provided for @msgUseDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get msgUseDeviceLanguage;

  /// No description provided for @msgCouldNotSaveYourLanguagePleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language. Please try again.'**
  String get msgCouldNotSaveYourLanguagePleaseTryAgain;

  /// No description provided for @msgDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get msgDone;

  /// No description provided for @msg394Month.
  ///
  /// In en, this message translates to:
  /// **'\$3.94 / month'**
  String get msg394Month;

  /// No description provided for @msg3942Year.
  ///
  /// In en, this message translates to:
  /// **'\$39.42 / year'**
  String get msg3942Year;

  /// No description provided for @msg499Month.
  ///
  /// In en, this message translates to:
  /// **'\$4.99 / month'**
  String get msg499Month;

  /// No description provided for @msg4728Year.
  ///
  /// In en, this message translates to:
  /// **'\$47.28 / year'**
  String get msg4728Year;

  /// No description provided for @msg4990Year.
  ///
  /// In en, this message translates to:
  /// **'\$49.90 / year'**
  String get msg4990Year;

  /// No description provided for @msg5988Year.
  ///
  /// In en, this message translates to:
  /// **'\$59.88 / year'**
  String get msg5988Year;

  /// No description provided for @msgAmountExceedsAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT EXCEEDS AVAILABLE BALANCE'**
  String get msgAmountExceedsAvailableBalance;

  /// No description provided for @msgAccountLevelSeedWalletMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Account-level seed wallet monitoring'**
  String get msgAccountLevelSeedWalletMonitoring;

  /// No description provided for @msgActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get msgActive;

  /// No description provided for @msgAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get msgAsset;

  /// No description provided for @msgAwaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Confirmation'**
  String get msgAwaitingConfirmation;

  /// No description provided for @msgBalanceCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Balance cannot be negative.'**
  String get msgBalanceCannotBeNegative;

  /// No description provided for @msgBitcoinMainnet.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin Mainnet'**
  String get msgBitcoinMainnet;

  /// No description provided for @msgBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get msgBlock;

  /// No description provided for @msgBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get msgBroadcast;

  /// No description provided for @msgBroadcasted.
  ///
  /// In en, this message translates to:
  /// **'Broadcasted'**
  String get msgBroadcasted;

  /// No description provided for @msgBroadcasting.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting'**
  String get msgBroadcasting;

  /// No description provided for @msgBroadcastingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Broadcasting Transaction'**
  String get msgBroadcastingTransaction;

  /// No description provided for @msgBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get msgBuy;

  /// No description provided for @msgCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get msgCancel;

  /// No description provided for @msgCardPaymentsScheduled.
  ///
  /// In en, this message translates to:
  /// **'Card Payments Scheduled'**
  String get msgCardPaymentsScheduled;

  /// No description provided for @msgComplete2.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get msgComplete2;

  /// No description provided for @msgConfirmationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation Link Sent'**
  String get msgConfirmationLinkSent;

  /// No description provided for @msgConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get msgConfirmed;

  /// No description provided for @msgConfirmedOnTheBitcoinNetwork.
  ///
  /// In en, this message translates to:
  /// **'Confirmed on the Bitcoin network'**
  String get msgConfirmedOnTheBitcoinNetwork;

  /// No description provided for @msgDecoyKeys2.
  ///
  /// In en, this message translates to:
  /// **'DECOY KEYS'**
  String get msgDecoyKeys2;

  /// No description provided for @msgDecoyKeysReady.
  ///
  /// In en, this message translates to:
  /// **'DECOY KEYS READY'**
  String get msgDecoyKeysReady;

  /// No description provided for @msgDecoyKeysMonitor.
  ///
  /// In en, this message translates to:
  /// **'Decoy Keys Monitor'**
  String get msgDecoyKeysMonitor;

  /// No description provided for @msgDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get msgDenied;

  /// No description provided for @msgDepositAsset.
  ///
  /// In en, this message translates to:
  /// **'Deposit asset'**
  String get msgDepositAsset;

  /// No description provided for @msgEnter21000000BtcOrLess.
  ///
  /// In en, this message translates to:
  /// **'Enter 21,000,000 BTC or less.'**
  String get msgEnter21000000BtcOrLess;

  /// No description provided for @msgEnterAValidBtcAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid BTC amount.'**
  String get msgEnterAValidBtcAmount;

  /// No description provided for @msgEveryPayday.
  ///
  /// In en, this message translates to:
  /// **'Every payday'**
  String get msgEveryPayday;

  /// No description provided for @msgFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get msgFrequency;

  /// No description provided for @msgGenerateANewDecoySeedPhraseOrMonitor.
  ///
  /// In en, this message translates to:
  /// **'Generate a new Decoy Seed phrase or monitor watch-only wallet data you already control.'**
  String get msgGenerateANewDecoySeedPhraseOrMonitor;

  /// No description provided for @msgGenerateANewDecoySeedPhraseToMonitor.
  ///
  /// In en, this message translates to:
  /// **'Generate a new Decoy Seed phrase to monitor for outbound wallet activity.'**
  String get msgGenerateANewDecoySeedPhraseToMonitor;

  /// No description provided for @msgInMempool.
  ///
  /// In en, this message translates to:
  /// **'In Mempool'**
  String get msgInMempool;

  /// No description provided for @msgLive2.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get msgLive2;

  /// No description provided for @msgManageCardPayments.
  ///
  /// In en, this message translates to:
  /// **'Manage Card Payments'**
  String get msgManageCardPayments;

  /// No description provided for @msgMempool.
  ///
  /// In en, this message translates to:
  /// **'Mempool'**
  String get msgMempool;

  /// No description provided for @msgMostRecentDecoySeedGenerated.
  ///
  /// In en, this message translates to:
  /// **'Most Recent Decoy Seed Generated'**
  String get msgMostRecentDecoySeedGenerated;

  /// No description provided for @msgNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get msgNotConfigured;

  /// No description provided for @msgNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get msgNotSelected;

  /// No description provided for @msgNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get msgNotSent;

  /// No description provided for @msgOptedOut.
  ///
  /// In en, this message translates to:
  /// **'Opted out'**
  String get msgOptedOut;

  /// No description provided for @msgOrderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get msgOrderType;

  /// No description provided for @msgPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get msgPaste;

  /// No description provided for @msgPasteAZpubXpubOrOneOrMore.
  ///
  /// In en, this message translates to:
  /// **'Paste a zpub, xpub, or one or more Bitcoin receive addresses.'**
  String get msgPasteAZpubXpubOrOneOrMore;

  /// No description provided for @msgPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get msgPaymentMethod;

  /// No description provided for @msgPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get msgPending;

  /// No description provided for @msgPleaseSignInAgainToManageDecoyKeys.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to manage Decoy Keys.'**
  String get msgPleaseSignInAgainToManageDecoyKeys;

  /// No description provided for @msgPleaseSignInAgainToSaveMonitorChanges.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to save monitor changes.'**
  String get msgPleaseSignInAgainToSaveMonitorChanges;

  /// No description provided for @msgReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get msgReady;

  /// No description provided for @msgReceiveAddressMonitor.
  ///
  /// In en, this message translates to:
  /// **'Receive Address Monitor'**
  String get msgReceiveAddressMonitor;

  /// No description provided for @msgRelayingTransactionToBitcoinPeers.
  ///
  /// In en, this message translates to:
  /// **'Relaying transaction to Bitcoin peers'**
  String get msgRelayingTransactionToBitcoinPeers;

  /// No description provided for @msgRenewBitcoinPayments.
  ///
  /// In en, this message translates to:
  /// **'Renew Bitcoin Payments'**
  String get msgRenewBitcoinPayments;

  /// No description provided for @msgResendConfirmationLink.
  ///
  /// In en, this message translates to:
  /// **'Resend Confirmation Link'**
  String get msgResendConfirmationLink;

  /// No description provided for @msgSeenByPeersAndWaitingForTheNext.
  ///
  /// In en, this message translates to:
  /// **'Seen by peers and waiting for the next block'**
  String get msgSeenByPeersAndWaitingForTheNext;

  /// No description provided for @msgSendConfirmationLink.
  ///
  /// In en, this message translates to:
  /// **'Send Confirmation Link'**
  String get msgSendConfirmationLink;

  /// No description provided for @msgSettlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get msgSettlement;

  /// No description provided for @msgSigning.
  ///
  /// In en, this message translates to:
  /// **'Signing'**
  String get msgSigning;

  /// No description provided for @msgSigningAndRelayingToBitcoinPeers.
  ///
  /// In en, this message translates to:
  /// **'Signing and relaying to Bitcoin peers'**
  String get msgSigningAndRelayingToBitcoinPeers;

  /// No description provided for @msgStackMoreDays.
  ///
  /// In en, this message translates to:
  /// **'Stack More Days'**
  String get msgStackMoreDays;

  /// No description provided for @msgSwitchToBitcoinPayments.
  ///
  /// In en, this message translates to:
  /// **'Switch to Bitcoin Payments'**
  String get msgSwitchToBitcoinPayments;

  /// No description provided for @msgSwitchToCardPayments.
  ///
  /// In en, this message translates to:
  /// **'Switch to Card Payments'**
  String get msgSwitchToCardPayments;

  /// No description provided for @msgSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get msgSyncing;

  /// No description provided for @msgThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get msgThisDevice;

  /// No description provided for @msgThisWalletOrReceiveAddressIsAlreadyBeing.
  ///
  /// In en, this message translates to:
  /// **'This wallet or receive address is already being monitored.'**
  String get msgThisWalletOrReceiveAddressIsAlreadyBeing;

  /// No description provided for @msgTransactionBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Transaction Broadcast'**
  String get msgTransactionBroadcast;

  /// No description provided for @msgTransactionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Transaction Confirmed'**
  String get msgTransactionConfirmed;

  /// No description provided for @msgTransactionRelayedAndPendingInclusion.
  ///
  /// In en, this message translates to:
  /// **'Transaction relayed and pending inclusion'**
  String get msgTransactionRelayedAndPendingInclusion;

  /// No description provided for @msgTxId.
  ///
  /// In en, this message translates to:
  /// **'Tx ID'**
  String get msgTxId;

  /// No description provided for @msgUsdBalance.
  ///
  /// In en, this message translates to:
  /// **'USD balance'**
  String get msgUsdBalance;

  /// No description provided for @msgUsdEstimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'USD estimate unavailable'**
  String get msgUsdEstimateUnavailable;

  /// No description provided for @msgUnableToCheckWhetherThisWalletIsAlready.
  ///
  /// In en, this message translates to:
  /// **'Unable to check whether this wallet is already monitored. Please try again.'**
  String get msgUnableToCheckWhetherThisWalletIsAlready;

  /// No description provided for @msgUnableToDeleteThisMonitor.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete this monitor.'**
  String get msgUnableToDeleteThisMonitor;

  /// No description provided for @msgUnableToLoadDecoyKeysMonitors.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Decoy Keys monitors.'**
  String get msgUnableToLoadDecoyKeysMonitors;

  /// No description provided for @msgUnableToSaveDecoyKeysMonitorChanges.
  ///
  /// In en, this message translates to:
  /// **'Unable to save Decoy Keys monitor changes.'**
  String get msgUnableToSaveDecoyKeysMonitorChanges;

  /// No description provided for @msgUnableToUpdateDecoyKeysMonitors.
  ///
  /// In en, this message translates to:
  /// **'Unable to update Decoy Keys monitors.'**
  String get msgUnableToUpdateDecoyKeysMonitors;

  /// No description provided for @msgUnableToUpdateThisMonitor.
  ///
  /// In en, this message translates to:
  /// **'Unable to update this monitor.'**
  String get msgUnableToUpdateThisMonitor;

  /// No description provided for @msgUnableToValidateThisWatchOnlyWalletData.
  ///
  /// In en, this message translates to:
  /// **'Unable to validate this watch-only wallet data.'**
  String get msgUnableToValidateThisWatchOnlyWalletData;

  /// No description provided for @msgWaitingForNetworkConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Waiting for network confirmations'**
  String get msgWaitingForNetworkConfirmations;

  /// No description provided for @msgWalletActivityMonitor2.
  ///
  /// In en, this message translates to:
  /// **'Wallet activity monitor'**
  String get msgWalletActivityMonitor2;

  /// No description provided for @msgXpubMonitor.
  ///
  /// In en, this message translates to:
  /// **'XPub Monitor'**
  String get msgXpubMonitor;

  /// No description provided for @msgZpubMonitor.
  ///
  /// In en, this message translates to:
  /// **'ZPub Monitor'**
  String get msgZpubMonitor;

  /// No description provided for @msgWallet2.
  ///
  /// In en, this message translates to:
  /// **'WALLET'**
  String get msgWallet2;

  /// No description provided for @msgSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get msgSecurity;

  /// No description provided for @receiveAddressCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 receive address} other{{count} receive addresses}}'**
  String receiveAddressCount(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @emergencyContactsHeadingFirstLine.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY'**
  String get emergencyContactsHeadingFirstLine;

  /// No description provided for @emergencyContactsHeadingSecondLine.
  ///
  /// In en, this message translates to:
  /// **'CONTACTS'**
  String get emergencyContactsHeadingSecondLine;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'he',
        'hi',
        'id',
        'it',
        'ja',
        'ko',
        'nl',
        'pl',
        'pt',
        'ru',
        'tr',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
