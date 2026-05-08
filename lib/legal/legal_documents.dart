// Centralized legal copy provided by Decoy Wallet counsel.
// Keep onboarding and settings pages pointed at these constants so they stay in sync.

import 'package:flutter/material.dart';

class LegalDocumentParagraph {
  const LegalDocumentParagraph(
    this.runs, {
    this.textAlign = TextAlign.start,
    this.isBullet = false,
  });

  final List<LegalDocumentRun> runs;
  final TextAlign textAlign;
  final bool isBullet;
}

class LegalDocumentRun {
  const LegalDocumentRun(
    this.text, {
    this.isBold = false,
  });

  final String text;
  final bool isBold;
}

const List<LegalDocumentParagraph> kDecoyWalletTermsOfServiceParagraphs =
    <LegalDocumentParagraph>[
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DECOY WALLET''', isBold: true),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''TERMS OF SERVICE AGREEMENT''', isBold: true),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Effective Date: May 8, 2026'''),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The Decoy Wallet mobile application and its associated services, website, software, and content (collectively "App" or "Services") is owned and operated by Decoy Wallet LLC, a Michigan limited liability company ("Decoy Wallet," "our," "us," "we"). Decoy Wallet has adopted this Terms of Service Agreement ("Agreement") to inform you ("User(s)") of your rights and duties when using the App and Services. If you do not agree with the terms and conditions of this Agreement, you are expressly prohibited from using the App and Services and must discontinue your use immediately.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''PLEASE READ THIS AGREEMENT CAREFULLY BEFORE ACCESSING OR USING THE APP AND ASSOCIATED SERVICES. BY ACCESSING OR USING THE APP, YOU AGREE TO BE BOUND BY THE TERMS AND CONDITIONS OF THIS AGREEMENT. THESE TERMS CONTAIN AN ARBITRATION AGREEMENT AND WAIVER OF JURY TRIAL. PLEASE READ THEM CAREFULLY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''DECOY WALLET MAY, FROM TIME TO TIME, AND RESERVES THE RIGHT, IN ITS SOLE AND ABSOLUTE DISCRETION, TO MODIFY, LIMIT, CHANGE, DISCONTINUE, OR REPLACE THE APP AND SERVICES OR THIS AGREEMENT. YOUR USE OF THE APP AND SERVICES AFTER SAID MODIFICATION CONSTITUTES YOUR MANIFESTATION OF ASSENT.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DEFINITIONS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''As used in this Agreement:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Account" means a Registered User's account with the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"App" means the Decoy Wallet mobile application, including all software, features, and associated content.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Blockchain Wallet" means a self-custodied, user-controlled cryptocurrency wallet accessed through a third-party application, extension, or hardware device. Decoy Wallet does not provide, control, or custody Blockchain Wallets.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Decoy Wallet Features" means the monitoring, alerting, and duress notification functionality provided through the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Duress PIN" means a user-defined personal identification number that, when entered into the App, triggers an automated alert to designated Emergency Contacts.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Emergency Contact(s)" means one or more individuals designated by a Registered User to receive automated alert notifications in connection with the Duress and Alert Features.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Registered User(s)" means Users who have created an account to use and access the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Services" means all functionality, features, and content provided through the App, including the Duress PIN feature, Emergency Contact alert system, wallet activity monitoring, simulated transaction functionality, and SMS communications.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Wallet Address" means the public blockchain address provided by a User solely for wallet activity monitoring within the App. Decoy Wallet does not access, store, or control private keys, seed phrases, or any cryptographic credentials associated with any Wallet Address.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"User(s)" means all individuals that download, install, or access the App or Services, including Registered Users.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"You / Your / You're" refers to the individual User accessing or using the App or Services.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''ABOUT THE APP''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet is a mobile application designed to provide users with personal safety monitoring and alert tools in connection with cryptocurrency wallet activity and duress scenarios. The App enables users to configure wallet activity monitoring, designate Emergency Contacts, establish a Duress PIN, and receive or send alerts based on user-defined triggers.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet does not function as a cryptocurrency exchange, custodian, broker, money transmitter, or financial services provider. The App does not hold, transmit, or control any cryptocurrency or digital assets. All wallet interactions are user-controlled and occur through third-party platforms and blockchain networks independent of Decoy Wallet.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NATURE OF SERVICE; NO CUSTODY; NO FINANCIAL CONTROL''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Monitoring and Alert Tool Only.  Decoy Wallet is a personal safety monitoring and alert tool. THE APP IS NOT A FINANCIAL SERVICES PRODUCT, EXCHANGE, CUSTODIAN, OR WALLET PROVIDER.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''No Custody of Digital Assets.  ''', isBold: true),
    LegalDocumentRun(
        r'''Decoy Wallet does not hold, transmit, control, custody, receive, or transfer any cryptocurrency or digital assets on behalf of any User. The App does not access, store, or interact with any User's private keys, seed phrases, or cryptographic credentials. All wallet functionality is entirely user-controlled and dependent on third-party applications and blockchain networks outside of Decoy Wallet's control.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Simulated Transactions.  ''', isBold: true),
    LegalDocumentRun(
        r'''Certain features of the App may include a "simulated transaction" capability. SIMULATED TRANSACTIONS ARE NOT ACTUAL BLOCKCHAIN TRANSACTIONS AND DO NOT RESULT IN THE TRANSFER, MOVEMENT, OR SECURING OF ANY CRYPTOCURRENCY OR DIGITAL ASSETS. Simulated transactions are informational and demonstrative only. Decoy Wallet makes no representation that simulated transactions will prevent theft, coercion, or loss of digital assets.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''No Guarantee of Fund Protection or Recovery.  ''',
        isBold: true),
    LegalDocumentRun(
        r'''Decoy Wallet does not guarantee, warrant, or represent that use of the App will protect, preserve, secure, recover, or assist in the recovery of any digital assets or funds. All blockchain transactions are irreversible.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Regulatory Status.  ''', isBold: true),
    LegalDocumentRun(
        r'''Decoy Wallet is not a money services business, money transmitter, broker-dealer, investment adviser, or financial institution. Nothing in the App or this Agreement constitutes financial, investment, or legal advice.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DURESS FEATURE; ASSUMPTION OF RISK''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Duress PIN — User-Initiated Signaling Only.  ''',
        isBold: true),
    LegalDocumentRun(
        r'''The Duress PIN feature is a user-initiated signaling mechanism. Entry of a Duress PIN triggers automated alerts to designated Emergency Contacts as configured by the User. THE DURESS PIN FEATURE DOES NOT VERIFY, CONFIRM, OR ASSESS WHETHER AN ACTUAL EMERGENCY OR DANGER EXISTS.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''System Limitations.  ''', isBold: true),
    LegalDocumentRun(
        r'''You acknowledge and understand that the Duress and Alert Systems:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''May fail to trigger due to technical errors, network outages, device failures, carrier interruptions, or other causes;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''May trigger falsely or erroneously due to user error, application malfunction, or other causes;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''May experience delays in delivery of alerts to Emergency Contacts;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Do not guarantee that Emergency Contacts will receive, view, or act upon any alert; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Do not guarantee contact with or response by law enforcement, emergency services, or any other authority.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''No Guarantee of Safety.  DECOY WALLET DOES NOT GUARANTEE YOUR PERSONAL SAFETY OR THE SAFETY OF ANY OTHER PERSON. THE APP IS NOT A SUBSTITUTE FOR CALLING 911 OR OTHER EMERGENCY SERVICES DIRECTLY. YOU SHOULD CONTACT EMERGENCY SERVICES DIRECTLY IN ANY SITUATION INVOLVING RISK TO LIFE OR PERSONAL SAFETY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Assumption of Risk.  YOU EXPRESSLY ASSUME ALL RISKS ASSOCIATED WITH USE OF THE DURESS AND ALERT FEATURES, INCLUDING WITHOUT LIMITATION RISKS ARISING FROM: (A) FALSE POSITIVE ALERTS TRIGGERED IN THE ABSENCE OF AN ACTUAL EMERGENCY; (B) FALSE NEGATIVE FAILURES TO TRIGGER DURING AN ACTUAL EMERGENCY; (C) DELAYS OR FAILURES IN ALERT DELIVERY; AND (D) RELIANCE ON THE APP INSTEAD OF DIRECTLY CONTACTING EMERGENCY SERVICES. YOU REMAIN SOLELY RESPONSIBLE FOR YOUR PERSONAL SAFETY DECISIONS.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''EMERGENCY CONTACT FEATURE''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''User Representations Regarding Emergency Contacts''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''By designating any individual as an Emergency Contact, you represent and warrant that:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You have the authority to provide such individual's contact information to Decoy Wallet;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Such individual has agreed, or will agree prior to activation, to be designated as an Emergency Contact and to receive automated alert messages from the App;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You will only designate individuals who have provided their express prior consent to receive automated SMS messages through the App; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You will promptly remove any individual who revokes consent or requests removal as an Emergency Contact.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Consent Requirement for Emergency Contacts''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''EMERGENCY CONTACTS MUST INDEPENDENTLY CONSENT TO RECEIVE AUTOMATED MESSAGES BEFORE ANY ALERTS MAY BE SENT TO THEM. The App uses an invitation and consent flow that requires each designated Emergency Contact to affirmatively opt in before alerts are enabled. No alerts will be transmitted to any Emergency Contact who has not completed the consent process.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''By consenting, each Emergency Contact acknowledges that they may receive automated text messages that may include:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Alerts that a designated user may be in a situation involving potential duress, coercion, or danger;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Real-time or near-real-time location data of the designated user; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Other information relevant to the alert trigger.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''No Liability for Contact Notifications''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Decoy Wallet shall not be liable for:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any alert message sent to an Emergency Contact in error or without a genuine emergency;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any failure or delay in delivery of any alert message to an Emergency Contact;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any interruption, failure, or limitation imposed by wireless carriers, SMS providers, or other third-party messaging infrastructure; or'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any action or inaction by an Emergency Contact in response to any alert.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Prohibition on Misuse of Alert Features''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''You are strictly prohibited from:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Triggering the Duress PIN or any alert feature knowing that no emergency or duress situation exists, except within a designated Test Mode;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Using the alert system to harass, annoy, or alarm any Emergency Contact or third party;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Repeatedly triggering alerts outside of Test Mode for non-emergency purposes; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Misusing the App in any manner that constitutes false reporting to emergency services or violates any applicable law.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Violation of this section is grounds for immediate termination of your Account and may subject you to indemnification obligations under the Indemnification section below.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SMS AND COMMUNICATIONS CONSENT''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''By creating an Account and using the App, you consent to receive SMS and other electronic communications from Decoy Wallet, including:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Transactional and account-related messages;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''System-generated alerts in connection with the Duress and Alert Features;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Notifications related to your Emergency Contact designations and consent status; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Other communications necessary for the operation of the Services.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App uses automated messaging technology to deliver alerts and notifications. MESSAGE FREQUENCY VARIES BASED ON YOUR ACCOUNT CONFIGURATION AND APP USAGE. STANDARD CARRIER MESSAGE AND DATA RATES MAY APPLY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''For marketing or promotional communications, separate consent will be obtained. Transactional and safety-related communications are necessary for the operation of the Services and may not be fully disabled without impairing core functionality.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''A separate Decoy Wallet SMS Terms and Conditions document governs additional details of SMS communications between Decoy Wallet and Users and Emergency Contacts, and is incorporated by reference into this Agreement.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''EMERGENCY SERVICES; 911 INTEGRATION DISCLAIMER''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''No Guarantee of Emergency Response.  ''',
        isBold: true),
    LegalDocumentRun(
        r'''Decoy Wallet does not guarantee that use of any feature of the App will result in contact with, dispatch of, or response by law enforcement, emergency medical services, fire departments, or any other emergency authority.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''No Direct 911 Integration at Launch.  THE CURRENT VERSION OF THE APP DOES NOT INCLUDE AUTOMATED DIRECT INTEGRATION WITH 911 OR OTHER PUBLIC SAFETY ANSWERING POINTS. Users should not rely on the App as a means of contacting emergency services. IN ANY EMERGENCY, YOU SHOULD CALL 911 DIRECTLY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Future Emergency Services Integration.  ''',
        isBold: true),
    LegalDocumentRun(
        r'''Decoy Wallet may, in future versions, integrate with third-party emergency services intermediaries (such as RapidSOS or similar providers). Any such integration will: (a) be subject to the availability and technical limitations of such third-party providers; (b) not constitute a guarantee of emergency response; and (c) be governed by updated terms disclosed to Users prior to activation of such features.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Limitation on Emergency Services Liability.  DECOY WALLET SHALL NOT BE LIABLE FOR ANY FAILURE TO CONTACT, DISPATCH, OR RECEIVE A RESPONSE FROM EMERGENCY SERVICES IN CONNECTION WITH ANY USE OF THE APP, INCLUDING ANY FUTURE EMERGENCY SERVICES INTEGRATION FEATURES. YOU MUST NOT RELY SOLELY ON THE APP TO CONTACT EMERGENCY SERVICES IN ANY SITUATION INVOLVING RISK TO LIFE OR PROPERTY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''WARRANTIES AND REPRESENTATIONS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''By accessing or using the App, you represent, warrant, and agree to the following terms:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You have the legal right and capacity to enter into this Agreement and to comply with its terms. You represent that you are a human individual who is at least eighteen (18) years of age.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''All information you submit to the App is, to the best of your knowledge, current, accurate, and complete.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You agree to use the App and Services only in accordance with all applicable laws, including but not limited to those relating to intellectual property, privacy, data protection, anti-money laundering, sanctions compliance, blockchain usage, and applicable telecommunications laws including the Telephone Consumer Protection Act (TCPA).'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You represent that any Emergency Contact you designate has provided, or will provide prior to activation, express prior consent to receive automated SMS messages from the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You represent that you are not a resident of, or accessing the App from, any jurisdiction subject to comprehensive U.S. trade sanctions or export restrictions.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''BETA SERVICES; MAINTENANCE''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet may, from time to time, offer access to the App that is classified as Beta version. Beta versions are provided AS IS and may contain bugs, errors, or other defects. Your use of a Beta version is at your sole risk.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''BETA VERSIONS OF THE APP MAY CONTAIN INCOMPLETE FEATURES, INCLUDING INCOMPLETE OR UNTESTED VERSIONS OF THE DURESS ALERT AND EMERGENCY CONTACT SYSTEMS. DECOY WALLET MAKES NO REPRESENTATIONS AS TO THE RELIABILITY OR SAFETY-CRITICAL FUNCTIONALITY OF ANY BETA FEATURE. DO NOT RELY ON BETA FEATURES FOR PERSONAL SAFETY PURPOSES.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet will make commercially reasonable efforts to maintain access to the App and its Services. However, Decoy Wallet may suspend, restrict, or disable access at any time and without notice.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''MOBILE APPLICATION; DEVICE REQUIREMENTS''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App is designed and intended for use on compatible mobile devices. By downloading, installing, and using the App, you acknowledge and agree that:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your wireless carrier's standard message and data rates will apply, including receipt of SMS alerts and push notifications;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App requires access to certain device features, including location services, contacts (for Emergency Contact designation), and push notification permissions, to deliver core functionality;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Disabling required device permissions may impair or disable core features, including the Duress Alert and Emergency Contact features;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet is not responsible for any data usage, roaming charges, carrier interruptions, or mobile-related fees; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App is distributed through third-party app stores (including the Apple App Store and Google Play Store), and your use of those platforms is also subject to their applicable terms of service.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''THIRD-PARTY SERVICES''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App depends on and integrates with third-party services outside of Decoy Wallet's ownership or control, including:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''SMS and wireless carriers for delivery of alert messages;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency service intermediaries (if and when implemented);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Third-party blockchain network infrastructure used for wallet activity monitoring;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Cloud hosting, storage, and infrastructure providers; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Analytics and performance monitoring services.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet makes no warranty, representation, or guarantee regarding the availability, accuracy, reliability, or performance of any third-party service. Decoy Wallet is not responsible for any failure, interruption, delay, or error caused by third-party services, including any failure to deliver an alert message or any failure of an emergency services integration.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''OWNERSHIP OF APP AND LICENSE''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You acknowledge and agree that Decoy Wallet is the sole and exclusive owner of, or otherwise possesses valid rights in and to, the App and all elements thereof. Decoy Wallet hereby grants you a limited, non-exclusive, non-sublicensable, royalty free, non-assignable, and revocable license to install and use the App on a compatible mobile device that you own or control for its customary and intended purposes.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PROHIBITED USES''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''In addition to any other restrictions set forth in this Agreement, you are prohibited from:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Using the App for any unlawful purpose or in violation of any applicable regulation;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Triggering the Duress PIN or any alert feature in the absence of a genuine emergency, except within designated Test Mode;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Using the App to harass, threaten, or alarm any person through false or malicious alerts;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Attempting to access, monitor, or modify the wallet activity or alert configurations of any other User;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Using a robot, spider, scraper, or other automated technology to access the App;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Reverse engineering, decompiling, or otherwise attempting to derive the source code of any portion of the App;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Interfering with or disrupting the operation of any blockchain or network relied upon by the App; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Attempting to bypass, disable, or interfere with any security mechanisms of the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DISCLAIMER OF WARRANTIES''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''YOUR USE OF THE APP AND SERVICES IS AT YOUR SOLE RISK. DECOY WALLET PROVIDES THE APP ON AN AS-IS BASIS AND WITHOUT WARRANTY OF ANY KIND, WHETHER EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, ACCURACY, COMPLETENESS, NON-INFRINGEMENT, OR QUALITY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''BY ACCESSING THE APP YOU ACKNOWLEDGE AND AGREE THAT DECOY WALLET IS NOT A WALLET PROVIDER, EXCHANGE, BROKER, FINANCIAL INSTITUTION, MONEY TRANSMITTER, OR CREDITOR, AND DOES NOT ENGAGE IN THE BUSINESS OF EFFECTING SECURITIES TRANSACTIONS OR PROVIDING INVESTMENT ADVICE.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''YOU ACKNOWLEDGE THAT DECOY WALLET DOES NOT CUSTODY OR CONTROL ANY CRYPTOCURRENCY, WALLETS, PRIVATE KEYS, SEED PHRASES, OR DIGITAL ASSETS, AND HAS NO ABILITY TO REVERSE OR MODIFY ANY TRANSACTION SUBMITTED TO A BLOCKCHAIN.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''DECOY WALLET WILL NOT BE HELD LIABLE OR RESPONSIBLE FOR: (A) USER ERROR OR MISCONFIGURED ALERT SETTINGS; (B) SERVER FAILURE OR DATA LOSS; (C) UNAUTHORIZED ACCESS TO ANY ACCOUNT; (D) FAILURE OF AN EMERGENCY CONTACT TO RECEIVE OR RESPOND TO AN ALERT; OR (E) UNAUTHORIZED THIRD-PARTY ACTIVITIES INCLUDING HACKING, PHISHING, OR OTHER ATTACKS AGAINST THE APP OR ANY ASSOCIATED BLOCKCHAIN INFRASTRUCTURE.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''LIMITATION OF LIABILITY''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''DECOY WALLET WILL NOT BE LIABLE TO YOU UNDER ANY LEGAL THEORY FOR ANY DAMAGES, CLAIMS, INJURIES, JUDGMENTS, COSTS, OR LIABILITIES ARISING OUT OF OR RELATED TO YOUR USE OR MISUSE OF THE APP, INCLUDING BUT NOT LIMITED TO:''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''LOSS OF LIFE, PERSONAL INJURY, OR BODILY HARM ARISING FROM OR IN CONNECTION WITH USE OF THE APP OR RELIANCE ON THE DURESS, ALERT, OR EMERGENCY FEATURES, TO THE EXTENT PERMITTED BY APPLICABLE LAW;''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''FAILURE OF THE DURESS PIN, EMERGENCY ALERT, OR ANY OTHER SAFETY FEATURE TO TRIGGER, DELIVER, OR FUNCTION AS INTENDED;''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''FALSE ALERTS SENT TO EMERGENCY CONTACTS OR EMERGENCY SERVICES, AND ANY CONSEQUENCES THEREOF;''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''FAILURE TO PREVENT COERCION, THEFT, LOSS, OR UNAUTHORIZED TRANSFER OF CRYPTOCURRENCY OR DIGITAL ASSETS;''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''ACTIONS OR INACTIONS OF EMERGENCY CONTACTS, LAW ENFORCEMENT, OR EMERGENCY SERVICES IN RESPONSE TO ANY ALERT;''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''LOSS OF BUSINESS, LOSS OF INCOME, SPECIAL, INCIDENTAL, CONSEQUENTIAL, PUNITIVE, OR EXEMPLARY DAMAGES; AND''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''LOSS OR DELETION OF DATA, FAILED ALERT DELIVERIES, OR THIRD-PARTY SERVICE FAILURES.''',
        isBold: true),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''YOU UNDERSTAND AND AGREE THAT THE MAXIMUM AMOUNT THAT DECOY WALLET CAN BE HELD LIABLE TO YOU UNDER ANY CIRCUMSTANCE IS THE AMOUNT YOU PAID FOR THE SERVICES DURING THE TWELVE (12) MONTHS PRECEDING THE CLAIM. IN NO CASE SHALL DECOY WALLET'S CUMULATIVE LIABILITY EXCEED $100. IF NO AMOUNT IS PAID BY YOU, YOU AGREE THAT YOU WILL BE LIMITED TO INJUNCTIVE RELIEF ONLY.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''INDEMNIFICATION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You agree to hold harmless, indemnify, and defend Decoy Wallet, its officers, employees, agents, successors, and assigns, from and against any and all claims, demands, losses, damages, rights, and actions of any kind, including but not limited to property damage, personal injury, and death, that directly or indirectly arise out of or are related to:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Your use or misuse of the App or Services;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your triggering of any false or improper alert, including any false Duress PIN activation outside of Test Mode;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your improper designation of any individual as an Emergency Contact, including designation without that individual's prior consent;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any violation of applicable telecommunications law, including the TCPA, arising from your use of the alert or communications features;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your misuse of any emergency services integration, including any conduct constituting false reporting under applicable state or federal law;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your violation of any term or condition of this Agreement; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Your violation of the rights of any third party.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''TERM AND TERMINATION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet may terminate this Agreement without liability at any time, without notice, and for any reason, including but not limited to your violation of a term or condition of this Agreement, misuse of the Duress or Emergency Contact features, or conduct constituting false reporting to emergency services. Upon termination, your right to use the App will immediately cease.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SECTION 230 OF THE COMMUNICATIONS DECENCY ACT''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You acknowledge and agree that Decoy Wallet is an interactive computer service provider under Section 230 of the Communications Decency Act. Decoy Wallet will not be held liable for content or information provided by Users in connection with their Account or Emergency Contact designations.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''JURISDICTION, GOVERNING LAW, AND RESOLUTION OF DISPUTES VIA BINDING ARBITRATION''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''This Agreement will be interpreted, governed, construed, and enforced in accordance with the laws of the State of Michigan, without giving effect to any conflicts of laws principles. The parties submit to and agree to personal jurisdiction in Michigan, with venue proper in Ingham County, Michigan.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''PLEASE READ THIS SECTION CAREFULLY. IT MATERIALLY AFFECTS YOUR LEGAL RIGHTS, INCLUDING YOUR RIGHT TO FILE A LAWSUIT IN COURT AND YOUR RIGHT TO A JURY TRIAL.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Agreement to Arbitrate.  ''', isBold: true),
    LegalDocumentRun(
        r'''You and Decoy Wallet agree that any dispute, claim, or controversy arising out of or relating to this Agreement, your use of the App, or any products or services provided by Decoy Wallet, including any question regarding the existence, validity, scope, or enforceability of this arbitration agreement, shall be resolved exclusively through final and binding individual arbitration, rather than in court. This arbitration agreement is governed by the Federal Arbitration Act, 9 U.S.C. § 1 et seq. ("FAA"), and shall be interpreted and enforced in accordance with the FAA to the fullest extent possible.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Delegation.  ''', isBold: true),
    LegalDocumentRun(
        r'''The arbitrator, and not any federal, state, or local court, shall have exclusive authority to resolve all disputes arising out of or relating to the interpretation, applicability, enforceability, or formation of this arbitration agreement, including any claim that all or any part of this arbitration agreement is void or voidable.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Administered Rules.  ''', isBold: true),
    LegalDocumentRun(
        r'''Arbitration shall be administered by the American Arbitration Association ("AAA") under its Consumer Arbitration Rules ("Consumer Rules"), as modified by this Agreement. The Consumer Rules are available at www.adr.org or by calling 1-800-778-7879. Where any provision of this Agreement conflicts with the Consumer Rules, this Agreement shall control, except where the Consumer Rules provide a non-waivable consumer protection, in which case the Consumer Rules shall control on that specific point only.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Arbitrator Selection and Conduct.  ''', isBold: true),
    LegalDocumentRun(
        r'''Arbitration shall be conducted before a single, neutral arbitrator selected in accordance with the Consumer Rules. The arbitrator shall apply the substantive law of the State of Michigan and applicable federal law, without regard to conflict of law principles. The arbitrator shall have authority to award any relief that a court could award, subject to the limitations set forth in this Agreement. The arbitrator's decision and award shall be final and binding and may be entered as a judgment in any court of competent jurisdiction.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Location and Format.  ''', isBold: true),
    LegalDocumentRun(
        r'''Unless you and Decoy Wallet agree otherwise, arbitration shall be conducted in Ingham County, Michigan. For claims under $10,000, you may elect to conduct the arbitration by telephone, videoconference, or written submissions only, and Decoy Wallet will not object to that election.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Fees.  ''', isBold: true),
    LegalDocumentRun(
        r'''Filing and arbitrator fees shall be allocated in accordance with the Consumer Rules, except as modified herein. Decoy Wallet will pay all AAA filing, administration, and arbitrator fees for any arbitration it initiates. For arbitrations initiated by you, Decoy Wallet will pay all fees that exceed what you would pay to file a comparable claim in a court of general jurisdiction in your state of residence, provided the claim is not frivolous as determined by the arbitrator under applicable law. If the arbitrator determines that any claim you assert is frivolous or brought for an improper purpose under Federal Rule of Civil Procedure 11(b), the arbitrator may require you to reimburse Decoy Wallet for all fees incurred in connection with that claim, including reasonable attorneys' fees.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Individual Claims Only; Class Action Waiver.  YOU AND DECOY WALLET EACH AGREE THAT ARBITRATION SHALL BE CONDUCTED SOLELY ON AN INDIVIDUAL BASIS AND NOT AS A CLASS, CONSOLIDATED, REPRESENTATIVE, OR COLLECTIVE ACTION. YOU EXPRESSLY WAIVE ANY RIGHT TO FILE OR PARTICIPATE IN A CLASS ACTION, CLASS ARBITRATION, CONSOLIDATED ARBITRATION, PRIVATE ATTORNEY GENERAL ACTION, OR ANY OTHER REPRESENTATIVE PROCEEDING OF ANY KIND. The arbitrator may award relief only to the individual party and only to the extent necessary to provide relief on that party's individual claims. No arbitration award or decision may be given preclusive effect as to issues or claims in any dispute with anyone who is not a named party to the arbitration.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Mass Arbitration Batching.  ''', isBold: true),
    LegalDocumentRun(
        r'''If twenty-five (25) or more similar demands for arbitration are filed against Decoy Wallet by or with the assistance of the same law firm or organized group, and the demands raise substantially similar claims, the AAA shall administer the demands as a consolidated proceeding in accordance with its Mass Arbitration Supplementary Rules, or if no such rules apply, the parties agree to negotiate in good faith a batching protocol for sequential or grouped resolution of those demands. This provision is intended to prevent abuse of the arbitration process and shall be enforced to the fullest extent permitted by law.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Injunctive and Equitable Relief.  ''', isBold: true),
    LegalDocumentRun(
        r'''Notwithstanding the foregoing, either party may seek temporary restraining orders, preliminary injunctions, or other provisional equitable relief in a court of competent jurisdiction to prevent irreparable harm or to protect intellectual property rights pending resolution of the underlying dispute in arbitration. Decoy Wallet expressly reserves the right to seek injunctive or other equitable relief in court in connection with any actual or threatened misuse of the App, violation of the Prohibited Uses section, or unauthorized access to or interference with the App or its systems.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Severability of Arbitration Clause.  ''',
        isBold: true),
    LegalDocumentRun(
        r'''If any portion of this arbitration agreement is found to be unenforceable, that portion shall be severed and the remaining portions shall remain in full force and effect. If the class action waiver is found to be unenforceable in a particular proceeding, then the entirety of the arbitration agreement shall be null and void with respect to that proceeding only, and that proceeding may proceed in a court of competent jurisdiction.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Opt-Out Right.  ''', isBold: true),
    LegalDocumentRun(
        r'''You may opt out of this arbitration agreement by sending written notice to legal@decoywalletapp.com within thirty (30) days of the date you first agree to this Agreement. Your notice must include your name, the email address associated with your Account, and a clear statement that you are opting out of arbitration. If you opt out, neither you nor Decoy Wallet will be bound by this arbitration agreement, but all other provisions of this Agreement will remain in effect. Opting out will not affect your ability to use the App.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''One-Year Limitation on Claims.  DECOY WALLET AND YOU BOTH AGREE THAT ANY CAUSE OF ACTION ARISING OUT OF OR RELATED TO THE APP AND SERVICES MUST COMMENCE WITHIN ONE YEAR AFTER THE CAUSE OF ACTION ACCRUES. FAILURE TO ASSERT SAID CAUSE OF ACTION WITHIN ONE YEAR WILL PERMANENTLY BAR ANY AND ALL RELIEF.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SEVERABILITY''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''If any provision of this Agreement is found to be invalid, illegal, or unenforceable, such provision shall be modified to the minimum extent necessary to make it enforceable, or if not possible, deemed severed from this Agreement, and the remaining provisions shall remain in full force and effect.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''INTEGRATION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet hereby incorporates its Privacy Policy and, when published, its SMS Terms and Conditions into this Agreement. This Agreement and its incorporated documents constitute the entire agreement between the parties with respect to the use of the App.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NO WAIVER''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''No term or provision of this Agreement will be deemed to have been waived unless said waiver is in writing and signed by the party to be charged.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''CHILD ONLINE PRIVACY PROTECTION ACT''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App is not directed to persons under the age of eighteen (18) and Decoy Wallet will not knowingly collect personally identifiable information from children under the age of eighteen (18).'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NO ASSIGNMENT''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You are prohibited from assigning your rights and obligations under this Agreement. Decoy Wallet may assign its rights and obligations under this Agreement at any time.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''RESERVATION OF RIGHTS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''All rights not expressly granted herein are reserved to Decoy Wallet.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NOTICE''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any notice required by this Agreement must be in writing and must be emailed to: legal@decoywalletapp.com.'''),
  ]),
];

const List<LegalDocumentParagraph> kDecoyWalletPrivacyPolicyParagraphs =
    <LegalDocumentParagraph>[
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DECOY WALLET''', isBold: true),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PRIVACY POLICY''', isBold: true),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Effective Date: May 8, 2026'''),
  ], textAlign: TextAlign.center),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The Decoy Wallet mobile application and its associated services, software, and content (the "App" or "Services") are owned and operated by Decoy Wallet LLC, a Michigan limited liability company ("Decoy Wallet," "our," "us," "we"). Decoy Wallet has adopted this Privacy Policy ("Privacy Policy") to inform you of the Personal Information it collects when you use the App and to explain how such information is used, shared, and protected. This Privacy Policy applies to all online and mobile interactions with Decoy Wallet owned or operated applications and services. You should contact Decoy Wallet directly with any questions or concerns at support@decoywalletapp.com.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''DECOY WALLET MAY CHANGE, MODIFY, AMEND, SUSPEND, TERMINATE, OR REPLACE THIS PRIVACY POLICY FROM TIME TO TIME AND WITHIN ITS SOLE AND ABSOLUTE DISCRETION. YOUR CONTINUED USE OF THE APP AFTER A CHANGE IN THE EFFECTIVE DATE OF THIS PRIVACY POLICY CONSTITUTES YOUR MANIFESTATION OF ASSENT TO THE CHANGE, MODIFICATION, AMENDMENT, OR REPLACEMENT CONTAINED WITHIN.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DEFINITIONS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The following terms apply to this Privacy Policy. Capitalized terms used but not defined herein have the meanings given in the Decoy Wallet Terms of Service Agreement.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''California Consumer Privacy Act ("CCPA") means the California statute intended to enhance privacy rights and consumer protection for residents of California, United States.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''General Data Protection Regulation ("GDPR") means the European Union law on data protection and privacy applicable to individuals within the EU.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Personal Data means any information relating to an identified or identifiable natural person.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Personal Information under the CCPA means information that identifies, relates to, describes, is reasonably capable of being associated with, or could reasonably be linked, directly or indirectly, with a particular consumer or household.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Alert Data" means information generated in connection with the triggering of a Duress PIN or other alert feature, including the time, trigger type, and any location data transmitted in connection with an alert.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Emergency Contact Data" means the name and phone number (or other contact information) of individuals designated by a Registered User as Emergency Contacts.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Geolocation Data" means precise, real-time or near-real-time geographic location information of a User, collected through the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Wallet Metadata" means observable blockchain activity data associated with a Wallet Address provided by the User for monitoring purposes, such as transaction activity indicators. Wallet Metadata does not include and Decoy Wallet does not collect private keys, seed phrases, or cryptographic credentials.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Account" means a Registered User's account with the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"Registered User(s)" means Users who have created an Account.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''"User(s)" means all individuals that download, install, or access the App, including Registered Users.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''"You / Your" refers to the individual User.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''TYPES OF PERSONAL INFORMATION WE COLLECT''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet collects the following categories of Personal Information. WE DO NOT COLLECT CRYPTOCURRENCY PRIVATE KEYS, SEED PHRASES, OR WALLET ACCESS CREDENTIALS.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Information Collected from All Users''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''First and last name;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Email address;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Phone number; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any other information you voluntarily submit to the App.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Information Collected from Registered Users''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''First and last name;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Email address;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Phone number;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Wallet Address (public blockchain address only, used for monitoring purposes; see Wallet Metadata definition);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Payment information, if applicable to subscription or premium features (processed by third-party payment processors);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Duress PIN configuration data (the PIN itself is not stored in recoverable form; only system configuration metadata is retained);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency Contact Data (names and phone numbers of designated Emergency Contacts);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Alert Data, including time, trigger type, and associated location data at time of alert trigger; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Any other information that you upload or submit to the App directly or indirectly.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Geolocation Data''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet collects precise Geolocation Data when the alert features are active or when an alert is triggered. Specifically:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''WHY COLLECTED: Geolocation Data is collected to enable the transmission of your location to designated Emergency Contacts in connection with an alert trigger.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''WHEN TRIGGERED: Geolocation collection is triggered upon activation of the Duress PIN feature or other alert trigger, and may be collected on a continuous basis while alert mode is active.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''RETENTION: Decoy Wallet does not store Geolocation Data on its backend servers. Location information transmitted in connection with an alert is processed in real time and delivered directly to designated Emergency Contacts as an instantaneous payload. No Geolocation Data is retained in Decoy Wallet's systems following delivery. Any transient processing of Geolocation Data that occurs in connection with alert delivery does not persist beyond the time technically necessary for transmission, which in no event exceeds 30 minutes. Geolocation Data is not retained for marketing purposes.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''DELETION: Because Geolocation Data is not stored on Decoy Wallet's backend, there is no Geolocation Data to delete following an alert event. If you believe Geolocation Data has been retained in error, please contact us at support@decoywalletapp.com.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''MINIMIZATION: Decoy Wallet limits the collection of Geolocation Data to what is reasonably necessary for the alert and safety features described in this Privacy Policy.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Device and Technical Information''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet collects the following information automatically from all Users:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''IP address;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Device type, operating system version, and device identifiers;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''App version and usage data;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Push notification tokens (used for delivery of alert notifications and subscription payment confirmations and reminders);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''App usage analytics, including features accessed, session duration, and alert trigger frequency; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Crash logs and error reports used for debugging and service improvement.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PURPOSE OF COLLECTION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet collects Personal Information for the following specific purposes:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''To create and maintain your Account;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To detect potential duress scenarios and trigger the appropriate alert flow based on your configuration;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To transmit alerts, including location data, to your designated Emergency Contacts when an alert is triggered;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To monitor Wallet Address activity and generate alerts based on wallet activity triggers you configure;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To facilitate the Emergency Contact consent and invitation flow, including sending opt-in messages to designated Emergency Contacts;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To deliver SMS and push notifications in connection with the Services;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To send subscription payment confirmations and upcoming payment reminders;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To communicate with you about your Account, including transactional and service-related messages;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To maintain the security and integrity of the App and Services;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''To comply with applicable legal obligations; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To improve the App and Services through analytics and performance monitoring.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet does NOT use your Personal Information, including Geolocation Data or Alert Data, for advertising, behavioral profiling, or marketing purposes without your separate consent.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NO CUSTODY; NO ACCESS TO WALLET CREDENTIALS''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet does not collect, store, access, transmit, or have any knowledge of your cryptocurrency private keys, seed phrases, wallet passwords, or any cryptographic credentials. The collection of a Wallet Address for monitoring purposes does not give Decoy Wallet any control over, access to, or custody of any digital assets associated with that address. Wallet Metadata collected by Decoy Wallet is limited to observable blockchain activity data and does not constitute financial account information.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''EMERGENCY CONTACT DATA; THIRD-PARTY CONSENT''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''When you designate Emergency Contacts, Decoy Wallet collects and stores the names and phone numbers (or other contact information) that you provide. This information is used solely to:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Facilitate the Emergency Contact consent and invitation process;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Deliver alert messages to designated Emergency Contacts when an alert is triggered; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Maintain records of consent status for each Emergency Contact.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency Contact Data is not used for marketing, profiling, or any purpose other than the delivery of alerts and consent management.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''EMERGENCY CONTACTS MUST INDEPENDENTLY CONSENT TO RECEIVE AUTOMATED MESSAGES BEFORE ANY DATA IS USED TO CONTACT THEM. Until an Emergency Contact has completed the consent process, their contact information is retained only for the purpose of facilitating consent and no messages will be sent.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency Contacts may withdraw consent at any time. Upon withdrawal, Decoy Wallet will cease transmitting alerts to that individual and will delete their contact information upon request.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SOURCES OF PERSONAL INFORMATION COLLECTION''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet collects Personal Information from you through the following channels: through your voluntary submission of information when creating an Account or configuring the App; through automated collection in connection with your use of the App (device data, usage analytics); through alert trigger events (Alert Data, Geolocation Data); and through the Emergency Contact consent flow.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''COOKIES AND SIMILAR TECHNOLOGIES''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''As a mobile application, the App does not use browser-based cookies. The App may use similar technologies, including device identifiers, push notification tokens, and local storage, for the following purposes:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To maintain your session and Account authentication;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To deliver push notifications related to alert events and subscription reminders; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''To collect analytics data about App usage.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You may manage device-level permissions and notification settings through your mobile device's operating system settings.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet also operates a website at  (the "Website"). The Website uses cookies and similar tracking technologies separately from the App. The collection, use, and management of cookies on the Website is governed exclusively by the Decoy Wallet Cookie Policy, which is incorporated herein by reference and available at . The Cookie Policy describes the categories of cookies used on the Website, the specific third-party tools deployed, your opt-out rights and mechanisms, and how to manage your cookie preferences through your browser settings. By using the Website, you acknowledge that your use of the Website is subject to both this Privacy Policy and the Cookie Policy.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''For the avoidance of doubt, this Privacy Policy governs the collection and use of Personal Information through the App. The Cookie Policy governs tracking technologies deployed through the Website. To the extent any conflict exists between the two documents with respect to Website cookie practices, the Cookie Policy controls.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SHARING OF YOUR PERSONAL INFORMATION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet shares your Personal Information with third parties in the following circumstances:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Where Decoy Wallet has obtained your consent;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''With your designated Emergency Contacts, as necessary to deliver alerts pursuant to the App's alert features, including transmission of Alert Data and Geolocation Data;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''With SMS carriers, messaging platforms, and related service providers as necessary to deliver alert messages to Emergency Contacts;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''With emergency services intermediaries, if and when such integration is implemented, solely for the purpose of facilitating emergency services contact;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Where sharing is necessary to provide you with the App and associated Services, with trusted third-party providers who assist in operating the App;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Where sharing is required to respond to requests by government authorities, court orders, or subpoenas;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Where sharing is needed to protect the rights, property, or safety of Decoy Wallet, its users, or others; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Where Decoy Wallet is otherwise legally obligated to share your Personal Information.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Third-Party Service Providers''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet shares Personal Information with the following categories of third-party service providers:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''SMS and wireless messaging providers (for alert delivery);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Cloud hosting and infrastructure providers;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Payment processors (if applicable for subscription features);'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Analytics providers; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency services integration providers (if and when implemented).'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''A current list of third-party service providers is available upon request at support@decoywalletapp.com.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''SENSITIVE DATA HANDLING; GEOLOCATION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Geolocation Data and Emergency Contact Data are treated as sensitive categories of Personal Information. In addition to the disclosures above, Decoy Wallet commits to the following:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Geolocation Data will not be shared with any third party other than designated Emergency Contacts and, where implemented, emergency services intermediaries;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Geolocation Data will not be used for advertising, behavioral targeting, or marketing purposes; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet will implement reasonable technical and organizational measures to protect Geolocation Data and Emergency Contact Data from unauthorized access or disclosure.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PUSH NOTIFICATIONS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''We may send push notifications to Users for the following purposes:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To deliver alert notifications related to Duress PIN triggers or wallet activity alerts;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To notify Users of Emergency Contact consent status changes;'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To send subscription payment confirmations and upcoming payment reminders; and'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To communicate transactional information related to your Account.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Users may manage push notification settings through their device settings. PLEASE NOTE: Disabling push notifications for the App may prevent delivery of critical alert notifications, which is a core safety feature of the Services. You should carefully consider the implications of disabling alerts before doing so.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''DATA MINIMIZATION AND RETENTION''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet is committed to data minimization. We collect only the categories of Personal Information that are reasonably necessary to provide the Services. Specifically:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Geolocation Data: Decoy Wallet does not store Geolocation Data on its backend servers. Location information is transmitted as an instantaneous real-time payload to designated Emergency Contacts and is not retained following delivery. Any transient processing buffer associated with alert transmission does not persist beyond 30 minutes and is purged upon completion of delivery.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Emergency Contact Data is retained only for the duration of the Emergency Contact relationship and is deleted upon request following removal or consent withdrawal.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Alert Data (trigger logs) is retained for security, compliance, and dispute resolution purposes for a period not to exceed 24 months.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Wallet Metadata is retained only for the period during which active monitoring is configured and for a reasonable period thereafter.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Account data is retained for the duration of the Account relationship and for any period required by applicable law.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PERSONAL INFORMATION SECURITY''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet implements reasonable administrative, technical, and organizational safeguards designed to protect your Personal Information from unauthorized access, use, disclosure, alteration, or destruction. These measures include, without limitation, encryption of data in transit and at rest, access controls, and security monitoring.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''NO SECURITY SYSTEM IS COMPLETELY SECURE. DECOY WALLET DOES NOT GUARANTEE THE ABSOLUTE SECURITY OF YOUR PERSONAL INFORMATION. YOU PROVIDE ALL INFORMATION AT YOUR OWN RISK.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PERSONAL INFORMATION TRANSFER AND STORAGE''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Your Personal Information is stored and processed on computers and servers in the United States. Decoy Wallet applies the same protections described in this Privacy Policy regardless of where your information is stored and processed. Through your use of the App, you consent to the processing and storage of your Personal Information in the United States.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet retains Personal Information in accordance with the data minimization and retention schedule described above. Upon Account deletion, Decoy Wallet will delete your Personal Information consistent with applicable law, subject to retention of information required for compliance, legal, or dispute resolution purposes.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''EU USERS' RIGHTS UNDER THE GDPR''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The GDPR provides Users located in the EU with certain rights with respect to their Personal Data. Decoy Wallet recognizes and will comply with the GDPR and those rights, except as limited by applicable law. The rights under the GDPR include:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right of Access: The right to obtain your Personal Data and information about how it is processed.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right of Rectification: The right to correct inaccurate Personal Data.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right of Erasure ("Right to be Forgotten"): The right to have your Personal Data deleted.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Restriction of Processing: The right to request restriction of how your Personal Data is used.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Data Portability: The right to receive your Personal Data in a structured, readable format.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Object: The right to object to processing of your Personal Data.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to not be Subject to Automated Decision-Making.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''CALIFORNIA USERS' RIGHTS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Under the CCPA, California Users have the following rights:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Know About Personal Information Collected, Disclosed, or Sold.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Right to Have Personal Information Deleted.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Know About Sensitive Personal Information (including Geolocation Data): You have the right to know how Decoy Wallet collects, uses, and shares your Geolocation Data and other sensitive categories of Personal Information.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Limit Use of Sensitive Personal Information: To the extent applicable under California law, you have the right to request that Decoy Wallet limit the use of your sensitive Personal Information, including Geolocation Data, to uses necessary to perform the requested services.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Right to Opt-Out of the Sale of Personal Information: Decoy Wallet does not sell Personal Information.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Right to Non-Discrimination.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Right to Correction.'''),
  ], isBullet: true),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''To exercise your rights under the CCPA, please contact Decoy Wallet at support@decoywalletapp.com. Decoy Wallet will verify requests by ensuring they are associated with a Registered User account.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''SUPPLEMENTAL NOTICE FOR RESIDENTS OF OTHER US STATES''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Residents of Colorado, Virginia, Connecticut, and other states with applicable privacy laws may have rights regarding their Personal Information, including rights to access, correct, delete, and port their Personal Information, and to opt out of profiling. Decoy Wallet does not engage in profiling that produces legal or similarly significant effects.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Given the sensitive nature of Geolocation Data collected by Decoy Wallet, residents of states that specifically regulate precise geolocation data (including California, Colorado, Virginia, Washington, and others) are encouraged to review the Geolocation Data section of this Privacy Policy and to contact Decoy Wallet with any questions about the collection, use, or retention of their location information.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NOTICE FOR NEVADA RESIDENTS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Under Nevada law, certain Nevada consumers may opt out of the sale of Personal Information for monetary consideration. Decoy Wallet does not engage in such activity; however, if you are a Nevada resident you may submit an opt-out request to support@decoywalletapp.com.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''NO LIABILITY FOR THIRD-PARTY WEBSITES AND SERVICES''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Third-party service providers used by Decoy Wallet, including SMS carriers, emergency services intermediaries, and analytics providers, have their own independent privacy policies. Decoy Wallet is not responsible for the data practices of third-party service providers. We encourage you to review applicable third-party privacy policies.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''PURCHASE OR SALE OF THE APP OR OTHER ASSETS''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''Decoy Wallet may purchase other businesses or sell components of its business. In the event of such a transaction, your Personal Information will continue to be used consistent with the terms of this Privacy Policy.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''HOW TO STOP DECOY WALLET FROM COLLECTING YOUR PERSONAL INFORMATION''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''You can request that Decoy Wallet stop collecting your Personal Information by contacting us at support@decoywalletapp.com and requesting deletion of your Account. You may also adjust your device settings to limit or disable location services and push notifications for the App.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''PLEASE NOTE: Disabling location services will prevent the App from transmitting Geolocation Data to Emergency Contacts in the event of an alert. This may materially impair the core safety functionality of the App.''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''YOUR OBLIGATIONS''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''When using the App, you are obligated to inform Decoy Wallet of any changes to your Personal Information. You are also responsible for ensuring that the information you provide regarding Emergency Contacts is accurate and current.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''CHILDREN'S ONLINE PRIVACY PROTECTION POLICY''',
        isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''The App is not intended for or directed to users under the age of 18, and Decoy Wallet does not knowingly collect Personal Information from children under the age of 13. If you believe Personal Information has been inadvertently collected from a child, please contact us immediately so appropriate steps may be taken.'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''CONTACT AND NOTICES''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(
        r'''All questions and concerns regarding this Privacy Policy may be submitted to Decoy Wallet at:'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Decoy Wallet LLC''', isBold: true),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''2222 W. Grand River Ave Ste A'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''Okemos, MI 48864'''),
  ]),
  LegalDocumentParagraph(<LegalDocumentRun>[
    LegalDocumentRun(r'''support@decoywalletapp.com'''),
  ]),
];
