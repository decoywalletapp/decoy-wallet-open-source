import UIKit
import Flutter
import ContactsUI

@main
@objc class AppDelegate: FlutterAppDelegate, CNContactPickerDelegate {
  private var contactPickerResult: FlutterResult?
  private var secureScreenEnabled = false
  private var privacyOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let contactPickerChannel = FlutterMethodChannel(
        name: "decoy_wallet/contact_picker",
        binaryMessenger: controller.binaryMessenger
      )

      contactPickerChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "pickContact" else {
          result(FlutterMethodNotImplemented)
          return
        }

        self?.presentContactPicker(result: result)
      }

      // Seed screens: hide content in the app-switcher snapshot and while the
      // screen is recorded/mirrored. iOS cannot block screenshots outright.
      let secureScreenChannel = FlutterMethodChannel(
        name: "decoy_wallet/secure_screen",
        binaryMessenger: controller.binaryMessenger
      )
      secureScreenChannel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "enable":
          self?.secureScreenEnabled = true
          self?.updatePrivacyOverlay()
          result(nil)
        case "disable":
          self?.secureScreenEnabled = false
          self?.updatePrivacyOverlay()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    let center = NotificationCenter.default
    center.addObserver(
      self, selector: #selector(appWillResignActive),
      name: UIApplication.willResignActiveNotification, object: nil)
    center.addObserver(
      self, selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification, object: nil)
    center.addObserver(
      self, selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification, object: nil)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func appWillResignActive() {
    if secureScreenEnabled { showPrivacyOverlay() }
  }

  @objc private func appDidBecomeActive() {
    updatePrivacyOverlay()
  }

  @objc private func screenCaptureChanged() {
    updatePrivacyOverlay()
  }

  private func updatePrivacyOverlay() {
    if secureScreenEnabled && window?.screen.isCaptured == true {
      showPrivacyOverlay()
    } else {
      hidePrivacyOverlay()
    }
  }

  private func showPrivacyOverlay() {
    guard privacyOverlay == nil, let window = window else { return }
    let overlay = UIView(frame: window.bounds)
    overlay.backgroundColor = UIColor(red: 0x1D / 255.0, green: 0x24 / 255.0, blue: 0x28 / 255.0, alpha: 1)
    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(overlay)
    privacyOverlay = overlay
  }

  private func hidePrivacyOverlay() {
    privacyOverlay?.removeFromSuperview()
    privacyOverlay = nil
  }

  private func presentContactPicker(result: @escaping FlutterResult) {
    guard contactPickerResult == nil else {
      result(FlutterError(
        code: "contact_picker_active",
        message: "A contact picker is already open.",
        details: nil
      ))
      return
    }

    guard let presentingController = topViewController(window?.rootViewController) else {
      result(FlutterError(
        code: "no_presenting_controller",
        message: "Unable to open contacts.",
        details: nil
      ))
      return
    }

    contactPickerResult = result
    let picker = CNContactPickerViewController()
    picker.delegate = self
    picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
    presentingController.present(picker, animated: true)
  }

  private func topViewController(_ base: UIViewController?) -> UIViewController? {
    if let navigationController = base as? UINavigationController {
      return topViewController(navigationController.visibleViewController)
    }

    if let tabController = base as? UITabBarController {
      return topViewController(tabController.selectedViewController)
    }

    if let presentedController = base?.presentedViewController {
      return topViewController(presentedController)
    }

    return base
  }

  private func completeContactPicker(_ value: Any?) {
    contactPickerResult?(value)
    contactPickerResult = nil
  }

  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
    completeContactPicker([
      "firstName": contact.givenName,
      "lastName": contact.familyName,
      "phoneNumber": phoneNumber
    ])
  }

  func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
    completeContactPicker(nil)
  }
}
