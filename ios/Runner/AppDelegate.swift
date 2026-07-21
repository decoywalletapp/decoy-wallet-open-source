import UIKit
import Flutter
import ContactsUI

@main
@objc class AppDelegate: FlutterAppDelegate, CNContactPickerDelegate {
  private var contactPickerResult: FlutterResult?

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
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
