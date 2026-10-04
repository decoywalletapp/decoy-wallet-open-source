// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get msgSaveBalanceToAccount =>
      'Dieses Guthaben in meinem Konto speichern';

  @override
  String msgSaveBalanceToAccountPrompt(String amount) {
    return '$amount BTC in diesem Konto speichern und das Guthaben zwischen Geräten synchronisieren? Ein bereits gespeichertes Kontoguthaben bleibt erhalten.';
  }

  @override
  String get msgAlreadyConfirmedYourEmail =>
      'E-Mail-Adresse bereits bestätigt?';

  @override
  String get msgCameraAccessRequiredForQrScan =>
      'Zum Scannen von QR-Codes ist der Kamerazugriff erforderlich. Du kannst ihn in den Geräteeinstellungen erlauben.';

  @override
  String get msgCouldNotOpenQrScanner =>
      'Der QR-Scanner konnte nicht geöffnet werden. Versuche es erneut oder füge den Text ein.';

  @override
  String get msgComplete => ' % abgeschlossen';

  @override
  String get msgControl => ' Steuer-';

  @override
  String get msgDaysLeft => ' TAGE ÜBRIG';

  @override
  String get msgSettingsControlCenter => ' Einstellungen > Steuerzentrale';

  @override
  String get msgSignUpHere => ' Hier registrieren';

  @override
  String get msgAnd => ' und ';

  @override
  String get msgByNavigatingTo => ' unter ';

  @override
  String get msgOutlinedByDecoyWalletLlc =>
      ' (festgelegt von DECOY WALLET LLC)';

  @override
  String get msgSeconds => ' Sekunden';

  @override
  String get msg0TradedThisMonth => '\$0 diesen Monat gehandelt';

  @override
  String get msg1000ToNextLevel => '\$1,000 bis zur nächsten Stufe';

  @override
  String get msg5551234567Or447700900123 =>
      '(555) 123-4567 oder +44 7700 900123';

  @override
  String get msg15551234567Or33612 => '+1 555 123 4567 oder +33 6 12 34 56 78';

  @override
  String get msgEnterItBelowToVerifyYourPhoneNumber =>
      '. Gib ihn unten ein, um deine Telefonnummer zu bestätigen.';

  @override
  String get msg0Btc => '0 BTC';

  @override
  String get msg10kBtc => '10K BTC';

  @override
  String get msg123OceanDr => '123 Ocean Dr.';

  @override
  String get msg2MonthsFree => '2 Monate kostenlos';

  @override
  String get msg911Trigger => '911-Auslöser';

  @override
  String get msgAccount => 'KONTO';

  @override
  String get msgActivated => 'AKTIVIERT';

  @override
  String get msgArmToActivelyMonitorOutboundTransactions =>
      'SCHARFSCHALTEN, UM AUSGEHENDE TRANSAKTIONEN AKTIV ZU ÜBERWACHEN';

  @override
  String get msgAcceptDecoySeedPhrase =>
      'Tarn-Wiederherstellungsphrase akzeptieren';

  @override
  String get msgAccountSubscriptionStatus => 'Abonnementstatus des Kontos:  ';

  @override
  String get msgAccountSubscriptionAccessAndActiveStripeBilling =>
      'Abonnementzugang des Kontos und aktive Stripe-Abrechnung';

  @override
  String get msgAcknowledgements => 'Bestätigungen';

  @override
  String get msgAddYourPhoneNumber => 'Telefonnummer hinzufügen';

  @override
  String get msgAddAWatchOnlyWalletKeyOrSpecific =>
      'Füge einen öffentlichen Schlüssel einer Wallet mit reinem Lesezugriff oder bestimmte Empfangsadressen hinzu, um ausgehende Aktivitäten zu überwachen.';

  @override
  String get msgAdjustBalance => 'Guthaben anpassen';

  @override
  String get msgAdvanced => 'Erweitert';

  @override
  String get msgAdvancedMonitorControls =>
      'Erweiterte Überwachungseinstellungen';

  @override
  String get msgAgreements => 'Vereinbarungen';

  @override
  String get msgAllowSubscriptionAlertsDirectlyToYourDevice =>
      'Abonnementhinweise direkt auf deinem Gerät erlauben';

  @override
  String get msgAllowYourLocationToBeIncludedAutomaticallyDuring =>
      'Erlaube, dass dein Standort bei einem Notfall automatisch übermittelt wird, damit Vertrauenskontakte und Einsatzkräfte schneller handeln können. Dein Standort wird niemals im Hintergrund verfolgt und nur abgerufen, wenn ein Notfall ausgelöst wird.';

  @override
  String get msgAlreadyHaveAnAccount => 'Du hast bereits ein Konto? ';

  @override
  String get msgAmount => 'Betrag';

  @override
  String get msgApartmentUnitOptional => 'Wohnung/Einheit (optional)';

  @override
  String get msgAppLock => 'App-Sperre';

  @override
  String get msgAppPreferencesAndConfigurations =>
      'App-Einstellungen und Konfigurationen';

  @override
  String get msgApt4b => 'Whg. 4B';

  @override
  String get msgAutoWithdraw => 'Automatisch auszahlen';

  @override
  String get msgAutoWithdrawBitcoin => 'Bitcoin automatisch auszahlen';

  @override
  String get msgAutomaticallySendPurchasedBitcoinToYourWallet =>
      'Gekaufte Bitcoin automatisch an deine Wallet senden.';

  @override
  String get msgAwaitingConfirmations => 'Warten auf Bestätigungen';

  @override
  String get msgBtc => 'BTC';

  @override
  String get msgBtcUsd => 'BTC/USD';

  @override
  String get msgBtcpayInvoiceInYourBrowser =>
      'BTCPay-Rechnung in deinem Browser';

  @override
  String get msgBiometricAuthentication => 'Biometrische Authentifizierung';

  @override
  String get msgBiometricVerification => 'Biometrische Überprüfung';

  @override
  String get msgBitcoin => 'Bitcoin';

  @override
  String get msgBitcoinBalance => 'Bitcoin-Guthaben';

  @override
  String get msgBitcoinPay => 'Bitcoin-Zahlung';

  @override
  String get msgBitcoinAddressOrPaymentUri =>
      'Bitcoin-Adresse oder Zahlungs-URI';

  @override
  String get msgBitcoinBalanceUpdated => 'Bitcoin-Guthaben aktualisiert.';

  @override
  String get msgBitcoinPaymentConfirmingFullProtectionActivatesAfterConfirmation =>
      'Bitcoin-Zahlung wird bestätigt. Der volle Schutz wird nach der Bestätigung aktiviert.';

  @override
  String get msgBroadcastedToNetwork => 'An das Netzwerk übermittelt';

  @override
  String get msgByContinuingYouAgreeToReceiveAutomatedText =>
      'Wenn du fortfährst, stimmst du dem Empfang automatisierter SMS von Decoy Wallet zu deinem Konto, Sicherheitswarnungen, dem Status deiner Notfallkontakte, Abonnementerinnerungen und Wallet-Warnungen zu.\nDie Nachrichtenhäufigkeit variiert. Es können SMS- und Datengebühren anfallen.\nAntworte mit STOP, um dich abzumelden. Antworte mit HELP, um Hilfe zu erhalten.';

  @override
  String get msgByCreatingADecoyWalletYouAuthorizeDecoy =>
      'Mit der Erstellung einer Decoy Wallet ermächtigst du Decoy Wallet, einmalige, von dir veranlasste Notfallwarnungen an deine ausgewählten Kontakte zu senden, wenn du ein Notfallereignis auslöst.';

  @override
  String get msgCannotBeTheSameAsDecoyPin =>
      'DARF NICHT MIT DER TARN-PIN ÜBEREINSTIMMEN';

  @override
  String get msgChooseAccess => 'ZUGANG WÄHLEN';

  @override
  String get msgComingSoon => 'BALD VERFÜGBAR !!!';

  @override
  String get msgContacts => 'KONTAKTE';

  @override
  String get msgCancelSubscription => 'Abonnement kündigen';

  @override
  String get msgCenter => 'zentrale';

  @override
  String get msgCenter2 => 'zentrale ';

  @override
  String get msgChangeAccountEntryPin => 'Konto-Zugangs-PIN ändern';

  @override
  String get msgChangeTheseSettingsAnytimeInThe =>
      'Ändere diese Einstellungen jederzeit in der ';

  @override
  String get msgCheckYourEmail => 'Prüfe deine E-Mails';

  @override
  String get msgChooseFromContacts => 'Aus Kontakten auswählen';

  @override
  String get msgChooseATargetPriceForYourNextBitcoin =>
      'Wähle einen Zielpreis für deinen nächsten Bitcoin-Kauf.';

  @override
  String get msgChooseWord => 'Wähle Wort ';

  @override
  String get msgCity => 'Stadt';

  @override
  String get msgClickTheLinkInTheEmailToConfirm =>
      'Klicke auf den Link in der E-Mail, um dein Konto zu bestätigen. Prüfe deinen Spamordner, falls du die E-Mail nicht findest.';

  @override
  String get msgCompleteTheRequiredDetailsToContinue =>
      'Fülle die erforderlichen Angaben aus, um fortzufahren.';

  @override
  String get msgConfigureBitcoinBalance => 'Bitcoin-Guthaben konfigurieren';

  @override
  String get msgConfirm => 'Bestätigen';

  @override
  String get msgConfirmDecoyPin => 'TARN-PIN bestätigen';

  @override
  String get msgConfirmPin => 'PIN bestätigen';

  @override
  String get msgConfirmPassword => 'Passwort bestätigen';

  @override
  String get msgConfirmTransaction => 'Transaktion bestätigen';

  @override
  String get msgConfirmNewPin => 'Neue PIN bestätigen';

  @override
  String get msgConfirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get msgConfirmations => 'Bestätigungen';

  @override
  String get msgContact1 => 'Kontakt 1';

  @override
  String get msgContact2 => 'Kontakt 2';

  @override
  String get msgContact3 => 'Kontakt 3';

  @override
  String get msgContact4 => 'Kontakt 4';

  @override
  String get msgContact5 => 'Kontakt 5';

  @override
  String get msgContactUs => 'Kontaktiere uns';

  @override
  String get msgContinue => 'Weiter';

  @override
  String get msgControl2 => 'Steuer-';

  @override
  String get msgControlCenter => 'Steuerzentrale';

  @override
  String get msgCouldNotOpenContactsEnterContactManually =>
      'Kontakte konnten nicht geöffnet werden. Gib den Kontakt manuell ein.';

  @override
  String get msgCountry => 'Land';

  @override
  String get msgCreateAccount => 'Konto erstellen';

  @override
  String get msgCreateEmergencyContacts => 'Notfallkontakte anlegen';

  @override
  String get msgCreateYourPinToAccessYourDashboard =>
      'Erstelle deine PIN für den Zugriff auf deine Übersicht';

  @override
  String get msgCreateADecoyPinForEmergencyServices =>
      'TARN-PIN für Notfalldienste erstellen';

  @override
  String get msgCreateAnAccount => 'Konto erstellen';

  @override
  String get msgCurrency => 'Währung';

  @override
  String get msgCurrentlyDisabledInDeviceSettings =>
      'Derzeit in den Geräteeinstellungen deaktiviert !!!';

  @override
  String get msgDeactivated => 'DEAKTIVIERT';

  @override
  String get msgDecoyEmergency => 'DECOY-NOTFALL';

  @override
  String get msgDecoyPinCannotBeTheSameAsAccount =>
      'DIE TARN-PIN DARF NICHT MIT DER KONTO-ZUGANGS-PIN ÜBEREINSTIMMEN';

  @override
  String get msgDecoySeed => 'TARN-WIEDERHERSTELLUNGSPHRASE';

  @override
  String get msgDecoyWalletBalance => 'GUTHABEN DER TARN-WALLET';

  @override
  String get msgDisable => 'DEAKTIVIEREN';

  @override
  String get msgDecoyContacts => 'Decoy-Kontakte';

  @override
  String get msgDecoyKeys => 'Tarnschlüssel';

  @override
  String get msgDecoyKeysTriggers => 'Tarnschlüssel-Auslöser';

  @override
  String get msgDecoyPin => 'Tarn-PIN';

  @override
  String get msgDecoyPinTriggers => 'Tarn-PIN-Auslöser';

  @override
  String get msgDecoyWalletUsesNotificationsForSubscriptionAlertsDirectly =>
      'Decoy Wallet verwendet Benachrichtigungen für Abonnementhinweise direkt auf deinem Gerät';

  @override
  String get msgDelete => 'Löschen';

  @override
  String get msgDeleteUserAccount => 'Benutzerkonto löschen';

  @override
  String get msgDeleteMyAccount => 'Mein Konto löschen';

  @override
  String get msgDeletingYourDecoyWalletAccountWillPermanentlyRemove =>
      'Wenn du dein Decoy Wallet-Konto löschst, werden dein Konto, deine Notfallkontakte, deine Einstellungen zur Weiterleitung von Warnungen und sämtliche App-Konfigurationen dauerhaft entfernt. Ein mit diesem Konto verknüpftes aktives Stripe-Abonnement wird zuerst gekündigt. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get msgDidnTReceiveTheCode => 'Code nicht erhalten?';

  @override
  String get msgDonTHaveAnAccount => 'Du hast noch kein Konto? ';

  @override
  String get msgEmergency => 'NOTFALL';

  @override
  String get msgEnable => 'AKTIVIEREN';

  @override
  String get msgEnterPin => 'PIN EINGEBEN';

  @override
  String get msgEnterValidPhoneNumber => 'GÜLTIGE TELEFONNUMMER EINGEBEN';

  @override
  String get msgError001PleaseScreenshotContactDecoySupport =>
      'FEHLER #001 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError002PleaseScreenshotContactDecoySupport =>
      'FEHLER #002 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError003PleaseScreenshotContactDecoySupport =>
      'FEHLER #003 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError004PleaseScreenshotContactDecoySupport =>
      'FEHLER #004 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError005PleaseScreenshotContactDecoySupport =>
      'FEHLER #005 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError006PleaseScreenshotContactDecoySupport =>
      'FEHLER #006 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError008PleaseScreenshotContactDecoySupport =>
      'FEHLER #008 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError009PleaseScreenshotContactDecoySupport =>
      'FEHLER #009 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError010PleaseScreenshotContactDecoySupport =>
      'FEHLER #010 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError011PleaseScreenshotContactDecoySupport =>
      'FEHLER #011 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError012PleaseScreenshotContactDecoySupport =>
      'FEHLER #012 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError013PleaseScreenshotContactDecoySupport =>
      'FEHLER #013 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError014PleaseScreenshotContactDecoySupport =>
      'FEHLER #014 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError015PleaseScreenshotContactDecoySupport =>
      'FEHLER #015 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError016PleaseScreenshotContactDecoySupport =>
      'FEHLER #016 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError020PleaseScreenshotContactDecoySupport =>
      'FEHLER #020 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError021PleaseScreenshotContactDecoySupport =>
      'FEHLER #021 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError024PleaseScreenshotContactDecoySupport =>
      'FEHLER #024 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError025PleaseScreenshotContactDecoySupport =>
      'FEHLER #025 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError029PleaseScreenshotContactDecoySupport =>
      'FEHLER #029 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgError030PleaseScreenshotContactDecoySupport =>
      'FEHLER #030 - BITTE BILDSCHIRMFOTO ERSTELLEN UND DECOY-KUNDENDIENST KONTAKTIEREN';

  @override
  String get msgEta => 'Voraussichtliche Dauer';

  @override
  String get msgEmail => 'E-Mail';

  @override
  String get msgEmailRequired => 'E-Mail erforderlich!';

  @override
  String get msgEmergencyContacts => 'Notfallkontakte';

  @override
  String get msgEmergencyContactsTrigger => 'Notfallkontakt-Auslöser';

  @override
  String get msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications =>
      'Notfallwarnungen, die Überwachung von Wallets und Benachrichtigungen an Notfallkontakte erfordern ein aktives kostenpflichtiges Abonnement.';

  @override
  String get msgEmergencyContactsAndAlertSettings =>
      'Notfallkontakte und Warnungseinstellungen';

  @override
  String get msgEmergencyContactsReceiveAlertsOnlyBecauseYouVoluntarily =>
      'Notfallkontakte erhalten Warnungen nur, weil du ihre Telefonnummer freiwillig angibst.\n\nInformationen können wie in der Datenschutzerklärung beschrieben an Notfalldienste oder Dritte weitergegeben werden.';

  @override
  String get msgEnableBiometricAuthentication =>
      'Biometrische Authentifizierung aktivieren';

  @override
  String get msgEnableCurrentLocation => 'Aktuellen Standort aktivieren';

  @override
  String get msgEnableLocationServices => 'Ortungsdienste\naktivieren';

  @override
  String get msgEnableLocationServices2 => 'Ortungsdienste aktivieren';

  @override
  String get msgEnablePushNotifications =>
      'Push-Benachrichtigungen\naktivieren';

  @override
  String get msgEnablePushNotifications2 =>
      'Push-Benachrichtigungen aktivieren';

  @override
  String get msgEnter => 'Eingeben';

  @override
  String get msgEnterCurrentAccountEntryPin =>
      'Aktuelle Konto-Zugangs-PIN eingeben';

  @override
  String get msgEnterManually => 'Manuell eingeben';

  @override
  String get msgEnterVerificationCode => 'Bestätigungscode eingeben';

  @override
  String get msgEnterA48DigitDecoyPin =>
      'Gib eine TARN-PIN mit 4 - 8 Ziffern ein ';

  @override
  String get msgEnterA48DigitPinToSecure =>
      'Gib eine PIN mit 4 - 8 Ziffern ein, um dein Konto zu sichern';

  @override
  String get msgEnterANewPinToAccessYourAccount =>
      'Gib eine neue PIN für den Zugriff auf dein Konto ein';

  @override
  String get msgEnterAnyValueFrom0To21000 =>
      'Gib einen beliebigen Wert von 0 bis 21.000.000 BTC ein';

  @override
  String get msgEnterEmail => 'E-Mail eingeben';

  @override
  String get msgEnterFirstName => 'Vorname eingeben';

  @override
  String get msgEnterLastName => 'Nachname eingeben';

  @override
  String get msgEnterNewPassword => 'Neues Passwort eingeben';

  @override
  String get msgEnterTheAmountYouWantToSend =>
      'Gib den Betrag ein, den du senden möchtest';

  @override
  String get msgEnterTheCurrentPinYouUseToAccess =>
      'Gib die aktuelle PIN ein, mit der du auf dein Konto zugreifst';

  @override
  String get msgEnterTheSame48DigitsToConfirm =>
      'Gib dieselben 4 - 8 Ziffern ein, um deine TARN-PIN zu bestätigen';

  @override
  String get msgEnterTheSame48DigitsToConfirm2 =>
      'Gib dieselben 4 - 8 Ziffern ein, um deine Zugangs-PIN zu bestätigen';

  @override
  String get msgEnterYourEmail => 'Gib deine E-Mail-Adresse ein...';

  @override
  String get msgEnterYourEventCodeInYourBrowser =>
      'Gib deinen Ereigniscode in deinem Browser ein';

  @override
  String get msgExactBitcoinAmount => 'Genauer Bitcoin-Betrag';

  @override
  String get msgFl => 'FL';

  @override
  String get msgFollowDecoyWallet => 'DECOY WALLET FOLGEN';

  @override
  String get msgFirstName => 'Vorname';

  @override
  String get msgFixTheMoneyFixTheWorld =>
      'Verbessere das Geld, verbessere die Welt.';

  @override
  String get msgFlexibleAccess => 'Flexibler Zugang';

  @override
  String get msgForgotPassword => 'Passwort vergessen';

  @override
  String get msgForgotPassword2 => 'Passwort vergessen?';

  @override
  String get msgGenerated => 'ERSTELLT';

  @override
  String get msgGenerateSeedPhrase => 'Wiederherstellungsphrase erstellen';

  @override
  String get msgGetPaidInBitcoin => 'In Bitcoin bezahlt werden';

  @override
  String get msgHomeAddress => 'Wohnanschrift';

  @override
  String get msgHowToChangeAccountEntryPin =>
      'So änderst du die Konto-Zugangs-PIN';

  @override
  String get msgHowToChangeDecoyKeys => 'So änderst du Tarnschlüssel';

  @override
  String get msgHowToChangeDecoyPin => 'So änderst du die Tarn-PIN';

  @override
  String get msgHowToChangePhoneNumber => 'So änderst du die Telefonnummer';

  @override
  String get msgHowToChangeYourEmail => 'So änderst du deine E-Mail-Adresse';

  @override
  String get msgHowToDeleteUserAccount => 'So löschst du das Benutzerkonto';

  @override
  String get msgHowToEnterContactInformation => 'So gibst du Kontaktdaten ein';

  @override
  String get msgHowToManageControlCenter =>
      'So verwaltest du die Steuerzentrale';

  @override
  String get msgIAgreeToThe => 'Ich stimme Folgendem zu: ';

  @override
  String get msgIUnderstandDecoyPinAlertsRelyOnMy =>
      'Ich verstehe, dass Tarn-PIN-Warnungen von meinen Geräteberechtigungen, meiner Netzwerkverbindung und den gespeicherten Warnungseinstellungen abhängen und dass ich dafür verantwortlich bin, diese Einstellungen einsatzbereit und aktuell zu halten.';

  @override
  String get msgIUnderstandDecoySeedAlertsAreDesignedFor =>
      'Ich verstehe, dass Warnungen zur Tarn-Wiederherstellungsphrase für Blockchain-Aktivitäten meiner scharfgeschalteten Tarn-Wallet vorgesehen sind und dass ich dafür verantwortlich bin, die zugehörigen Warnungseinstellungen einsatzbereit und aktuell zu halten.';

  @override
  String get msgIUnderstandThatDecoyWalletDoesNotHold =>
      'Ich verstehe, dass Decoy Wallet meine Gelder weder verwahrt noch schützt, Verluste nicht verhindern kann und dass ich für alle Folgen der Nutzung oder des Missbrauchs dieser Funktion voll verantwortlich bin.';

  @override
  String get msgIUnderstandThatEnteringMyDecoyPinWill =>
      'Ich verstehe, dass die Eingabe meiner Tarn-PIN einen Notfallauslöser aktiviert und meine Notfallkontakte, Dienste Dritter oder Behörden für öffentliche Sicherheit benachrichtigen kann.';

  @override
  String get msgIUnderstandThatUsingMyDecoyWalletMay =>
      'Ich verstehe, dass die Nutzung meiner Decoy Wallet Notfallwarnungen an meine Kontakte, Dienste Dritter oder Behörden für öffentliche Sicherheit auslösen kann.';

  @override
  String get msgIUnderstandThisActionIsPermanentAndCannot =>
      'Ich verstehe, dass diese Aktion dauerhaft ist und nicht rückgängig gemacht werden kann';

  @override
  String get msgIUnderstandThisFeatureIsOnlyForReal =>
      'Ich verstehe, dass diese Funktion nur für echte Notfallsituationen bestimmt ist und dass ich für alle durch Missbrauch verursachten Fehlalarme, Gebühren oder Folgen verantwortlich bin.';

  @override
  String get msgInactive => 'INAKTIV';

  @override
  String get msgIncorrectPin => 'FALSCHE PIN';

  @override
  String get msgInvalidLogin => 'UNGÜLTIGE ANMELDEDATEN';

  @override
  String get msgInvalidPasswordMustBeAtLeast10Characters =>
      'UNGÜLTIGES PASSWORT - MINDESTENS 10 ZEICHEN ERFORDERLICH';

  @override
  String get msgInvalidPhoneNumber => 'UNGÜLTIGE TELEFONNUMMER';

  @override
  String get msgInvalidPinTryAgain => 'UNGÜLTIGE PIN - ERNEUT VERSUCHEN';

  @override
  String get msgImportantToEnableTheDecoyPinFeatureYou =>
      'Wichtig: Um die Tarn-PIN-Funktion zu aktivieren, musst du alle folgenden Erklärungen bestätigen.\nFahre nicht fort, wenn du nicht jeder Aussage zustimmst.';

  @override
  String get msgInstagram => 'Instagram';

  @override
  String get msgInvalidCodePleaseTryAgain =>
      'Ungültiger Code. Bitte versuche es erneut.';

  @override
  String get msgLegal => 'RECHTLICHES';

  @override
  String get msgLive => 'IN ECHTZEIT';

  @override
  String get msgLastName => 'Nachname';

  @override
  String get msgLetSGetStartedByFillingOutThe =>
      'Fülle zunächst das folgende Formular aus.';

  @override
  String get msgLimitOrder => 'Limitauftrag';

  @override
  String get msgLocationServices => 'Ortungsdienste';

  @override
  String get msgLogOut => 'Abmelden';

  @override
  String get msgLogIn => 'Anmelden';

  @override
  String get msgManageAccess => 'ZUGANG VERWALTEN';

  @override
  String get msgMethod => 'METHODE';

  @override
  String get msgMustBeAtLeast4Digits => 'MUSS MINDESTENS 4 ZIFFERN ENTHALTEN';

  @override
  String get msgManageYourWalletPreferencesAndSession =>
      'Verwalte die Einstellungen deiner Wallet und deine Sitzung.';

  @override
  String get msgManualAddress => 'Manuelle Adresse';

  @override
  String get msgMasterStatus => 'Gesamtstatus:';

  @override
  String get msgMessage => 'Nachricht ';

  @override
  String get msgMiamiBeach => 'Miami Beach';

  @override
  String get msgMonitorExistingWallet => 'Bestehende Wallet überwachen';

  @override
  String get msgMonitorStatus => 'Überwachungsstatus:';

  @override
  String get msgMonthly => 'Monatlich';

  @override
  String get msgMySubscription => 'Mein Abonnement';

  @override
  String get msgNotQuiteTryAgain => 'NICHT GANZ - ERNEUT VERSUCHEN';

  @override
  String get msgNetwork => 'Netzwerk';

  @override
  String get msgNetworkFee => 'Netzwerkgebühr';

  @override
  String get msgNetworkProgress => 'Netzwerkfortschritt';

  @override
  String get msgNext => 'Weiter';

  @override
  String get msgNoDecoyKeysMonitorsFoundYet =>
      'Noch keine Tarnschlüssel-Überwachungen gefunden.';

  @override
  String get msgOpenDeviceSettings => 'Geräteeinstellungen öffnen';

  @override
  String get msgOrderDetails => 'Auftragsdetails';

  @override
  String get msgPasswordUpdateFailedTryADifferentPassword =>
      'PASSWORTÄNDERUNG FEHLGESCHLAGEN - ANDERES PASSWORT VERSUCHEN';

  @override
  String get msgPasswordsDoNotMatch => 'PASSWÖRTER STIMMEN NICHT ÜBEREIN';

  @override
  String get msgPasswordsDoNotMatchTryAgain =>
      'PASSWÖRTER STIMMEN NICHT ÜBEREIN - ERNEUT VERSUCHEN';

  @override
  String get msgPhoneNumberAlreadyInUse => 'TELEFONNUMMER BEREITS VERGEBEN';

  @override
  String get msgPinMustBeAtLeast4Digits =>
      'DIE PIN MUSS MINDESTENS 4 ZIFFERN ENTHALTEN';

  @override
  String get msgPinsDidNotMatchTryAgain =>
      'PINS STIMMEN NICHT ÜBEREIN - ERNEUT VERSUCHEN';

  @override
  String get msgPinsDoNotMatchPleaseTryAgain =>
      'PINS STIMMEN NICHT ÜBEREIN - BITTE ERNEUT VERSUCHEN';

  @override
  String get msgPleaseEnterAtLeast4Digits =>
      'BITTE MINDESTENS 4 ZIFFERN EINGEBEN';

  @override
  String get msgPleaseEnterAtLeast4DigitsToContinue =>
      'BITTE MINDESTENS 4 ZIFFERN EINGEBEN, UM FORTZUFAHREN';

  @override
  String get msgPleaseEnterAtLeastFourDigits =>
      'BITTE MINDESTENS VIER ZIFFERN EINGEBEN';

  @override
  String get msgProgress => 'FORTSCHRITT';

  @override
  String get msgPassword => 'Passwort';

  @override
  String get msgPasswordMustBeAtLeast10Characters =>
      'Das Passwort muss mindestens 10 Zeichen enthalten';

  @override
  String get msgPasteOnlyWatchOnlyPublicDataNeverPaste =>
      'Füge nur öffentliche Daten für reinen Lesezugriff ein. Füge niemals eine Wiederherstellungsphrase, einen privaten Schlüssel, xprv oder zprv ein.';

  @override
  String get msgPasteOrEnterWalletAddress =>
      'Wallet-Adresse einfügen oder eingeben';

  @override
  String get msgPayForDecoyWithBitcoin => 'Decoy mit Bitcoin bezahlen';

  @override
  String get msgPayForDecoyWithCreditCard => 'Decoy mit Kreditkarte bezahlen';

  @override
  String get msgPayWithBitcoin => 'Mit Bitcoin bezahlen';

  @override
  String get msgPayWithCard => 'Mit Karte bezahlen';

  @override
  String get msgPaymentSetup => 'Zahlung einrichten';

  @override
  String get msgPersonalContact => 'Persönlicher Kontakt';

  @override
  String get msgPhoneNumber => 'Telefonnummer';

  @override
  String get msgPhoneNumberCountryCode => 'Telefonnummer (+Ländervorwahl)';

  @override
  String get msgPlaceALimitOrder => 'Limitauftrag erteilen';

  @override
  String get msgPleaseAuthenticateToEnableBiometricUnlockForDecoy =>
      'Bitte authentifiziere dich, um die biometrische Entsperrung für Decoy Wallet zu aktivieren';

  @override
  String get msgPleaseAuthenticateToUnlockYourWallet =>
      'Bitte authentifiziere dich, um deine Wallet zu entsperren';

  @override
  String get msgPrimal => 'Primal';

  @override
  String get msgPrivacy => 'Datenschutz';

  @override
  String get msgPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get msgPurchaseSchedule => 'Kaufplan';

  @override
  String get msgPushNotifications => 'Push-Benachrichtigungen';

  @override
  String get msgQuizTime => 'ZEIT FÜR EIN QUIZ!';

  @override
  String get msgResetPasswordEmailSent =>
      'E-MAIL ZUM ZURÜCKSETZEN DES PASSWORTS GESENDET';

  @override
  String get msgReceive => 'Empfangen';

  @override
  String get msgReceivePartOfYourPaycheckDirectlyInBitcoin =>
      'Erhalte einen Teil deines Gehalts direkt in Bitcoin.';

  @override
  String get msgRecipientQr => 'Empfänger-QR-Code';

  @override
  String get msgRecurringBuy => 'Regelmäßiger Kauf';

  @override
  String get msgRedeemCode => 'Code einlösen';

  @override
  String get msgRefresh => 'Aktualisieren';

  @override
  String get msgResendCode => 'Code erneut senden';

  @override
  String get msgRetry => 'Erneut versuchen';

  @override
  String get msgReturnToHome => 'Zur Startseite';

  @override
  String get msgReviewDetailsBeforeBroadcast =>
      'Details vor der Übermittlung prüfen';

  @override
  String get msgRumble => 'Rumble';

  @override
  String get msgSafetySupport => 'SICHERHEIT UND HILFE';

  @override
  String get msgSetup => 'EINRICHTUNG';

  @override
  String get msgSmsTerms => 'SMS-Bedingungen';

  @override
  String get msgSupportTicket => 'HILFEANFRAGE';

  @override
  String get msgSaveExit => 'Speichern und beenden';

  @override
  String get msgSaveGoBack => 'Speichern und zurück';

  @override
  String get msgSaveGoHome => 'Speichern und zur Startseite';

  @override
  String get msgSavePhoneNumber => 'Telefonnummer speichern';

  @override
  String get msgScan => 'Scannen';

  @override
  String get msgScanOrPasteARecipientAddress =>
      'Empfängeradresse scannen oder einfügen';

  @override
  String get msgSee => 'Siehe ';

  @override
  String get msgSend => 'Senden';

  @override
  String get msgSendAmount => 'Sendebetrag';

  @override
  String get msgSendBitcoin => 'Bitcoin senden';

  @override
  String get msgSendFunds => 'Geld senden';

  @override
  String get msgSendLink => 'Link senden';

  @override
  String get msgSendMax => 'Maximum senden';

  @override
  String get msgSet => 'Festlegen';

  @override
  String get msgSetUpDecoyKeys => 'Tarnschlüssel einrichten';

  @override
  String get msgSetARecurringBuy => 'Regelmäßigen Kauf einrichten';

  @override
  String get msgSetAScheduleForAutomaticBitcoinPurchases =>
      'Lege einen Zeitplan für automatische Bitcoin-Käufe fest.';

  @override
  String get msgSettingUpYourDecoyKeys => 'Deine Tarnschlüssel einrichten';

  @override
  String get msgSettingUpYourDecoyPin => 'Deine Tarn-PIN einrichten';

  @override
  String get msgSettings => 'Einstellungen';

  @override
  String get msgSettingsControlCenter2 => 'Einstellungen > Steuerzentrale';

  @override
  String get msgSignInHere => 'Hier anmelden';

  @override
  String get msgSignedInDevice => 'Angemeldetes Gerät';

  @override
  String get msgSkipForNow => 'Vorerst überspringen';

  @override
  String get msgSlideForAQuickEstimateOrEnterAn =>
      'Verschiebe den Regler für eine schnelle Schätzung oder gib unten einen genauen Betrag ein.';

  @override
  String get msgSlideToSignAndSend => 'Zum Signieren und Senden schieben';

  @override
  String get msgState => 'Bundesstaat';

  @override
  String get msgStatus => 'Status';

  @override
  String get msgStatus2 => 'Status: ';

  @override
  String get msgStreetAddress => 'Straße und Hausnummer';

  @override
  String get msgStripeCheckoutInYourBrowser =>
      'Stripe-Zahlung in deinem Browser';

  @override
  String get msgStripeWillTakeOverOn => 'Stripe übernimmt ab dem  ';

  @override
  String get msgSubject => 'Betreff ';

  @override
  String get msgSubmitTicket => 'Anfrage senden';

  @override
  String get msgSubscriptionRequiredToChangeValues =>
      'Zum Ändern der Werte ist ein Abonnement erforderlich';

  @override
  String get msgSupportTicketSentToDecoyTeam =>
      'Hilfeanfrage an das Decoy-Team gesendet';

  @override
  String get msgSwitchValue => 'Schalterwert:';

  @override
  String get msgSyncMarket => 'Marktdaten synchronisieren';

  @override
  String get msgSystemStatus => 'Systemstatus:';

  @override
  String get msgTimeToGetAccess => 'JETZT ZUGANG SICHERN!';

  @override
  String get msgTapToOpenQrScanner => 'Tippen, um den QR-Scanner zu öffnen';

  @override
  String get msgTerms => 'Bedingungen';

  @override
  String get msgTermsConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get msgTermsOfService => 'Dienstleistungsbedingungen';

  @override
  String get msgTermsOfUse => 'Nutzungsbedingungen';

  @override
  String get msgThisActionIsPermanent => 'Diese Aktion ist dauerhaft';

  @override
  String get msgThisSeedPhraseWillNotBeStoredOn =>
      'Diese Wiederherstellungsphrase wird nicht auf diesem Gerät gespeichert. Schreibe sie auf und bewahre sie sicher auf.';

  @override
  String get msgTitleTheProblemYouAreExperiencing =>
      'Gib deinem Problem einen Titel';

  @override
  String get msgTo => 'An';

  @override
  String get msgToAddress => 'Empfängeradresse';

  @override
  String get msgToggleOnToEnableDecoyPinToContact =>
      'Aktiviere den Schalter, damit die TARN-PIN deine Notfallkontakte benachrichtigen kann';

  @override
  String get msgTotalAmount => 'Gesamtbetrag';

  @override
  String get msgTransactionComplete => 'Transaktion abgeschlossen';

  @override
  String get msgTransactionInitiated => 'Transaktion eingeleitet';

  @override
  String get msgTriggerDecoyKeysAlerts => 'Tarnschlüssel-Warnungen auslösen';

  @override
  String get msgTriggerDecoyPinAlerts => 'Tarn-PIN-Warnungen auslösen';

  @override
  String get msgTriggerStatus => 'Auslöserstatus:';

  @override
  String get msgTutorials => 'Anleitungen';

  @override
  String get msgUsa => 'USA';

  @override
  String get msgUnlockDecoyWallet => 'Decoy Wallet entsperren';

  @override
  String get msgUpdatePassword => 'Passwort aktualisieren';

  @override
  String get msgUseFingerprintOrFaceRecognitionForSecureAccess =>
      'Nutze Fingerabdruck oder Gesichtserkennung für sicheren Zugriff';

  @override
  String get msgUseXpubForLegacy1AddressWalletsZpub =>
      'Verwende xpub für Wallets mit älteren Adressen, die mit 1 beginnen, zpub für native SegWit-Wallets mit bc1-Adressen oder füge bestimmte Empfangsadressen ein.';

  @override
  String get msgUseYourFingerprintOrFaceIdToQuickly =>
      'Nutze deinen Fingerabdruck oder Face ID, um schnell und sicher auf dein Konto zuzugreifen';

  @override
  String get msgUseYourLocationToSupportEmergencyAlerts =>
      'Nutze deinen Standort zur Unterstützung von Notfallwarnungen';

  @override
  String get msgUsingADecoyPinWillTriggerEmergencyBehavior =>
      'Die Verwendung einer Tarn-PIN löst Notfallfunktionen in Decoy Wallet aus, einschließlich der Benachrichtigung von Kontakten oder Notfalldiensten.\n\nDiese Funktion ist ausschließlich für echte Bedrohungs- oder Zwangssituationen vorgesehen.';

  @override
  String get msgVerifyingPleaseWait => 'Wird überprüft... Bitte warten!';

  @override
  String get msgWallet => 'Wallet';

  @override
  String get msgWalletActivityMonitor => 'Überwachung der Wallet-Aktivität';

  @override
  String get msgWalletSeedPhrasesAndPrivateKeys =>
      'Wiederherstellungsphrasen und private Schlüssel der Wallets';

  @override
  String get msgWatchOnlyWalletImportIsAvailableInEnabled =>
      'Der Import von Wallets mit reinem Lesezugriff ist nur in dafür freigeschalteten Testversionen verfügbar.';

  @override
  String get msgWeSentA6DigitCodeTo =>
      'Wir haben einen 6-stelligen Code gesendet an ';

  @override
  String get msgWeWillSendYouAnEmailWithA =>
      'Wir senden dir eine E-Mail mit einem Link zum Zurücksetzen deines Passworts. Gib unten die mit deinem Konto verknüpfte E-Mail-Adresse ein.';

  @override
  String get msgWeReHereToHelpSubmitASupport =>
      'Wir helfen dir gerne! Sende eine Hilfeanfrage und wir melden uns so schnell wie möglich bei dir.';

  @override
  String get msgWeVeSentAConfirmationLinkTo =>
      'Wir haben einen Bestätigungslink gesendet an:';

  @override
  String get msgWebsite => 'Internetseite';

  @override
  String get msgWelcomeBack => 'Willkommen zurück';

  @override
  String get msgWhatWillBeDeleted => 'Was gelöscht wird';

  @override
  String get msgWhatWillNotBeDeleted => 'Was nicht gelöscht wird';

  @override
  String get msgWithdrawalSettings => 'Auszahlungseinstellungen';

  @override
  String get msgWriteADetailedDescriptionOfTheProblemYou =>
      'Beschreibe das aufgetretene Problem ausführlich';

  @override
  String get msgYourDecoySeed => 'DEINE TARN-WIEDERHERSTELLUNGSPHRASE';

  @override
  String get msgYearly => 'Jährlich';

  @override
  String get msgYouCanRequestANewCodeIn =>
      'Du kannst einen neuen Code anfordern in ';

  @override
  String get msgYouMayAlsoReachOutTo => 'Du kannst dich auch wenden an ';

  @override
  String get msgYoutube => 'YouTube';

  @override
  String get msgYourBitcoinFundsRemainSafeInYourExternal =>
      'Dein Bitcoin-Guthaben bleibt in deiner externen Wallet sicher';

  @override
  String get msgYourDecoyWalletAccountAndProfile =>
      'Dein Decoy Wallet-Konto und -Profil';

  @override
  String get msgYourEmailAddress => 'Deine E-Mail-Adresse...';

  @override
  String get msgZipCode => 'Postleitzahl';

  @override
  String get msgByNavigatingTo2 => 'unter ';

  @override
  String get msgForFurtherAssistance => 'für weitere Hilfe';

  @override
  String get msgZpubXpubOrReceiveAddresses =>
      'zpub, xpub oder Empfangsadressen';

  @override
  String get msgZpubOrBc1qBc1p1 => 'zpub...\n\noder\nbc1q...\nbc1p...\n1...';

  @override
  String get msgItcoinWallet => '₿itcoin-Wallet';

  @override
  String get msgLanguage => 'Sprache';

  @override
  String get msgUseDeviceLanguage => 'Gerätesprache verwenden';

  @override
  String get msgCouldNotSaveYourLanguagePleaseTryAgain =>
      'Deine Sprache konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get msgDone => 'Fertig';

  @override
  String get msg394Month => '\$3.94 / Monat';

  @override
  String get msg3942Year => '\$39.42 / Jahr';

  @override
  String get msg499Month => '\$4.99 / Monat';

  @override
  String get msg4728Year => '\$47.28 / Jahr';

  @override
  String get msg4990Year => '\$49.90 / Jahr';

  @override
  String get msg5988Year => '\$59.88 / Jahr';

  @override
  String get msgAmountExceedsAvailableBalance =>
      'BETRAG ÜBERSTEIGT DAS VERFÜGBARE GUTHABEN';

  @override
  String get msgAccountLevelSeedWalletMonitoring =>
      'Kontoweite Überwachung der aus der Wiederherstellungsphrase erstellten Wallet';

  @override
  String get msgActive => 'Aktiv';

  @override
  String get msgAsset => 'Vermögenswert';

  @override
  String get msgAwaitingConfirmation => 'Warten auf Bestätigung';

  @override
  String get msgBalanceCannotBeNegative =>
      'Das Guthaben darf nicht negativ sein.';

  @override
  String get msgBitcoinMainnet => 'Bitcoin-Hauptnetz';

  @override
  String get msgBlock => 'Block';

  @override
  String get msgBroadcast => 'Übermitteln';

  @override
  String get msgBroadcasted => 'Übermittelt';

  @override
  String get msgBroadcasting => 'Wird übermittelt';

  @override
  String get msgBroadcastingTransaction => 'Transaktion wird übermittelt';

  @override
  String get msgBuy => 'Kaufen';

  @override
  String get msgCancel => 'Abbrechen';

  @override
  String get msgCardPaymentsScheduled => 'Kartenzahlungen geplant';

  @override
  String get msgComplete2 => 'Abgeschlossen';

  @override
  String get msgConfirmationLinkSent => 'Bestätigungslink gesendet';

  @override
  String get msgConfirmed => 'Bestätigt';

  @override
  String get msgConfirmedOnTheBitcoinNetwork => 'Im Bitcoin-Netzwerk bestätigt';

  @override
  String get msgDecoyKeys2 => 'TARNSCHLÜSSEL';

  @override
  String get msgDecoyKeysReady => 'TARNSCHLÜSSEL BEREIT';

  @override
  String get msgDecoyKeysMonitor => 'Tarnschlüssel-Überwachung';

  @override
  String get msgDenied => 'Abgelehnt';

  @override
  String get msgDepositAsset => 'Einzahlungswährung';

  @override
  String get msgEnter21000000BtcOrLess =>
      'Gib 21.000.000 BTC oder weniger ein.';

  @override
  String get msgEnterAValidBtcAmount => 'Gib einen gültigen BTC-Betrag ein.';

  @override
  String get msgEveryPayday => 'An jedem Zahltag';

  @override
  String get msgFrequency => 'Häufigkeit';

  @override
  String get msgGenerateANewDecoySeedPhraseOrMonitor =>
      'Erstelle eine neue Tarn-Wiederherstellungsphrase oder überwache öffentliche Daten einer Wallet, die du bereits kontrollierst, mit reinem Lesezugriff.';

  @override
  String get msgGenerateANewDecoySeedPhraseToMonitor =>
      'Erstelle eine neue Tarn-Wiederherstellungsphrase, um ausgehende Aktivitäten der Wallet zu überwachen.';

  @override
  String get msgInMempool => 'Im Mempool';

  @override
  String get msgLive2 => 'In Echtzeit';

  @override
  String get msgManageCardPayments => 'Kartenzahlungen verwalten';

  @override
  String get msgMempool => 'Mempool';

  @override
  String get msgMostRecentDecoySeedGenerated =>
      'Zuletzt erstellte Tarn-Wiederherstellungsphrase';

  @override
  String get msgNotConfigured => 'Nicht konfiguriert';

  @override
  String get msgNotSelected => 'Nicht ausgewählt';

  @override
  String get msgNotSent => 'Nicht gesendet';

  @override
  String get msgOptedOut => 'Abgemeldet';

  @override
  String get msgOrderType => 'Auftragsart';

  @override
  String get msgPaste => 'Einfügen';

  @override
  String get msgPasteAZpubXpubOrOneOrMore =>
      'Füge einen zpub, xpub oder eine oder mehrere Bitcoin-Empfangsadressen ein.';

  @override
  String get msgPaymentMethod => 'Zahlungsmethode';

  @override
  String get msgPending => 'Ausstehend';

  @override
  String get msgPleaseSignInAgainToManageDecoyKeys =>
      'Bitte melde dich erneut an, um Tarnschlüssel zu verwalten.';

  @override
  String get msgPleaseSignInAgainToSaveMonitorChanges =>
      'Bitte melde dich erneut an, um Änderungen an der Überwachung zu speichern.';

  @override
  String get msgReady => 'Bereit';

  @override
  String get msgReceiveAddressMonitor => 'Empfangsadressen-Überwachung';

  @override
  String get msgRelayingTransactionToBitcoinPeers =>
      'Transaktion wird an Bitcoin-Netzwerkknoten weitergeleitet';

  @override
  String get msgRenewBitcoinPayments => 'Bitcoin-Zahlungen erneuern';

  @override
  String get msgResendConfirmationLink => 'Bestätigungslink erneut senden';

  @override
  String get msgSeenByPeersAndWaitingForTheNext =>
      'Von Netzwerkknoten empfangen, wartet auf den nächsten Block';

  @override
  String get msgSendConfirmationLink => 'Bestätigungslink senden';

  @override
  String get msgSettlement => 'Abwicklung';

  @override
  String get msgSigning => 'Wird signiert';

  @override
  String get msgSigningAndRelayingToBitcoinPeers =>
      'Wird signiert und an Bitcoin-Netzwerkknoten weitergeleitet';

  @override
  String get msgStackMoreDays => 'Weitere Tage hinzufügen';

  @override
  String get msgSwitchToBitcoinPayments => 'Zu Bitcoin-Zahlungen wechseln';

  @override
  String get msgSwitchToCardPayments => 'Zu Kartenzahlungen wechseln';

  @override
  String get msgSyncing => 'Wird synchronisiert';

  @override
  String get msgThisDevice => 'Dieses Gerät';

  @override
  String get msgThisWalletOrReceiveAddressIsAlreadyBeing =>
      'Diese Wallet oder Empfangsadresse wird bereits überwacht.';

  @override
  String get msgTransactionBroadcast => 'Transaktion übermittelt';

  @override
  String get msgTransactionConfirmed => 'Transaktion bestätigt';

  @override
  String get msgTransactionRelayedAndPendingInclusion =>
      'Transaktion weitergeleitet, wartet auf Aufnahme in einen Block';

  @override
  String get msgTxId => 'Transaktions-ID';

  @override
  String get msgUsdBalance => 'USD-Guthaben';

  @override
  String get msgUsdEstimateUnavailable => 'USD-Schätzung nicht verfügbar';

  @override
  String get msgUnableToCheckWhetherThisWalletIsAlready =>
      'Es konnte nicht geprüft werden, ob diese Wallet bereits überwacht wird. Bitte versuche es erneut.';

  @override
  String get msgUnableToDeleteThisMonitor =>
      'Diese Überwachung konnte nicht gelöscht werden.';

  @override
  String get msgUnableToLoadDecoyKeysMonitors =>
      'Tarnschlüssel-Überwachungen konnten nicht geladen werden.';

  @override
  String get msgUnableToSaveDecoyKeysMonitorChanges =>
      'Änderungen an der Tarnschlüssel-Überwachung konnten nicht gespeichert werden.';

  @override
  String get msgUnableToUpdateDecoyKeysMonitors =>
      'Tarnschlüssel-Überwachungen konnten nicht aktualisiert werden.';

  @override
  String get msgUnableToUpdateThisMonitor =>
      'Diese Überwachung konnte nicht aktualisiert werden.';

  @override
  String get msgUnableToValidateThisWatchOnlyWalletData =>
      'Diese Wallet-Daten mit reinem Lesezugriff konnten nicht validiert werden.';

  @override
  String get msgWaitingForNetworkConfirmations =>
      'Warten auf Netzwerkbestätigungen';

  @override
  String get msgWalletActivityMonitor2 => 'Überwachung der Wallet-Aktivität';

  @override
  String get msgXpubMonitor => 'xpub-Überwachung';

  @override
  String get msgZpubMonitor => 'zpub-Überwachung';

  @override
  String get msgWallet2 => 'WALLET';

  @override
  String get msgSecurity => 'SICHERHEIT';

  @override
  String receiveAddressCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Empfangsadressen',
      one: '1 Empfangsadresse',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    return 'vor $count Min.';
  }

  @override
  String get emergencyContactsHeadingFirstLine => 'NOTFALL-';

  @override
  String get emergencyContactsHeadingSecondLine => 'KONTAKTE';
}
