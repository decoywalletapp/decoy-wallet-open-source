// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get msgSaveBalanceToAccount => '将此余额保存到我的账户';

  @override
  String msgSaveBalanceToAccountPrompt(String amount) {
    return '将 $amount BTC 保存到此账户并在设备之间同步余额？如果此账户已有保存的余额，将保留该余额。';
  }

  @override
  String get msgAlreadyConfirmedYourEmail => '已经确认您的电子邮箱了吗？';

  @override
  String get msgCameraAccessRequiredForQrScan => '扫描二维码需要相机访问权限。您可以在设备设置中开启。';

  @override
  String get msgCouldNotOpenQrScanner => '无法打开二维码扫描器。请重试或粘贴文本。';

  @override
  String get msgComplete => ' % 已完成';

  @override
  String get msgControl => ' 控制';

  @override
  String get msgDaysLeft => ' 天剩余';

  @override
  String get msgSettingsControlCenter => ' 设置 > 控制中心';

  @override
  String get msgSignUpHere => ' 在此注册';

  @override
  String get msgAnd => ' 和 ';

  @override
  String get msgByNavigatingTo => ' 访问路径: ';

  @override
  String get msgOutlinedByDecoyWalletLlc => ' （由 DECOY WALLET LLC 制定）';

  @override
  String get msgSeconds => ' 秒';

  @override
  String get msg0TradedThisMonth => '本月交易额 \$0';

  @override
  String get msg1000ToNextLevel => '距下一等级还差 \$1,000';

  @override
  String get msg5551234567Or447700900123 => '(555) 123-4567 或 +44 7700 900123';

  @override
  String get msg15551234567Or33612 => '+1 555 123 4567 或 +33 6 12 34 56 78';

  @override
  String get msgEnterItBelowToVerifyYourPhoneNumber => '。请在下方输入以验证您的电话号码。';

  @override
  String get msg0Btc => '0 BTC';

  @override
  String get msg10kBtc => '10K BTC';

  @override
  String get msg123OceanDr => '123 Ocean Dr.';

  @override
  String get msg2MonthsFree => '免费 2 个月';

  @override
  String get msg911Trigger => '911 报警触发器';

  @override
  String get msgAccount => '账户';

  @override
  String get msgActivated => '已激活';

  @override
  String get msgArmToActivelyMonitorOutboundTransactions => '启用监控以主动监测转出交易';

  @override
  String get msgAcceptDecoySeedPhrase => '接受伪装助记词';

  @override
  String get msgAccountSubscriptionStatus => '账户订阅状态:  ';

  @override
  String get msgAccountSubscriptionAccessAndActiveStripeBilling =>
      '账户订阅使用权限及有效的 Stripe 计费';

  @override
  String get msgAcknowledgements => '确认事项';

  @override
  String get msgAddYourPhoneNumber => '添加您的电话号码';

  @override
  String get msgAddAWatchOnlyWalletKeyOrSpecific => '添加只读钱包密钥或特定收款地址，以监控转出活动。';

  @override
  String get msgAdjustBalance => '调整余额';

  @override
  String get msgAdvanced => '高级';

  @override
  String get msgAdvancedMonitorControls => '高级监控设置';

  @override
  String get msgAgreements => '同意事项';

  @override
  String get msgAllowSubscriptionAlertsDirectlyToYourDevice =>
      '允许向您的设备直接发送订阅提醒';

  @override
  String get msgAllowYourLocationToBeIncludedAutomaticallyDuring =>
      '允许在紧急情况下自动附上您的位置信息，以便可信联系人和应急人员更快采取行动。我们绝不会在后台跟踪位置，仅在紧急事件被触发时才会访问位置信息。';

  @override
  String get msgAlreadyHaveAnAccount => '已有账户？ ';

  @override
  String get msgAmount => '金额';

  @override
  String get msgApartmentUnitOptional => '公寓/单元号（可选）';

  @override
  String get msgAppLock => '应用锁';

  @override
  String get msgAppPreferencesAndConfigurations => '应用偏好与配置';

  @override
  String get msgApt4b => '4B 室';

  @override
  String get msgAutoWithdraw => '自动提现';

  @override
  String get msgAutoWithdrawBitcoin => '自动提取 Bitcoin';

  @override
  String get msgAutomaticallySendPurchasedBitcoinToYourWallet =>
      '自动将购买的 Bitcoin 转入您的钱包。';

  @override
  String get msgAwaitingConfirmations => '等待确认';

  @override
  String get msgBtc => 'BTC';

  @override
  String get msgBtcUsd => 'BTC/USD';

  @override
  String get msgBtcpayInvoiceInYourBrowser => '在浏览器中查看 BTCPay 账单';

  @override
  String get msgBiometricAuthentication => '生物识别认证';

  @override
  String get msgBiometricVerification => '生物识别验证';

  @override
  String get msgBitcoin => 'Bitcoin';

  @override
  String get msgBitcoinBalance => 'Bitcoin 余额';

  @override
  String get msgBitcoinPay => 'Bitcoin 支付';

  @override
  String get msgBitcoinAddressOrPaymentUri => 'Bitcoin 地址或支付 URI';

  @override
  String get msgBitcoinBalanceUpdated => 'Bitcoin 余额已更新。';

  @override
  String
      get msgBitcoinPaymentConfirmingFullProtectionActivatesAfterConfirmation =>
          'Bitcoin 付款确认中。确认后将启用全部保护功能。';

  @override
  String get msgBroadcastedToNetwork => '已广播至网络';

  @override
  String get msgByContinuingYouAgreeToReceiveAutomatedText =>
      '继续即表示您同意接收 Decoy Wallet 自动发送的短信，内容涉及您的账户、安全警报、紧急联系人状态、订阅提醒和钱包警报。\n短信发送频率不固定。可能产生短信及数据流量费用。\n回复 STOP 可退订。回复 HELP 可获取帮助。';

  @override
  String get msgByCreatingADecoyWalletYouAuthorizeDecoy =>
      '创建 Decoy Wallet 即表示您授权 Decoy Wallet，在您触发紧急事件时，向您选定的联系人发送由用户发起的一次性紧急警报。';

  @override
  String get msgCannotBeTheSameAsDecoyPin => '不能与伪装 PIN 相同';

  @override
  String get msgChooseAccess => '选择使用方式';

  @override
  String get msgComingSoon => '即将推出!!!';

  @override
  String get msgContacts => '联系人';

  @override
  String get msgCancelSubscription => '取消订阅';

  @override
  String get msgCenter => '中心';

  @override
  String get msgCenter2 => '中心 ';

  @override
  String get msgChangeAccountEntryPin => '更改账户访问 PIN';

  @override
  String get msgChangeTheseSettingsAnytimeInThe => '您可以随时在以下位置更改这些设置: ';

  @override
  String get msgCheckYourEmail => '请查收邮件';

  @override
  String get msgChooseFromContacts => '从通讯录中选择';

  @override
  String get msgChooseATargetPriceForYourNextBitcoin => '为下次购买 Bitcoin 选择目标价格。';

  @override
  String get msgChooseWord => '选择单词 ';

  @override
  String get msgCity => '城市';

  @override
  String get msgClickTheLinkInTheEmailToConfirm =>
      '点击邮件中的链接以确认您的账户。如果未看到邮件，请检查垃圾邮件文件夹。';

  @override
  String get msgCompleteTheRequiredDetailsToContinue => '请填写必填信息以继续。';

  @override
  String get msgConfigureBitcoinBalance => '设置 Bitcoin 余额';

  @override
  String get msgConfirm => '确认';

  @override
  String get msgConfirmDecoyPin => '确认伪装 PIN';

  @override
  String get msgConfirmPin => '确认 PIN';

  @override
  String get msgConfirmPassword => '确认密码';

  @override
  String get msgConfirmTransaction => '确认交易';

  @override
  String get msgConfirmNewPin => '确认新 PIN';

  @override
  String get msgConfirmNewPassword => '确认新密码';

  @override
  String get msgConfirmations => '确认次数';

  @override
  String get msgContact1 => '联系人 1';

  @override
  String get msgContact2 => '联系人 2';

  @override
  String get msgContact3 => '联系人 3';

  @override
  String get msgContact4 => '联系人 4';

  @override
  String get msgContact5 => '联系人 5';

  @override
  String get msgContactUs => '联系我们';

  @override
  String get msgContinue => '继续';

  @override
  String get msgControl2 => '控制';

  @override
  String get msgControlCenter => '控制中心';

  @override
  String get msgCouldNotOpenContactsEnterContactManually => '无法打开通讯录。请手动输入联系人。';

  @override
  String get msgCountry => '国家';

  @override
  String get msgCreateAccount => '创建账户';

  @override
  String get msgCreateEmergencyContacts => '添加紧急联系人';

  @override
  String get msgCreateYourPinToAccessYourDashboard => '创建用于访问控制面板的 PIN';

  @override
  String get msgCreateADecoyPinForEmergencyServices => '创建用于紧急服务的伪装 PIN';

  @override
  String get msgCreateAnAccount => '创建账户';

  @override
  String get msgCurrency => '货币';

  @override
  String get msgCurrentlyDisabledInDeviceSettings => '当前已在设备设置中禁用!!!';

  @override
  String get msgDeactivated => '已停用';

  @override
  String get msgDecoyEmergency => '伪装应急功能';

  @override
  String get msgDecoyPinCannotBeTheSameAsAccount => '伪装 PIN 不能与账户访问 PIN 相同';

  @override
  String get msgDecoySeed => '伪装种子';

  @override
  String get msgDecoyWalletBalance => 'Decoy Wallet 余额';

  @override
  String get msgDisable => '禁用';

  @override
  String get msgDecoyContacts => '伪装功能联系人';

  @override
  String get msgDecoyKeys => '伪装密钥';

  @override
  String get msgDecoyKeysTriggers => '伪装密钥触发器';

  @override
  String get msgDecoyPin => '伪装 PIN';

  @override
  String get msgDecoyPinTriggers => '伪装 PIN 触发器';

  @override
  String get msgDecoyWalletUsesNotificationsForSubscriptionAlertsDirectly =>
      'Decoy Wallet 使用通知功能，将订阅提醒直接发送至您的设备';

  @override
  String get msgDelete => '删除';

  @override
  String get msgDeleteUserAccount => '删除用户账户';

  @override
  String get msgDeleteMyAccount => '删除我的账户';

  @override
  String get msgDeletingYourDecoyWalletAccountWillPermanentlyRemove =>
      '删除 Decoy Wallet 账户将永久移除您的账户、紧急联系人、警报发送设置以及所有应用配置。与此账户关联的任何有效 Stripe 订阅都将先被取消。此操作无法撤销。';

  @override
  String get msgDidnTReceiveTheCode => '没有收到验证码？';

  @override
  String get msgDonTHaveAnAccount => '还没有账户？ ';

  @override
  String get msgEmergency => '紧急';

  @override
  String get msgEnable => '启用';

  @override
  String get msgEnterPin => '输入 PIN';

  @override
  String get msgEnterValidPhoneNumber => '请输入有效的电话号码';

  @override
  String get msgError001PleaseScreenshotContactDecoySupport =>
      '错误 #001 - 请截图并联系 Decoy 客服';

  @override
  String get msgError002PleaseScreenshotContactDecoySupport =>
      '错误 #002 - 请截图并联系 Decoy 客服';

  @override
  String get msgError003PleaseScreenshotContactDecoySupport =>
      '错误 #003 - 请截图并联系 Decoy 客服';

  @override
  String get msgError004PleaseScreenshotContactDecoySupport =>
      '错误 #004 - 请截图并联系 Decoy 客服';

  @override
  String get msgError005PleaseScreenshotContactDecoySupport =>
      '错误 #005 - 请截图并联系 Decoy 客服';

  @override
  String get msgError006PleaseScreenshotContactDecoySupport =>
      '错误 #006 - 请截图并联系 Decoy 客服';

  @override
  String get msgError008PleaseScreenshotContactDecoySupport =>
      '错误 #008 - 请截图并联系 Decoy 客服';

  @override
  String get msgError009PleaseScreenshotContactDecoySupport =>
      '错误 #009 - 请截图并联系 Decoy 客服';

  @override
  String get msgError010PleaseScreenshotContactDecoySupport =>
      '错误 #010 - 请截图并联系 Decoy 客服';

  @override
  String get msgError011PleaseScreenshotContactDecoySupport =>
      '错误 #011 - 请截图并联系 Decoy 客服';

  @override
  String get msgError012PleaseScreenshotContactDecoySupport =>
      '错误 #012 - 请截图并联系 Decoy 客服';

  @override
  String get msgError013PleaseScreenshotContactDecoySupport =>
      '错误 #013 - 请截图并联系 Decoy 客服';

  @override
  String get msgError014PleaseScreenshotContactDecoySupport =>
      '错误 #014 - 请截图并联系 Decoy 客服';

  @override
  String get msgError015PleaseScreenshotContactDecoySupport =>
      '错误 #015 - 请截图并联系 Decoy 客服';

  @override
  String get msgError016PleaseScreenshotContactDecoySupport =>
      '错误 #016 - 请截图并联系 Decoy 客服';

  @override
  String get msgError020PleaseScreenshotContactDecoySupport =>
      '错误 #020 - 请截图并联系 Decoy 客服';

  @override
  String get msgError021PleaseScreenshotContactDecoySupport =>
      '错误 #021 - 请截图并联系 Decoy 客服';

  @override
  String get msgError024PleaseScreenshotContactDecoySupport =>
      '错误 #024 - 请截图并联系 Decoy 客服';

  @override
  String get msgError025PleaseScreenshotContactDecoySupport =>
      '错误 #025 - 请截图并联系 Decoy 客服';

  @override
  String get msgError029PleaseScreenshotContactDecoySupport =>
      '错误 #029 - 请截图并联系 Decoy 客服';

  @override
  String get msgError030PleaseScreenshotContactDecoySupport =>
      '错误 #030 - 请截图并联系 Decoy 客服';

  @override
  String get msgEta => '预计完成时间';

  @override
  String get msgEmail => '电子邮箱';

  @override
  String get msgEmailRequired => '请填写电子邮箱！';

  @override
  String get msgEmergencyContacts => '紧急联系人';

  @override
  String get msgEmergencyContactsTrigger => '紧急联系人通知触发器';

  @override
  String
      get msgEmergencyAlertsWalletMonitoringAndEmergencyContactNotifications =>
          '紧急警报、钱包监控和紧急联系人通知功能需要有效的付费订阅。';

  @override
  String get msgEmergencyContactsAndAlertSettings => '紧急联系人及警报设置';

  @override
  String get msgEmergencyContactsReceiveAlertsOnlyBecauseYouVoluntarily =>
      '紧急联系人收到警报，仅因为您自愿提供了他们的电话号码。\n\n根据隐私政策的说明，信息可能会与紧急服务提供方或第三方共享。';

  @override
  String get msgEnableBiometricAuthentication => '启用生物识别认证';

  @override
  String get msgEnableCurrentLocation => '启用当前位置';

  @override
  String get msgEnableLocationServices => '启用\n定位服务';

  @override
  String get msgEnableLocationServices2 => '启用定位服务';

  @override
  String get msgEnablePushNotifications => '启用\n推送通知';

  @override
  String get msgEnablePushNotifications2 => '启用推送通知';

  @override
  String get msgEnter => '输入';

  @override
  String get msgEnterCurrentAccountEntryPin => '输入当前账户访问 PIN';

  @override
  String get msgEnterManually => '手动输入';

  @override
  String get msgEnterVerificationCode => '输入验证码';

  @override
  String get msgEnterA48DigitDecoyPin => '输入 4 - 8 位伪装 PIN ';

  @override
  String get msgEnterA48DigitPinToSecure => '输入 4 - 8 位 PIN 以保护您的账户';

  @override
  String get msgEnterANewPinToAccessYourAccount => '输入用于访问账户的新 PIN';

  @override
  String get msgEnterAnyValueFrom0To21000 => '输入 0 至 21,000,000 BTC 之间的任意值';

  @override
  String get msgEnterEmail => '输入电子邮箱';

  @override
  String get msgEnterFirstName => '输入名字';

  @override
  String get msgEnterLastName => '输入姓氏';

  @override
  String get msgEnterNewPassword => '输入新密码';

  @override
  String get msgEnterTheAmountYouWantToSend => '输入您要发送的金额';

  @override
  String get msgEnterTheCurrentPinYouUseToAccess => '输入您当前用于访问账户的 PIN';

  @override
  String get msgEnterTheSame48DigitsToConfirm => '输入相同的 4 - 8 位数字以确认您的伪装 PIN';

  @override
  String get msgEnterTheSame48DigitsToConfirm2 => '输入相同的 4 - 8 位数字以确认您的访问 PIN';

  @override
  String get msgEnterYourEmail => '输入您的电子邮箱...';

  @override
  String get msgEnterYourEventCodeInYourBrowser => '在浏览器中输入您的活动代码';

  @override
  String get msgExactBitcoinAmount => '准确的 Bitcoin 金额';

  @override
  String get msgFl => 'FL';

  @override
  String get msgFollowDecoyWallet => '关注 Decoy Wallet';

  @override
  String get msgFirstName => '名字';

  @override
  String get msgFixTheMoneyFixTheWorld => '让货币回归正轨，让世界变得更好。';

  @override
  String get msgFlexibleAccess => '灵活的使用方式';

  @override
  String get msgForgotPassword => '忘记密码';

  @override
  String get msgForgotPassword2 => '忘记密码？';

  @override
  String get msgGenerated => '已生成';

  @override
  String get msgGenerateSeedPhrase => '生成助记词';

  @override
  String get msgGetPaidInBitcoin => '以 Bitcoin 领取工资';

  @override
  String get msgHomeAddress => '家庭住址';

  @override
  String get msgHowToChangeAccountEntryPin => '如何更改账户访问 PIN';

  @override
  String get msgHowToChangeDecoyKeys => '如何更改伪装密钥';

  @override
  String get msgHowToChangeDecoyPin => '如何更改伪装 PIN';

  @override
  String get msgHowToChangePhoneNumber => '如何更改电话号码';

  @override
  String get msgHowToChangeYourEmail => '如何更改电子邮箱';

  @override
  String get msgHowToDeleteUserAccount => '如何删除用户账户';

  @override
  String get msgHowToEnterContactInformation => '如何输入联系信息';

  @override
  String get msgHowToManageControlCenter => '如何管理控制中心';

  @override
  String get msgIAgreeToThe => '我同意 ';

  @override
  String get msgIUnderstandDecoyPinAlertsRelyOnMy =>
      '我理解，伪装 PIN 警报依赖于我的设备权限、网络连接和已保存的警报设置，我有责任确保这些设置随时可用并保持更新。';

  @override
  String get msgIUnderstandDecoySeedAlertsAreDesignedFor =>
      '我理解，伪装种子警报旨在监测已启用监控的伪装种子钱包的链上活动，我有责任确保种子警报设置随时可用并保持更新。';

  @override
  String get msgIUnderstandThatDecoyWalletDoesNotHold =>
      '我理解，Decoy Wallet 不持有或保护我的资金，也无法防止损失，对于使用或误用此功能所导致的任何后果，我将承担全部责任。';

  @override
  String get msgIUnderstandThatEnteringMyDecoyPinWill =>
      '我理解，输入伪装 PIN 将激活紧急触发器，并可能通知我的紧急联系人、第三方服务或公共安全机构。';

  @override
  String get msgIUnderstandThatUsingMyDecoyWalletMay =>
      '我理解，使用 Decoy Wallet 可能会触发向我的联系人、第三方服务或公共安全机构发送的紧急警报。';

  @override
  String get msgIUnderstandThisActionIsPermanentAndCannot =>
      '我理解，此操作是永久性的，无法撤销';

  @override
  String get msgIUnderstandThisFeatureIsOnlyForReal =>
      '我理解，此功能仅适用于真实的紧急情况，对于误用造成的虚假警报、费用或后果，我将承担责任。';

  @override
  String get msgInactive => '未激活';

  @override
  String get msgIncorrectPin => 'PIN 错误';

  @override
  String get msgInvalidLogin => '登录信息无效';

  @override
  String get msgInvalidPasswordMustBeAtLeast10Characters =>
      '密码无效 - 必须至少包含 10 个字符';

  @override
  String get msgInvalidPhoneNumber => '电话号码无效';

  @override
  String get msgInvalidPinTryAgain => 'PIN 无效 - 请重试';

  @override
  String get msgImportantToEnableTheDecoyPinFeatureYou =>
      '重要提示：要启用伪装 PIN 功能，您必须确认以下所有声明。\n如果有任何一项声明您不同意，请勿继续。';

  @override
  String get msgInstagram => 'Instagram';

  @override
  String get msgInvalidCodePleaseTryAgain => '验证码无效。请重试。';

  @override
  String get msgLegal => '法律信息';

  @override
  String get msgLive => '实时';

  @override
  String get msgLastName => '姓氏';

  @override
  String get msgLetSGetStartedByFillingOutThe => '请先填写下方表单。';

  @override
  String get msgLimitOrder => '限价单';

  @override
  String get msgLocationServices => '定位服务';

  @override
  String get msgLogOut => '退出登录';

  @override
  String get msgLogIn => '登录';

  @override
  String get msgManageAccess => '管理使用权限';

  @override
  String get msgMethod => '方式';

  @override
  String get msgMustBeAtLeast4Digits => '必须至少为 4 位数字';

  @override
  String get msgManageYourWalletPreferencesAndSession => '管理您的钱包偏好和会话。';

  @override
  String get msgManualAddress => '手动输入地址';

  @override
  String get msgMasterStatus => '总体状态:';

  @override
  String get msgMessage => '消息 ';

  @override
  String get msgMiamiBeach => '迈阿密海滩';

  @override
  String get msgMonitorExistingWallet => '监控现有钱包';

  @override
  String get msgMonitorStatus => '监控状态:';

  @override
  String get msgMonthly => '每月';

  @override
  String get msgMySubscription => '我的订阅';

  @override
  String get msgNotQuiteTryAgain => '不太正确 - 请重试';

  @override
  String get msgNetwork => '网络';

  @override
  String get msgNetworkFee => '网络手续费';

  @override
  String get msgNetworkProgress => '网络进度';

  @override
  String get msgNext => '下一步';

  @override
  String get msgNoDecoyKeysMonitorsFoundYet => '尚未找到伪装密钥监控项。';

  @override
  String get msgOpenDeviceSettings => '打开设备设置';

  @override
  String get msgOrderDetails => '订单详情';

  @override
  String get msgPasswordUpdateFailedTryADifferentPassword => '密码更新失败 - 请尝试其他密码';

  @override
  String get msgPasswordsDoNotMatch => '密码不一致';

  @override
  String get msgPasswordsDoNotMatchTryAgain => '密码不一致 - 请重试';

  @override
  String get msgPhoneNumberAlreadyInUse => '该电话号码已被使用';

  @override
  String get msgPinMustBeAtLeast4Digits => 'PIN 必须至少为 4 位数字';

  @override
  String get msgPinsDidNotMatchTryAgain => '两次输入的 PIN 不一致 - 请重试';

  @override
  String get msgPinsDoNotMatchPleaseTryAgain => 'PIN 不一致 - 请重试';

  @override
  String get msgPleaseEnterAtLeast4Digits => '请输入至少 4 位数字';

  @override
  String get msgPleaseEnterAtLeast4DigitsToContinue => '请输入至少 4 位数字以继续';

  @override
  String get msgPleaseEnterAtLeastFourDigits => '请输入至少 4 位数字';

  @override
  String get msgProgress => '进度';

  @override
  String get msgPassword => '密码';

  @override
  String get msgPasswordMustBeAtLeast10Characters => '密码必须至少包含 10 个字符';

  @override
  String get msgPasteOnlyWatchOnlyPublicDataNeverPaste =>
      '请仅粘贴只读公开数据。切勿粘贴助记词、私钥、xprv 或 zprv。';

  @override
  String get msgPasteOrEnterWalletAddress => '粘贴或输入钱包地址';

  @override
  String get msgPayForDecoyWithBitcoin => '使用 Bitcoin 支付 Decoy Wallet 费用';

  @override
  String get msgPayForDecoyWithCreditCard => '使用信用卡支付 Decoy Wallet 费用';

  @override
  String get msgPayWithBitcoin => '使用 Bitcoin 支付';

  @override
  String get msgPayWithCard => '使用银行卡支付';

  @override
  String get msgPaymentSetup => '支付设置';

  @override
  String get msgPersonalContact => '私人联系人';

  @override
  String get msgPhoneNumber => '电话号码';

  @override
  String get msgPhoneNumberCountryCode => '电话号码（+国家代码）';

  @override
  String get msgPlaceALimitOrder => '提交限价单';

  @override
  String get msgPleaseAuthenticateToEnableBiometricUnlockForDecoy =>
      '请完成身份验证以启用 Decoy Wallet 的生物识别解锁';

  @override
  String get msgPleaseAuthenticateToUnlockYourWallet => '请完成身份验证以解锁钱包';

  @override
  String get msgPrimal => 'Primal';

  @override
  String get msgPrivacy => '隐私';

  @override
  String get msgPrivacyPolicy => '隐私政策';

  @override
  String get msgPurchaseSchedule => '购买计划';

  @override
  String get msgPushNotifications => '推送通知';

  @override
  String get msgQuizTime => '验证小测验！';

  @override
  String get msgResetPasswordEmailSent => '密码重置邮件已发送';

  @override
  String get msgReceive => '接收';

  @override
  String get msgReceivePartOfYourPaycheckDirectlyInBitcoin =>
      '直接以 Bitcoin 领取部分工资。';

  @override
  String get msgRecipientQr => '收款人二维码';

  @override
  String get msgRecurringBuy => '定期购买';

  @override
  String get msgRedeemCode => '兑换代码';

  @override
  String get msgRefresh => '刷新';

  @override
  String get msgResendCode => '重新发送验证码';

  @override
  String get msgRetry => '重试';

  @override
  String get msgReturnToHome => '返回首页';

  @override
  String get msgReviewDetailsBeforeBroadcast => '广播前检查详情';

  @override
  String get msgRumble => 'Rumble';

  @override
  String get msgSafetySupport => '安全与支持';

  @override
  String get msgSetup => '设置';

  @override
  String get msgSmsTerms => '短信条款';

  @override
  String get msgSupportTicket => '客服工单';

  @override
  String get msgSaveExit => '保存并退出';

  @override
  String get msgSaveGoBack => '保存并返回';

  @override
  String get msgSaveGoHome => '保存并返回首页';

  @override
  String get msgSavePhoneNumber => '保存电话号码';

  @override
  String get msgScan => '扫描';

  @override
  String get msgScanOrPasteARecipientAddress => '扫描或粘贴收款地址';

  @override
  String get msgSee => '查看 ';

  @override
  String get msgSend => '发送';

  @override
  String get msgSendAmount => '发送金额';

  @override
  String get msgSendBitcoin => '发送 Bitcoin';

  @override
  String get msgSendFunds => '发送资金';

  @override
  String get msgSendLink => '发送链接';

  @override
  String get msgSendMax => '发送全部';

  @override
  String get msgSet => '设置';

  @override
  String get msgSetUpDecoyKeys => '设置伪装密钥';

  @override
  String get msgSetARecurringBuy => '设置定期购买';

  @override
  String get msgSetAScheduleForAutomaticBitcoinPurchases =>
      '设置自动购买 Bitcoin 的计划。';

  @override
  String get msgSettingUpYourDecoyKeys => '设置您的伪装密钥';

  @override
  String get msgSettingUpYourDecoyPin => '设置您的伪装 PIN';

  @override
  String get msgSettings => '设置';

  @override
  String get msgSettingsControlCenter2 => '设置 > 控制中心';

  @override
  String get msgSignInHere => '在此登录';

  @override
  String get msgSignedInDevice => '已登录的设备';

  @override
  String get msgSkipForNow => '暂时跳过';

  @override
  String get msgSlideForAQuickEstimateOrEnterAn => '滑动以快速估算，或在下方输入准确金额。';

  @override
  String get msgSlideToSignAndSend => '滑动以签名并发送';

  @override
  String get msgState => '州';

  @override
  String get msgStatus => '状态';

  @override
  String get msgStatus2 => '状态: ';

  @override
  String get msgStreetAddress => '街道地址';

  @override
  String get msgStripeCheckoutInYourBrowser => '在浏览器中通过 Stripe 结账';

  @override
  String get msgStripeWillTakeOverOn => 'Stripe 将开始接续收费，日期为:  ';

  @override
  String get msgSubject => '主题 ';

  @override
  String get msgSubmitTicket => '提交工单';

  @override
  String get msgSubscriptionRequiredToChangeValues => '更改数值需要订阅';

  @override
  String get msgSupportTicketSentToDecoyTeam => '客服工单已发送至 Decoy 团队';

  @override
  String get msgSwitchValue => '开关值:';

  @override
  String get msgSyncMarket => '同步市场价格';

  @override
  String get msgSystemStatus => '系统状态:';

  @override
  String get msgTimeToGetAccess => '开始使用吧！';

  @override
  String get msgTapToOpenQrScanner => '点击打开二维码扫描器';

  @override
  String get msgTerms => '条款';

  @override
  String get msgTermsConditions => '条款与条件';

  @override
  String get msgTermsOfService => '服务条款';

  @override
  String get msgTermsOfUse => '使用条款';

  @override
  String get msgThisActionIsPermanent => '此操作是永久性的';

  @override
  String get msgThisSeedPhraseWillNotBeStoredOn => '此助记词不会保存在本设备上。请将其写下并妥善保管。';

  @override
  String get msgTitleTheProblemYouAreExperiencing => '为您遇到的问题填写标题';

  @override
  String get msgTo => '收款方';

  @override
  String get msgToAddress => '收款地址';

  @override
  String get msgToggleOnToEnableDecoyPinToContact => '打开开关，允许伪装 PIN 通知紧急联系人';

  @override
  String get msgTotalAmount => '总金额';

  @override
  String get msgTransactionComplete => '交易完成';

  @override
  String get msgTransactionInitiated => '交易已发起';

  @override
  String get msgTriggerDecoyKeysAlerts => '触发伪装密钥警报';

  @override
  String get msgTriggerDecoyPinAlerts => '触发伪装 PIN 警报';

  @override
  String get msgTriggerStatus => '触发器状态:';

  @override
  String get msgTutorials => '使用教程';

  @override
  String get msgUsa => '美国';

  @override
  String get msgUnlockDecoyWallet => '解锁 Decoy Wallet';

  @override
  String get msgUpdatePassword => '更新密码';

  @override
  String get msgUseFingerprintOrFaceRecognitionForSecureAccess =>
      '使用指纹或面部识别进行安全访问';

  @override
  String get msgUseXpubForLegacy1AddressWalletsZpub =>
      '地址以 1 开头的传统钱包请使用 xpub，地址以 bc1 开头的原生 SegWit 钱包请使用 zpub，或粘贴特定的收款地址。';

  @override
  String get msgUseYourFingerprintOrFaceIdToQuickly =>
      '使用指纹或 Face ID 快速、安全地访问您的账户';

  @override
  String get msgUseYourLocationToSupportEmergencyAlerts => '使用您的位置信息辅助紧急警报';

  @override
  String get msgUsingADecoyPinWillTriggerEmergencyBehavior =>
      '使用伪装 PIN 将触发 Decoy Wallet 内的紧急响应行为，包括通知联系人或紧急服务机构。\n\n此功能仅用于真实的受胁迫情况。';

  @override
  String get msgVerifyingPleaseWait => '正在验证... 请稍候！';

  @override
  String get msgWallet => '钱包';

  @override
  String get msgWalletActivityMonitor => '钱包活动监控';

  @override
  String get msgWalletSeedPhrasesAndPrivateKeys => '钱包助记词和私钥';

  @override
  String get msgWatchOnlyWalletImportIsAvailableInEnabled =>
      '只读钱包导入功能仅在已启用该功能的测试版本中可用。';

  @override
  String get msgWeSentA6DigitCodeTo => '我们已发送 6 位验证码至 ';

  @override
  String get msgWeWillSendYouAnEmailWithA =>
      '我们将向您发送包含密码重置链接的邮件。请在下方输入与您账户关联的电子邮箱。';

  @override
  String get msgWeReHereToHelpSubmitASupport => '我们随时为您提供帮助！请提交客服工单，我们会尽快回复您。';

  @override
  String get msgWeVeSentAConfirmationLinkTo => '我们已将确认链接发送至:';

  @override
  String get msgWebsite => '网站';

  @override
  String get msgWelcomeBack => '欢迎回来';

  @override
  String get msgWhatWillBeDeleted => '将删除的内容';

  @override
  String get msgWhatWillNotBeDeleted => '不会删除的内容';

  @override
  String get msgWithdrawalSettings => '提现设置';

  @override
  String get msgWriteADetailedDescriptionOfTheProblemYou => '请详细描述您遇到的问题';

  @override
  String get msgYourDecoySeed => '您的伪装种子';

  @override
  String get msgYearly => '每年';

  @override
  String get msgYouCanRequestANewCodeIn => '距离可重新获取验证码还需 ';

  @override
  String get msgYouMayAlsoReachOutTo => '您也可以联系 ';

  @override
  String get msgYoutube => 'YouTube';

  @override
  String get msgYourBitcoinFundsRemainSafeInYourExternal =>
      '您的 Bitcoin 资金仍安全地保存在外部钱包中';

  @override
  String get msgYourDecoyWalletAccountAndProfile => '您的 Decoy Wallet 账户和个人资料';

  @override
  String get msgYourEmailAddress => '您的电子邮箱地址...';

  @override
  String get msgZipCode => '邮政编码';

  @override
  String get msgByNavigatingTo2 => '访问路径: ';

  @override
  String get msgForFurtherAssistance => '以获取进一步帮助';

  @override
  String get msgZpubXpubOrReceiveAddresses => 'zpub、xpub 或收款地址';

  @override
  String get msgZpubOrBc1qBc1p1 => 'zpub...\n\n或\nbc1q...\nbc1p...\n1...';

  @override
  String get msgItcoinWallet => '₿itcoin 钱包';

  @override
  String get msgLanguage => '语言';

  @override
  String get msgUseDeviceLanguage => '使用设备语言';

  @override
  String get msgCouldNotSaveYourLanguagePleaseTryAgain => '无法保存语言设置。请重试。';

  @override
  String get msgDone => '完成';

  @override
  String get msg394Month => '\$3.94 / 月';

  @override
  String get msg3942Year => '\$39.42 / 年';

  @override
  String get msg499Month => '\$4.99 / 月';

  @override
  String get msg4728Year => '\$47.28 / 年';

  @override
  String get msg4990Year => '\$49.90 / 年';

  @override
  String get msg5988Year => '\$59.88 / 年';

  @override
  String get msgAmountExceedsAvailableBalance => '金额超过可用余额';

  @override
  String get msgAccountLevelSeedWalletMonitoring => '账户级种子钱包监控';

  @override
  String get msgActive => '已启用';

  @override
  String get msgAsset => '资产';

  @override
  String get msgAwaitingConfirmation => '等待确认';

  @override
  String get msgBalanceCannotBeNegative => '余额不能为负数。';

  @override
  String get msgBitcoinMainnet => 'Bitcoin 主网';

  @override
  String get msgBlock => '区块';

  @override
  String get msgBroadcast => '广播';

  @override
  String get msgBroadcasted => '已广播';

  @override
  String get msgBroadcasting => '正在广播';

  @override
  String get msgBroadcastingTransaction => '正在广播交易';

  @override
  String get msgBuy => '购买';

  @override
  String get msgCancel => '取消';

  @override
  String get msgCardPaymentsScheduled => '已安排银行卡付款';

  @override
  String get msgComplete2 => '完成';

  @override
  String get msgConfirmationLinkSent => '确认链接已发送';

  @override
  String get msgConfirmed => '已确认';

  @override
  String get msgConfirmedOnTheBitcoinNetwork => '已在 Bitcoin 网络上确认';

  @override
  String get msgDecoyKeys2 => '伪装密钥';

  @override
  String get msgDecoyKeysReady => '伪装密钥已就绪';

  @override
  String get msgDecoyKeysMonitor => '伪装密钥监控';

  @override
  String get msgDenied => '已拒绝';

  @override
  String get msgDepositAsset => '存入资产';

  @override
  String get msgEnter21000000BtcOrLess => '请输入不超过 21,000,000 BTC 的金额。';

  @override
  String get msgEnterAValidBtcAmount => '请输入有效的 BTC 金额。';

  @override
  String get msgEveryPayday => '每个发薪日';

  @override
  String get msgFrequency => '频率';

  @override
  String get msgGenerateANewDecoySeedPhraseOrMonitor =>
      '生成新的伪装助记词，或监控您已掌控的只读钱包数据。';

  @override
  String get msgGenerateANewDecoySeedPhraseToMonitor => '生成新的伪装助记词，以监控钱包的转出活动。';

  @override
  String get msgInMempool => '已进入内存池';

  @override
  String get msgLive2 => '实时';

  @override
  String get msgManageCardPayments => '管理银行卡付款';

  @override
  String get msgMempool => '内存池';

  @override
  String get msgMostRecentDecoySeedGenerated => '最近生成的伪装种子';

  @override
  String get msgNotConfigured => '未配置';

  @override
  String get msgNotSelected => '未选择';

  @override
  String get msgNotSent => '未发送';

  @override
  String get msgOptedOut => '已退订';

  @override
  String get msgOrderType => '订单类型';

  @override
  String get msgPaste => '粘贴';

  @override
  String get msgPasteAZpubXpubOrOneOrMore =>
      '粘贴 zpub、xpub 或一个或多个 Bitcoin 收款地址。';

  @override
  String get msgPaymentMethod => '支付方式';

  @override
  String get msgPending => '待处理';

  @override
  String get msgPleaseSignInAgainToManageDecoyKeys => '请重新登录以管理伪装密钥。';

  @override
  String get msgPleaseSignInAgainToSaveMonitorChanges => '请重新登录以保存监控更改。';

  @override
  String get msgReady => '就绪';

  @override
  String get msgReceiveAddressMonitor => '收款地址监控';

  @override
  String get msgRelayingTransactionToBitcoinPeers => '正在向 Bitcoin 对等节点转发交易';

  @override
  String get msgRenewBitcoinPayments => '使用 Bitcoin 续费';

  @override
  String get msgResendConfirmationLink => '重新发送确认链接';

  @override
  String get msgSeenByPeersAndWaitingForTheNext => '对等节点已接收，正在等待下一个区块';

  @override
  String get msgSendConfirmationLink => '发送确认链接';

  @override
  String get msgSettlement => '结算';

  @override
  String get msgSigning => '正在签名';

  @override
  String get msgSigningAndRelayingToBitcoinPeers => '正在签名并转发至 Bitcoin 对等节点';

  @override
  String get msgStackMoreDays => '增加使用天数';

  @override
  String get msgSwitchToBitcoinPayments => '切换为 Bitcoin 付款';

  @override
  String get msgSwitchToCardPayments => '切换为银行卡付款';

  @override
  String get msgSyncing => '正在同步';

  @override
  String get msgThisDevice => '此设备';

  @override
  String get msgThisWalletOrReceiveAddressIsAlreadyBeing => '此钱包或收款地址已在监控中。';

  @override
  String get msgTransactionBroadcast => '交易广播';

  @override
  String get msgTransactionConfirmed => '交易已确认';

  @override
  String get msgTransactionRelayedAndPendingInclusion => '交易已转发，等待纳入区块';

  @override
  String get msgTxId => '交易 ID';

  @override
  String get msgUsdBalance => 'USD 余额';

  @override
  String get msgUsdEstimateUnavailable => '无法获取 USD 估值';

  @override
  String get msgUnableToCheckWhetherThisWalletIsAlready =>
      '无法检查此钱包是否已在监控中。请重试。';

  @override
  String get msgUnableToDeleteThisMonitor => '无法删除此监控项。';

  @override
  String get msgUnableToLoadDecoyKeysMonitors => '无法加载伪装密钥监控项。';

  @override
  String get msgUnableToSaveDecoyKeysMonitorChanges => '无法保存伪装密钥监控更改。';

  @override
  String get msgUnableToUpdateDecoyKeysMonitors => '无法更新伪装密钥监控项。';

  @override
  String get msgUnableToUpdateThisMonitor => '无法更新此监控项。';

  @override
  String get msgUnableToValidateThisWatchOnlyWalletData => '无法验证此只读钱包数据。';

  @override
  String get msgWaitingForNetworkConfirmations => '等待网络确认';

  @override
  String get msgWalletActivityMonitor2 => '钱包活动监控';

  @override
  String get msgXpubMonitor => 'xpub 监控';

  @override
  String get msgZpubMonitor => 'zpub 监控';

  @override
  String get msgWallet2 => '钱包';

  @override
  String get msgSecurity => '安全';

  @override
  String receiveAddressCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个收款地址',
      one: '1 个收款地址',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String get emergencyContactsHeadingFirstLine => '紧急';

  @override
  String get emergencyContactsHeadingSecondLine => '联系人';
}
