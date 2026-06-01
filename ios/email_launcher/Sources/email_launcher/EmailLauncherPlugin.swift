import Flutter
import UIKit
import MessageUI

public class EmailLauncherPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "email_launcher", binaryMessenger: registrar.messenger())
        let instance = EmailLauncherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "launch":
            launchEmail(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func launchEmail(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let email = parseArgs(call, result: result) else { return }
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(FlutterError(code: "error", message: "Unable to get view controller", details: nil))
            return
        }
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients(email.to)
            mailComposeVC.setCcRecipients(email.cc)
            mailComposeVC.setBccRecipients(email.bcc)
            if let subject = email.subject {
                mailComposeVC.setSubject(subject)
            }
            if let body = email.body {
                mailComposeVC.setMessageBody(body, isHTML: false)
            }
            viewController.present(mailComposeVC, animated: true, completion: nil)
            result(true)
        } else {
            result(FlutterError(code: "-1", message: "No email clients found!", details: nil))
        }
    }

    private func parseArgs(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> Email? {
        guard let args = call.arguments as? [String: Any?] else {
            result(FlutterError(code: "error", message: "args are not map", details: nil))
            return nil
        }
        return Email(
            to: args[Email.to] as? [String],
            cc: args[Email.cc] as? [String],
            bcc: args[Email.bcc] as? [String],
            subject: args[Email.subject] as? String,
            body: args[Email.body] as? String
        )
    }
}

extension EmailLauncherPlugin: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

struct Email {
    static let to = "to"
    static let cc = "cc"
    static let bcc = "bcc"
    static let subject = "subject"
    static let body = "body"

    let to: [String]?
    let cc: [String]?
    let bcc: [String]?
    let subject: String?
    let body: String?
}
