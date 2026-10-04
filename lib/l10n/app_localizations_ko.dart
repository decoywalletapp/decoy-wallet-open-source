// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get msgSaveBalanceToAccount => '이 잔액을 내 계정에 저장';

  @override
  String msgSaveBalanceToAccountPrompt(String amount) {
    return '이 계정에 $amount BTC를 저장하고 기기 간에 잔액을 동기화할까요? 이 계정에 이미 저장된 잔액이 있다면 기존 잔액이 유지됩니다.';
  }

  @override
  String get msgAlreadyConfirmedYourEmail => '이미 이메일을 확인하셨나요?';

  @override
  String get msgCameraAccessRequiredForQrScan =>
      'QR 코드를 스캔하려면 카메라 접근 권한이 필요합니다. 기기 설정에서 허용할 수 있습니다.';

  @override
  String get msgCouldNotOpenQrScanner =>
      'QR 스캐너를 열 수 없습니다. 다시 시도하거나 텍스트를 붙여넣으세요.';

  @override
  String get msgComplete => ' % 완료';

  @override
  String get msgControl => ' 제어';

  @override
  String get msgDaysLeft => ' 일 남음';

  @override
  String get msgSettingsControlCenter => ' 설정 > 제어 센터';

  @override
  String get msgSignUpHere => ' 여기서 가입';

  @override
  String get msgAnd => ' 및 ';

  @override
  String get msgByNavigatingTo => ' 다음 경로에서: ';

  @override
  String get msgOutlinedByDecoyWalletLlc => ' (DECOY WALLET LLC에서 정함)';

  @override
  String get msgSeconds => ' 초';

  @override
  String get msg0TradedThisMonth => '이번 달 거래액 \$0';

  @override
  String get msg1000ToNextLevel => '다음 등급까지 \$1,000';

  @override
  String get msg5551234567Or447700900123 => '(555) 123-4567 또는 +44 7700 900123';

  @override
  String get msg15551234567Or33612 => '+1 555 123 4567 또는 +33 6 12 34 56 78';

  @override
  String get msgEnterItBelowToVerifyYourPhoneNumber =>
      '. 전화번호를 확인하려면 아래에 입력하세요.';

  @override
  String get msg0Btc => '0 BTC';

  @override
  String get msg10kBtc => '10K BTC';

  @override
  String get msg123OceanDr => '123 Ocean Dr.';

  @override
  String get msg2MonthsFree => '2개월 무료';

  @override
  String get msg911Trigger => '911 신고 트리거';

  @override
  String get msgAccount => '계정';

  @override
  String get msgActivated => '활성화됨';

  @override
  String get msgArmToActivelyMonitorOutboundTransactions => '활성화하여 출금 거래 모니터링';

  @override
  String get msgAcceptDecoySeedPhrase => '위장 시드 문구 승인';

  @override
  String get msgAccountSubscriptionStatus => '계정 구독 상태:  ';

  @override
  String get msgAccountSubscriptionAccessAndActiveStripeBilling =>
      '계정 구독 이용 권한 및 활성 Stripe 결제';

  @override
  String get msgAcknowledgements => '확인 사항';

  @override
  String get msgAddYourPhoneNumber => '전화번호 추가';

  @override
  String get msgAddAWatchOnlyWalletKeyOrSpecific =>
      '보기 전용 지갑 키 또는 특정 수신 주소를 추가하여 출금 활동을 모니터링하세요.';

  @override
  String get msgAdjustBalance => '잔액 조정';

  @override
  String get msgAdvanced => '고급';

  @override
  String get msgAdvancedMonitorControls => '고급 모니터링 설정';

  @override
  String get msgAgreements => '동의 사항';

  @override
  String get msgAllowSubscriptionAlertsDirectlyToYourDevice =>
      '기기에서 구독 알림을 직접 받도록 허용';

  @override
  String get msgAllowYourLocationToBeIncludedAutomaticallyDuring =>
      '긴급 상황에서 위치가 자동으로 포함되도록 허용하면 신뢰하는 연락처와 긴급 대응 인력이 더 신속하게 대응할 수 있습니다. 위치는 백그라운드에서 추적되지 않으며, 긴급 기능이 작동한 경우에만 접근합니다.';

  @override
  String get msgAlreadyHaveAnAccount => '이미 계정이 있으신가요? ';

  @override
  String get msgAmount => '금액';

  @override
  String get msgApartmentUnitOptional => '동/호수 (선택 사항)';

  @override
  String get msgAppLock => '앱 잠금';

  @override
  String get msgAppPreferencesAndConfigurations => '앱 환경설정 및 구성';

  @override
  String get msgApt4b => '4B호';

  @override
  String get msgAutoWithdraw => '자동 출금';

  @override
  String get msgAutoWithdrawBitcoin => 'Bitcoin 자동 출금';

  @override
  String get msgAutomaticallySendPurchasedBitcoinToYourWallet =>
      '구매한 Bitcoin을 내 지갑으로 자동 전송합니다.';

  @override
  String get msgAwaitingConfirmations => '승인 대기 중';

  @override
  String get msgBtc => 'BTC';

  @override
  String get msgBtcUsd => 'BTC/USD';

  @override
  String get msgBtcpayInvoiceInYourBrowser => '브라우저에서 BTCPay 청구서 열기';

  @override
  String get msgBiometricAuthentication => '생체 인증';

  @override
  String get msgBiometricVerification => '생체 정보 확인';

  @override
  String get msgBitcoin => 'Bitcoin';

  @override
  String get msgBitcoinBalance => 'Bitcoin 잔액';

  @override
  String get msgBitcoinPay => 'Bitcoin 결제';

  @override
  String get msgBitcoinAddressOrPaymentUri => 'Bitcoin 주소 또는 결제 URI';

  @override
  String get msgBitcoinBalanceUpdated => 'Bitcoin 잔액이 업데이트되었습니다.';

  @override
  String
      get msgBitcoinPaymentConfirmingFullProtectionActivatesAfterConfirmation =>
          'Bitcoin 결제 승인 중입니다. 승인 후 모든 보호 기능이 활성화됩니다.';

  @override
  String get msgBroadcastedToNetwork => '네트워크에 전파됨';

  @override
  String get msgByContinuingYouAgreeToReceiveAutomatedText =>
      '계속하면 계정, 안전 알림, 긴급 연락처 상태, 구독 알림 및 지갑 알림에 관해 Decoy Wallet에서 자동으로 보내는 문자 메시지 수신에 동의하는 것입니다.\n메시지 발송 빈도는 일정하지 않습니다. 문자 및 데이터 요금이 부과될 수 있습니다.\n수신을 거부하려면 STOP, 도움이 필요하면 HELP라고 답장하세요.';

  @override
  String get msgByCreatingADecoyWalletYouAuthorizeDecoy =>
      'Decoy Wallet을 만들면, 본인이 긴급 이벤트를 발동하는 경우 선택한 연락처에 사용자 요청에 따른 일회성 긴급 알림을 보내도록 Decoy Wallet에 권한을 부여하는 것입니다.';

  @override
  String get msgCannotBeTheSameAsDecoyPin => '위장 PIN과 같을 수 없습니다';

  @override
  String get msgChooseAccess => '이용 방식 선택';

  @override
  String get msgComingSoon => '출시 예정!!!';

  @override
  String get msgContacts => '연락처';

  @override
  String get msgCancelSubscription => '구독 취소';

  @override
  String get msgCenter => '센터';

  @override
  String get msgCenter2 => '센터 ';

  @override
  String get msgChangeAccountEntryPin => '계정 접속 PIN 변경';

  @override
  String get msgChangeTheseSettingsAnytimeInThe =>
      '언제든지 다음에서 이 설정을 변경할 수 있습니다: ';

  @override
  String get msgCheckYourEmail => '이메일을 확인하세요';

  @override
  String get msgChooseFromContacts => '연락처에서 선택';

  @override
  String get msgChooseATargetPriceForYourNextBitcoin =>
      '다음 Bitcoin 구매의 목표 가격을 선택하세요.';

  @override
  String get msgChooseWord => '단어 선택 ';

  @override
  String get msgCity => '도시';

  @override
  String get msgClickTheLinkInTheEmailToConfirm =>
      '이메일의 링크를 클릭하여 계정을 확인하세요. 이메일이 보이지 않으면 스팸 폴더를 확인하세요.';

  @override
  String get msgCompleteTheRequiredDetailsToContinue => '계속하려면 필수 정보를 입력하세요.';

  @override
  String get msgConfigureBitcoinBalance => 'Bitcoin 잔액 설정';

  @override
  String get msgConfirm => '확인';

  @override
  String get msgConfirmDecoyPin => '위장 PIN 확인';

  @override
  String get msgConfirmPin => 'PIN 확인';

  @override
  String get msgConfirmPassword => '비밀번호 확인';

  @override
  String get msgConfirmTransaction => '거래 확인';

  @override
  String get msgConfirmNewPin => '새 PIN 확인';

  @override
  String get msgConfirmNewPassword => '새 비밀번호 확인';

  @override
  String get msgConfirmations => '승인 횟수';

  @override
  String get msgContact1 => '연락처 1';

  @override
  String get msgContact2 => '연락처 2';

  @override
  String get msgContact3 => '연락처 3';

  @override
  String get msgContact4 => '연락처 4';

  @override
  String get msgContact5 => '연락처 5';

  @override
  String get msgContactUs => '문의하기';

  @override
  String get msgContinue => '계속';

  @override
  String get msgControl2 => '제어';

  @override
  String get msgControlCenter => '제어 센터';

  @override
  String get msgCouldNotOpenContactsEnterContactManually =>
      '연락처를 열 수 없습니다. 연락처를 직접 입력하세요.';

  @override
  String get msgCountry => '국가';

  @override
  String get msgCreateAccount => '계정 만들기';

  @override
  String get msgCreateEmergencyContacts => '긴급 연락처 등록';

  @override
  String get msgCreateYourPinToAccessYourDashboard => '대시보드에 접속할 PIN 만들기';

  @override
  String get msgCreateADecoyPinForEmergencyServices => '긴급 서비스용 위장 PIN 만들기';

  @override
  String get msgCreateAnAccount => '계정 만들기';

  @override
  String get msgCurrency => '통화';

  @override
  String get msgCurrentlyDisabledInDeviceSettings =>
      '현재 기기 설정에서 비활성화되어 있습니다!!!';

  @override
  String get msgDeactivated => '비활성화됨';

  @override
  String get msgDecoyEmergency => '위장 긴급 기능';

  @override
  String get msgDecoyPinCannotBeTheSameAsAccount =>
      '위장 PIN은 계정 접속 PIN과 같을 수 없습니다';

  @override
  String get msgDecoySeed => '위장 시드';

  @override
  String get msgDecoyWalletBalance => 'Decoy Wallet 잔액';

  @override
  String get msgDisable => '비활성화';

  @override
  String get msgDecoyContacts => '위장 기능 연락처';

  @override
  String get msgDecoyKeys => '위장 키';

  @override
  String get msgDecoyKeysTriggers => '위장 키 트리거';

  @override
  String get msgDecoyPin => '위장 PIN';

  @override
  String get msgDecoyPinTriggers => '위장 PIN 트리거';

  @override
  String get msgDecoyWalletUsesNotificationsForSubscriptionAlertsDirectly =>
      'Decoy Wallet은 알림 기능을 사용하여 구독 관련 알림을 기기로 직접 보냅니다';

  @override
  String get msgDelete => '삭제';

  @override
  String get msgDeleteUserAccount => '사용자 계정 삭제';

  @override
  String get msgDeleteMyAccount => '내 계정 삭제';

  @override
  String get msgDeletingYourDecoyWalletAccountWillPermanentlyRemove =>
      'Decoy Wallet 계정을 삭제하면 계정, 긴급 연락처, 알림 전달 설정 및 모든 앱 설정이 영구적으로 삭제됩니다. 이 계정에 연결된 활성 Stripe 구독은 먼저 취소됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String get msgDidnTReceiveTheCode => '코드를 받지 못하셨나요?';

  @override
  String get msgDonTHaveAnAccount => '계정이 없으신가요? ';

  @override
  String get msgEmergency => '긴급';

  @override
  String get msgEnable => '활성화';

  @override
  String get msgEnterPin => 'PIN 입력';

  @override
  String get msgEnterValidPhoneNumber => '유효한 전화번호를 입력하세요';

  @override
  String get msgError001PleaseScreenshotContactDecoySupport =>
      '오류 #001 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError002PleaseScreenshotContactDecoySupport =>
      '오류 #002 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError003PleaseScreenshotContactDecoySupport =>
      '오류 #003 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError004PleaseScreenshotContactDecoySupport =>
      '오류 #004 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError005PleaseScreenshotContactDecoySupport =>
      '오류 #005 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError006PleaseScreenshotContactDecoySupport =>
      '오류 #006 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError008PleaseScreenshotContactDecoySupport =>
      '오류 #008 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError009PleaseScreenshotContactDecoySupport =>
      '오류 #009 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError010PleaseScreenshotContactDecoySupport =>
      '오류 #010 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError011PleaseScreenshotContactDecoySupport =>
      '오류 #011 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError012PleaseScreenshotContactDecoySupport =>
      '오류 #012 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError013PleaseScreenshotContactDecoySupport =>
      '오류 #013 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError014PleaseScreenshotContactDecoySupport =>
      '오류 #014 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError015PleaseScreenshotContactDecoySupport =>
      '오류 #015 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError016PleaseScreenshotContactDecoySupport =>
      '오류 #016 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError020PleaseScreenshotContactDecoySupport =>
      '오류 #020 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError021PleaseScreenshotContactDecoySupport =>
      '오류 #021 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError024PleaseScreenshotContactDecoySupport =>
      '오류 #024 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError025PleaseScreenshotContactDecoySupport =>
      '오류 #025 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError029PleaseScreenshotContactDecoySupport =>
      '오류 #029 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgError030PleaseScreenshotContactDecoySupport =>
      '오류 #030 - 화면을 캡처하여 Decoy 지원팀에 문의하세요';

  @override
  String get msgEta => '예상 완료 시간';

  @override
  String get msgEmail => '이메일';

  @override
  String get msgEmailRequired => '이메일은 필수입니다!';

  @override
  String get msgEmergencyContacts => '긴급 연락처';

  @override
  String get msgEmergencyContactsTrigger => '긴급 연락처 알림 트리거';

  @override
  String
      get msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications =>
          '긴급 알림, 지갑 모니터링 및 긴급 연락처 알림을 이용하려면 활성 유료 구독이 필요합니다.';

  @override
  String get msgEmergencyContactsAndAlertSettings => '긴급 연락처 및 알림 설정';

  @override
  String get msgEmergencyContactsReceiveAlertsOnlyBecauseYouVoluntarily =>
      '긴급 연락처는 본인이 자발적으로 해당 전화번호를 제공한 경우에만 알림을 받습니다.\n\n개인정보 처리방침에 명시된 대로 정보가 긴급 서비스 제공업체 또는 제3자와 공유될 수 있습니다.';

  @override
  String get msgEnableBiometricAuthentication => '생체 인증 활성화';

  @override
  String get msgEnableCurrentLocation => '현재 위치 사용 활성화';

  @override
  String get msgEnableLocationServices => '위치 서비스\n활성화';

  @override
  String get msgEnableLocationServices2 => '위치 서비스 활성화';

  @override
  String get msgEnablePushNotifications => '푸시 알림\n활성화';

  @override
  String get msgEnablePushNotifications2 => '푸시 알림 활성화';

  @override
  String get msgEnter => '입력';

  @override
  String get msgEnterCurrentAccountEntryPin => '현재 계정 접속 PIN 입력';

  @override
  String get msgEnterManually => '직접 입력';

  @override
  String get msgEnterVerificationCode => '인증 코드 입력';

  @override
  String get msgEnterA48DigitDecoyPin => '4 - 8자리 위장 PIN 입력 ';

  @override
  String get msgEnterA48DigitPinToSecure => '계정을 보호할 4 - 8자리 PIN을 입력하세요';

  @override
  String get msgEnterANewPinToAccessYourAccount => '계정에 접속할 새 PIN을 입력하세요';

  @override
  String get msgEnterAnyValueFrom0To21000 => '0부터 21,000,000 BTC 사이의 값을 입력하세요';

  @override
  String get msgEnterEmail => '이메일 입력';

  @override
  String get msgEnterFirstName => '이름 입력';

  @override
  String get msgEnterLastName => '성 입력';

  @override
  String get msgEnterNewPassword => '새 비밀번호 입력';

  @override
  String get msgEnterTheAmountYouWantToSend => '보낼 금액을 입력하세요';

  @override
  String get msgEnterTheCurrentPinYouUseToAccess => '현재 계정 접속에 사용하는 PIN을 입력하세요';

  @override
  String get msgEnterTheSame48DigitsToConfirm =>
      '위장 PIN을 확인하려면 동일한 4 - 8자리 숫자를 입력하세요';

  @override
  String get msgEnterTheSame48DigitsToConfirm2 =>
      '접속 PIN을 확인하려면 동일한 4 - 8자리 숫자를 입력하세요';

  @override
  String get msgEnterYourEmail => '이메일을 입력하세요...';

  @override
  String get msgEnterYourEventCodeInYourBrowser => '브라우저에서 이벤트 코드를 입력하세요';

  @override
  String get msgExactBitcoinAmount => '정확한 Bitcoin 금액';

  @override
  String get msgFl => 'FL';

  @override
  String get msgFollowDecoyWallet => 'Decoy Wallet 팔로우';

  @override
  String get msgFirstName => '이름';

  @override
  String get msgFixTheMoneyFixTheWorld => '돈을 바로잡으면 세상이 바로잡힙니다.';

  @override
  String get msgFlexibleAccess => '유연한 이용 방식';

  @override
  String get msgForgotPassword => '비밀번호 찾기';

  @override
  String get msgForgotPassword2 => '비밀번호를 잊으셨나요?';

  @override
  String get msgGenerated => '생성됨';

  @override
  String get msgGenerateSeedPhrase => '시드 문구 생성';

  @override
  String get msgGetPaidInBitcoin => 'Bitcoin으로 급여 받기';

  @override
  String get msgHomeAddress => '집 주소';

  @override
  String get msgHowToChangeAccountEntryPin => '계정 접속 PIN 변경 방법';

  @override
  String get msgHowToChangeDecoyKeys => '위장 키 변경 방법';

  @override
  String get msgHowToChangeDecoyPin => '위장 PIN 변경 방법';

  @override
  String get msgHowToChangePhoneNumber => '전화번호 변경 방법';

  @override
  String get msgHowToChangeYourEmail => '이메일 변경 방법';

  @override
  String get msgHowToDeleteUserAccount => '사용자 계정 삭제 방법';

  @override
  String get msgHowToEnterContactInformation => '연락처 정보 입력 방법';

  @override
  String get msgHowToManageControlCenter => '제어 센터 관리 방법';

  @override
  String get msgIAgreeToThe => '다음에 동의합니다: ';

  @override
  String get msgIUnderstandDecoyPinAlertsRelyOnMy =>
      '위장 PIN 알림은 내 기기 권한, 네트워크 연결 및 저장된 알림 설정에 의존하며, 이러한 설정을 사용 가능한 최신 상태로 유지할 책임이 본인에게 있음을 이해합니다.';

  @override
  String get msgIUnderstandDecoySeedAlertsAreDesignedFor =>
      '위장 시드 알림은 모니터링을 활성화한 내 위장 시드 지갑의 온체인 활동을 대상으로 설계되었으며, 시드 알림 설정을 사용 가능한 최신 상태로 유지할 책임이 본인에게 있음을 이해합니다.';

  @override
  String get msgIUnderstandThatDecoyWalletDoesNotHold =>
      'Decoy Wallet은 내 자금을 보관하거나 보호하지 않고 손실을 방지할 수 없으며, 이 기능의 사용 또는 오용으로 발생하는 모든 결과에 대한 책임은 전적으로 본인에게 있음을 이해합니다.';

  @override
  String get msgIUnderstandThatEnteringMyDecoyPinWill =>
      '위장 PIN을 입력하면 긴급 트리거가 활성화되며, 내 긴급 연락처, 제3자 서비스 또는 공공 안전 기관에 알림이 전송될 수 있음을 이해합니다.';

  @override
  String get msgIUnderstandThatUsingMyDecoyWalletMay =>
      'Decoy Wallet을 사용하면 내 연락처, 제3자 서비스 또는 공공 안전 기관에 긴급 알림이 전송될 수 있음을 이해합니다.';

  @override
  String get msgIUnderstandThisActionIsPermanentAndCannot =>
      '이 작업은 영구적이며 되돌릴 수 없음을 이해합니다';

  @override
  String get msgIUnderstandThisFeatureIsOnlyForReal =>
      '이 기능은 실제 긴급 상황에서만 사용해야 하며, 오용으로 인한 허위 알림, 요금 또는 결과에 대한 책임이 본인에게 있음을 이해합니다.';

  @override
  String get msgInactive => '비활성';

  @override
  String get msgIncorrectPin => 'PIN이 올바르지 않습니다';

  @override
  String get msgInvalidLogin => '로그인 정보가 유효하지 않습니다';

  @override
  String get msgInvalidPasswordMustBeAtLeast10Characters =>
      '유효하지 않은 비밀번호 - 10자 이상이어야 합니다';

  @override
  String get msgInvalidPhoneNumber => '유효하지 않은 전화번호';

  @override
  String get msgInvalidPinTryAgain => '유효하지 않은 PIN - 다시 시도하세요';

  @override
  String get msgImportantToEnableTheDecoyPinFeatureYou =>
      '중요: 위장 PIN 기능을 활성화하려면 아래의 모든 확인 사항에 동의해야 합니다.\n하나라도 동의하지 않는 항목이 있으면 계속하지 마세요.';

  @override
  String get msgInstagram => 'Instagram';

  @override
  String get msgInvalidCodePleaseTryAgain => '유효하지 않은 코드입니다. 다시 시도하세요.';

  @override
  String get msgLegal => '법적 정보';

  @override
  String get msgLive => '실시간';

  @override
  String get msgLastName => '성';

  @override
  String get msgLetSGetStartedByFillingOutThe => '아래 양식을 작성하여 시작하세요.';

  @override
  String get msgLimitOrder => '지정가 주문';

  @override
  String get msgLocationServices => '위치 서비스';

  @override
  String get msgLogOut => '로그아웃';

  @override
  String get msgLogIn => '로그인';

  @override
  String get msgManageAccess => '이용 권한 관리';

  @override
  String get msgMethod => '방법';

  @override
  String get msgMustBeAtLeast4Digits => '4자리 이상이어야 합니다';

  @override
  String get msgManageYourWalletPreferencesAndSession => '지갑 환경설정과 세션을 관리하세요.';

  @override
  String get msgManualAddress => '주소 직접 입력';

  @override
  String get msgMasterStatus => '전체 상태:';

  @override
  String get msgMessage => '메시지 ';

  @override
  String get msgMiamiBeach => '마이애미 비치';

  @override
  String get msgMonitorExistingWallet => '기존 지갑 모니터링';

  @override
  String get msgMonitorStatus => '모니터링 상태:';

  @override
  String get msgMonthly => '월간';

  @override
  String get msgMySubscription => '내 구독';

  @override
  String get msgNotQuiteTryAgain => '정확하지 않습니다 - 다시 시도하세요';

  @override
  String get msgNetwork => '네트워크';

  @override
  String get msgNetworkFee => '네트워크 수수료';

  @override
  String get msgNetworkProgress => '네트워크 진행 상황';

  @override
  String get msgNext => '다음';

  @override
  String get msgNoDecoyKeysMonitorsFoundYet => '아직 등록된 위장 키 모니터가 없습니다.';

  @override
  String get msgOpenDeviceSettings => '기기 설정 열기';

  @override
  String get msgOrderDetails => '주문 상세';

  @override
  String get msgPasswordUpdateFailedTryADifferentPassword =>
      '비밀번호 변경 실패 - 다른 비밀번호를 사용하세요';

  @override
  String get msgPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get msgPasswordsDoNotMatchTryAgain => '비밀번호가 일치하지 않습니다 - 다시 시도하세요';

  @override
  String get msgPhoneNumberAlreadyInUse => '이미 사용 중인 전화번호입니다';

  @override
  String get msgPinMustBeAtLeast4Digits => 'PIN은 4자리 이상이어야 합니다';

  @override
  String get msgPinsDidNotMatchTryAgain => 'PIN이 일치하지 않았습니다 - 다시 시도하세요';

  @override
  String get msgPinsDoNotMatchPleaseTryAgain => 'PIN이 일치하지 않습니다 - 다시 시도하세요';

  @override
  String get msgPleaseEnterAtLeast4Digits => '4자리 이상 입력하세요';

  @override
  String get msgPleaseEnterAtLeast4DigitsToContinue => '계속하려면 4자리 이상 입력하세요';

  @override
  String get msgPleaseEnterAtLeastFourDigits => '4자리 이상 입력하세요';

  @override
  String get msgProgress => '진행 상황';

  @override
  String get msgPassword => '비밀번호';

  @override
  String get msgPasswordMustBeAtLeast10Characters => '비밀번호는 10자 이상이어야 합니다';

  @override
  String get msgPasteOnlyWatchOnlyPublicDataNeverPaste =>
      '보기 전용 공개 데이터만 붙여넣으세요. 시드 문구, 개인 키, xprv 또는 zprv는 절대 붙여넣지 마세요.';

  @override
  String get msgPasteOrEnterWalletAddress => '지갑 주소 붙여넣기 또는 입력';

  @override
  String get msgPayForDecoyWithBitcoin => 'Bitcoin으로 Decoy Wallet 이용료 결제';

  @override
  String get msgPayForDecoyWithCreditCard => '신용카드로 Decoy Wallet 이용료 결제';

  @override
  String get msgPayWithBitcoin => 'Bitcoin으로 결제';

  @override
  String get msgPayWithCard => '카드로 결제';

  @override
  String get msgPaymentSetup => '결제 설정';

  @override
  String get msgPersonalContact => '개인 연락처';

  @override
  String get msgPhoneNumber => '전화번호';

  @override
  String get msgPhoneNumberCountryCode => '전화번호 (+국가 코드)';

  @override
  String get msgPlaceALimitOrder => '지정가 주문하기';

  @override
  String get msgPleaseAuthenticateToEnableBiometricUnlockForDecoy =>
      'Decoy Wallet의 생체 인식 잠금 해제를 활성화하려면 인증하세요';

  @override
  String get msgPleaseAuthenticateToUnlockYourWallet => '지갑 잠금을 해제하려면 인증하세요';

  @override
  String get msgPrimal => 'Primal';

  @override
  String get msgPrivacy => '개인정보 보호';

  @override
  String get msgPrivacyPolicy => '개인정보 처리방침';

  @override
  String get msgPurchaseSchedule => '구매 일정';

  @override
  String get msgPushNotifications => '푸시 알림';

  @override
  String get msgQuizTime => '확인 퀴즈!';

  @override
  String get msgResetPasswordEmailSent => '비밀번호 재설정 이메일을 보냈습니다';

  @override
  String get msgReceive => '받기';

  @override
  String get msgReceivePartOfYourPaycheckDirectlyInBitcoin =>
      '급여의 일부를 Bitcoin으로 직접 받으세요.';

  @override
  String get msgRecipientQr => '수신자 QR 코드';

  @override
  String get msgRecurringBuy => '정기 구매';

  @override
  String get msgRedeemCode => '코드 사용';

  @override
  String get msgRefresh => '새로고침';

  @override
  String get msgResendCode => '코드 다시 보내기';

  @override
  String get msgRetry => '다시 시도';

  @override
  String get msgReturnToHome => '홈으로 돌아가기';

  @override
  String get msgReviewDetailsBeforeBroadcast => '전파하기 전에 세부 정보 확인';

  @override
  String get msgRumble => 'Rumble';

  @override
  String get msgSafetySupport => '안전 및 지원';

  @override
  String get msgSetup => '설정';

  @override
  String get msgSmsTerms => 'SMS 약관';

  @override
  String get msgSupportTicket => '지원 문의';

  @override
  String get msgSaveExit => '저장 후 종료';

  @override
  String get msgSaveGoBack => '저장 후 돌아가기';

  @override
  String get msgSaveGoHome => '저장 후 홈으로';

  @override
  String get msgSavePhoneNumber => '전화번호 저장';

  @override
  String get msgScan => '스캔';

  @override
  String get msgScanOrPasteARecipientAddress => '수신자 주소 스캔 또는 붙여넣기';

  @override
  String get msgSee => '참고: ';

  @override
  String get msgSend => '보내기';

  @override
  String get msgSendAmount => '보낼 금액';

  @override
  String get msgSendBitcoin => 'Bitcoin 보내기';

  @override
  String get msgSendFunds => '자금 보내기';

  @override
  String get msgSendLink => '링크 보내기';

  @override
  String get msgSendMax => '전액 보내기';

  @override
  String get msgSet => '설정';

  @override
  String get msgSetUpDecoyKeys => '위장 키 설정';

  @override
  String get msgSetARecurringBuy => '정기 구매 설정';

  @override
  String get msgSetAScheduleForAutomaticBitcoinPurchases =>
      'Bitcoin 자동 구매 일정을 설정하세요.';

  @override
  String get msgSettingUpYourDecoyKeys => '위장 키 설정하기';

  @override
  String get msgSettingUpYourDecoyPin => '위장 PIN 설정하기';

  @override
  String get msgSettings => '설정';

  @override
  String get msgSettingsControlCenter2 => '설정 > 제어 센터';

  @override
  String get msgSignInHere => '여기서 로그인';

  @override
  String get msgSignedInDevice => '로그인된 기기';

  @override
  String get msgSkipForNow => '나중에 하기';

  @override
  String get msgSlideForAQuickEstimateOrEnterAn =>
      '슬라이더로 대략적인 금액을 선택하거나 아래에 정확한 금액을 입력하세요.';

  @override
  String get msgSlideToSignAndSend => '밀어서 서명 및 전송';

  @override
  String get msgState => '주';

  @override
  String get msgStatus => '상태';

  @override
  String get msgStatus2 => '상태: ';

  @override
  String get msgStreetAddress => '도로명 주소';

  @override
  String get msgStripeCheckoutInYourBrowser => '브라우저에서 Stripe 결제';

  @override
  String get msgStripeWillTakeOverOn => 'Stripe 결제 시작일:  ';

  @override
  String get msgSubject => '제목 ';

  @override
  String get msgSubmitTicket => '문의 제출';

  @override
  String get msgSubscriptionRequiredToChangeValues => '값을 변경하려면 구독이 필요합니다';

  @override
  String get msgSupportTicketSentToDecoyTeam => 'Decoy 팀에 지원 문의를 보냈습니다';

  @override
  String get msgSwitchValue => '스위치 값:';

  @override
  String get msgSyncMarket => '시장 가격 동기화';

  @override
  String get msgSystemStatus => '시스템 상태:';

  @override
  String get msgTimeToGetAccess => '이제 이용을 시작하세요!';

  @override
  String get msgTapToOpenQrScanner => '탭하여 QR 스캐너 열기';

  @override
  String get msgTerms => '약관';

  @override
  String get msgTermsConditions => '이용약관 및 조건';

  @override
  String get msgTermsOfService => '서비스 약관';

  @override
  String get msgTermsOfUse => '이용약관';

  @override
  String get msgThisActionIsPermanent => '이 작업은 영구적입니다';

  @override
  String get msgThisSeedPhraseWillNotBeStoredOn =>
      '이 시드 문구는 이 기기에 저장되지 않습니다. 적어 두고 안전하게 보관하세요.';

  @override
  String get msgTitleTheProblemYouAreExperiencing => '발생한 문제의 제목을 입력하세요';

  @override
  String get msgTo => '받는 사람';

  @override
  String get msgToAddress => '수신 주소';

  @override
  String get msgToggleOnToEnableDecoyPinToContact =>
      '켜면 위장 PIN으로 긴급 연락처에 알릴 수 있습니다';

  @override
  String get msgTotalAmount => '총금액';

  @override
  String get msgTransactionComplete => '거래 완료';

  @override
  String get msgTransactionInitiated => '거래 시작됨';

  @override
  String get msgTriggerDecoyKeysAlerts => '위장 키 알림 발동';

  @override
  String get msgTriggerDecoyPinAlerts => '위장 PIN 알림 발동';

  @override
  String get msgTriggerStatus => '트리거 상태:';

  @override
  String get msgTutorials => '사용 안내';

  @override
  String get msgUsa => '미국';

  @override
  String get msgUnlockDecoyWallet => 'Decoy Wallet 잠금 해제';

  @override
  String get msgUpdatePassword => '비밀번호 변경';

  @override
  String get msgUseFingerprintOrFaceRecognitionForSecureAccess =>
      '지문 또는 얼굴 인식으로 안전하게 접속';

  @override
  String get msgUseXpubForLegacy1AddressWalletsZpub =>
      '주소가 1로 시작하는 레거시 지갑에는 xpub, bc1로 시작하는 네이티브 SegWit 지갑에는 zpub를 사용하거나 특정 수신 주소를 붙여넣으세요.';

  @override
  String get msgUseYourFingerprintOrFaceIdToQuickly =>
      '지문 또는 Face ID로 계정에 빠르고 안전하게 접속하세요';

  @override
  String get msgUseYourLocationToSupportEmergencyAlerts => '위치 정보를 긴급 알림에 활용';

  @override
  String get msgUsingADecoyPinWillTriggerEmergencyBehavior =>
      '위장 PIN을 사용하면 연락처 또는 긴급 서비스에 알림을 보내는 등 Decoy Wallet 내의 긴급 대응 동작이 실행됩니다.\n\n이 기능은 실제로 협박이나 강압을 받는 상황에서만 사용하도록 설계되었습니다.';

  @override
  String get msgVerifyingPleaseWait => '확인 중... 잠시 기다려 주세요!';

  @override
  String get msgWallet => '지갑';

  @override
  String get msgWalletActivityMonitor => '지갑 활동 모니터';

  @override
  String get msgWalletSeedPhrasesAndPrivateKeys => '지갑 시드 문구 및 개인 키';

  @override
  String get msgWatchOnlyWalletImportIsAvailableInEnabled =>
      '보기 전용 지갑 가져오기는 이 기능이 활성화된 테스트 빌드에서만 사용할 수 있습니다.';

  @override
  String get msgWeSentA6DigitCodeTo => '6자리 코드를 보냈습니다. 수신 번호: ';

  @override
  String get msgWeWillSendYouAnEmailWithA =>
      '비밀번호 재설정 링크가 포함된 이메일을 보내드립니다. 아래에 계정과 연결된 이메일을 입력하세요.';

  @override
  String get msgWeReHereToHelpSubmitASupport =>
      '도움이 필요하신가요? 지원 문의를 제출하시면 최대한 빨리 답변해 드리겠습니다.';

  @override
  String get msgWeVeSentAConfirmationLinkTo => '다음 주소로 확인 링크를 보냈습니다:';

  @override
  String get msgWebsite => '웹사이트';

  @override
  String get msgWelcomeBack => '다시 오신 것을 환영합니다';

  @override
  String get msgWhatWillBeDeleted => '삭제되는 항목';

  @override
  String get msgWhatWillNotBeDeleted => '삭제되지 않는 항목';

  @override
  String get msgWithdrawalSettings => '출금 설정';

  @override
  String get msgWriteADetailedDescriptionOfTheProblemYou =>
      '발생한 문제를 자세히 설명해 주세요';

  @override
  String get msgYourDecoySeed => '내 위장 시드';

  @override
  String get msgYearly => '연간';

  @override
  String get msgYouCanRequestANewCodeIn => '새 코드 요청까지 남은 시간: ';

  @override
  String get msgYouMayAlsoReachOutTo => '다음으로도 문의하실 수 있습니다: ';

  @override
  String get msgYoutube => 'YouTube';

  @override
  String get msgYourBitcoinFundsRemainSafeInYourExternal =>
      'Bitcoin 자금은 외부 지갑에 안전하게 보관된 상태로 유지됩니다';

  @override
  String get msgYourDecoyWalletAccountAndProfile => '내 Decoy Wallet 계정 및 프로필';

  @override
  String get msgYourEmailAddress => '이메일 주소...';

  @override
  String get msgZipCode => '우편번호';

  @override
  String get msgByNavigatingTo2 => '다음 경로에서: ';

  @override
  String get msgForFurtherAssistance => '추가 도움이 필요한 경우';

  @override
  String get msgZpubXpubOrReceiveAddresses => 'zpub, xpub 또는 수신 주소';

  @override
  String get msgZpubOrBc1qBc1p1 => 'zpub...\n\n또는\nbc1q...\nbc1p...\n1...';

  @override
  String get msgItcoinWallet => '₿itcoin 지갑';

  @override
  String get msgLanguage => '언어';

  @override
  String get msgUseDeviceLanguage => '기기 언어 사용';

  @override
  String get msgCouldNotSaveYourLanguagePleaseTryAgain =>
      '언어 설정을 저장할 수 없습니다. 다시 시도하세요.';

  @override
  String get msgDone => '완료';

  @override
  String get msg394Month => '\$3.94 / 월';

  @override
  String get msg3942Year => '\$39.42 / 년';

  @override
  String get msg499Month => '\$4.99 / 월';

  @override
  String get msg4728Year => '\$47.28 / 년';

  @override
  String get msg4990Year => '\$49.90 / 년';

  @override
  String get msg5988Year => '\$59.88 / 년';

  @override
  String get msgAmountExceedsAvailableBalance => '금액이 사용 가능한 잔액을 초과합니다';

  @override
  String get msgAccountLevelSeedWalletMonitoring => '계정 단위 시드 지갑 모니터링';

  @override
  String get msgActive => '활성';

  @override
  String get msgAsset => '자산';

  @override
  String get msgAwaitingConfirmation => '승인 대기 중';

  @override
  String get msgBalanceCannotBeNegative => '잔액은 음수일 수 없습니다.';

  @override
  String get msgBitcoinMainnet => 'Bitcoin 메인넷';

  @override
  String get msgBlock => '블록';

  @override
  String get msgBroadcast => '전파';

  @override
  String get msgBroadcasted => '전파됨';

  @override
  String get msgBroadcasting => '전파 중';

  @override
  String get msgBroadcastingTransaction => '거래 전파 중';

  @override
  String get msgBuy => '구매';

  @override
  String get msgCancel => '취소';

  @override
  String get msgCardPaymentsScheduled => '카드 결제 예정';

  @override
  String get msgComplete2 => '완료';

  @override
  String get msgConfirmationLinkSent => '확인 링크 전송됨';

  @override
  String get msgConfirmed => '승인됨';

  @override
  String get msgConfirmedOnTheBitcoinNetwork => 'Bitcoin 네트워크에서 승인됨';

  @override
  String get msgDecoyKeys2 => '위장 키';

  @override
  String get msgDecoyKeysReady => '위장 키 준비 완료';

  @override
  String get msgDecoyKeysMonitor => '위장 키 모니터';

  @override
  String get msgDenied => '거부됨';

  @override
  String get msgDepositAsset => '입금 자산';

  @override
  String get msgEnter21000000BtcOrLess => '21,000,000 BTC 이하로 입력하세요.';

  @override
  String get msgEnterAValidBtcAmount => '유효한 BTC 금액을 입력하세요.';

  @override
  String get msgEveryPayday => '매 급여일';

  @override
  String get msgFrequency => '빈도';

  @override
  String get msgGenerateANewDecoySeedPhraseOrMonitor =>
      '새 위장 시드 문구를 생성하거나 이미 직접 관리 중인 보기 전용 지갑 데이터를 모니터링하세요.';

  @override
  String get msgGenerateANewDecoySeedPhraseToMonitor =>
      '새 위장 시드 문구를 생성하여 지갑 출금 활동을 모니터링하세요.';

  @override
  String get msgInMempool => '메모리풀에 있음';

  @override
  String get msgLive2 => '실시간';

  @override
  String get msgManageCardPayments => '카드 결제 관리';

  @override
  String get msgMempool => '메모리풀';

  @override
  String get msgMostRecentDecoySeedGenerated => '가장 최근에 생성한 위장 시드';

  @override
  String get msgNotConfigured => '설정되지 않음';

  @override
  String get msgNotSelected => '선택되지 않음';

  @override
  String get msgNotSent => '전송되지 않음';

  @override
  String get msgOptedOut => '수신 거부됨';

  @override
  String get msgOrderType => '주문 유형';

  @override
  String get msgPaste => '붙여넣기';

  @override
  String get msgPasteAZpubXpubOrOneOrMore =>
      'zpub, xpub 또는 하나 이상의 Bitcoin 수신 주소를 붙여넣으세요.';

  @override
  String get msgPaymentMethod => '결제 방법';

  @override
  String get msgPending => '대기 중';

  @override
  String get msgPleaseSignInAgainToManageDecoyKeys => '위장 키를 관리하려면 다시 로그인하세요.';

  @override
  String get msgPleaseSignInAgainToSaveMonitorChanges =>
      '모니터 변경 사항을 저장하려면 다시 로그인하세요.';

  @override
  String get msgReady => '준비 완료';

  @override
  String get msgReceiveAddressMonitor => '수신 주소 모니터';

  @override
  String get msgRelayingTransactionToBitcoinPeers => 'Bitcoin 피어에 거래 전달 중';

  @override
  String get msgRenewBitcoinPayments => 'Bitcoin으로 이용 기간 갱신';

  @override
  String get msgResendConfirmationLink => '확인 링크 다시 보내기';

  @override
  String get msgSeenByPeersAndWaitingForTheNext => '피어가 수신했으며 다음 블록 대기 중';

  @override
  String get msgSendConfirmationLink => '확인 링크 보내기';

  @override
  String get msgSettlement => '정산';

  @override
  String get msgSigning => '서명 중';

  @override
  String get msgSigningAndRelayingToBitcoinPeers => '서명 후 Bitcoin 피어에 전달 중';

  @override
  String get msgStackMoreDays => '이용 일수 추가';

  @override
  String get msgSwitchToBitcoinPayments => 'Bitcoin 결제로 전환';

  @override
  String get msgSwitchToCardPayments => '카드 결제로 전환';

  @override
  String get msgSyncing => '동기화 중';

  @override
  String get msgThisDevice => '이 기기';

  @override
  String get msgThisWalletOrReceiveAddressIsAlreadyBeing =>
      '이 지갑 또는 수신 주소는 이미 모니터링 중입니다.';

  @override
  String get msgTransactionBroadcast => '거래 전파';

  @override
  String get msgTransactionConfirmed => '거래 승인됨';

  @override
  String get msgTransactionRelayedAndPendingInclusion =>
      '거래가 전달되었으며 블록 포함 대기 중';

  @override
  String get msgTxId => '거래 ID';

  @override
  String get msgUsdBalance => 'USD 잔액';

  @override
  String get msgUsdEstimateUnavailable => 'USD 예상 금액을 확인할 수 없습니다';

  @override
  String get msgUnableToCheckWhetherThisWalletIsAlready =>
      '이 지갑이 이미 모니터링 중인지 확인할 수 없습니다. 다시 시도하세요.';

  @override
  String get msgUnableToDeleteThisMonitor => '이 모니터를 삭제할 수 없습니다.';

  @override
  String get msgUnableToLoadDecoyKeysMonitors => '위장 키 모니터를 불러올 수 없습니다.';

  @override
  String get msgUnableToSaveDecoyKeysMonitorChanges =>
      '위장 키 모니터 변경 사항을 저장할 수 없습니다.';

  @override
  String get msgUnableToUpdateDecoyKeysMonitors => '위장 키 모니터를 업데이트할 수 없습니다.';

  @override
  String get msgUnableToUpdateThisMonitor => '이 모니터를 업데이트할 수 없습니다.';

  @override
  String get msgUnableToValidateThisWatchOnlyWalletData =>
      '이 보기 전용 지갑 데이터를 검증할 수 없습니다.';

  @override
  String get msgWaitingForNetworkConfirmations => '네트워크 승인 대기 중';

  @override
  String get msgWalletActivityMonitor2 => '지갑 활동 모니터';

  @override
  String get msgXpubMonitor => 'xpub 모니터';

  @override
  String get msgZpubMonitor => 'zpub 모니터';

  @override
  String get msgWallet2 => '지갑';

  @override
  String get msgSecurity => '보안';

  @override
  String receiveAddressCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '수신 주소 $count개',
      one: '수신 주소 1개',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String get emergencyContactsHeadingFirstLine => '긴급';

  @override
  String get emergencyContactsHeadingSecondLine => '연락처';
}
