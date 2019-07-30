import Cocoa

class LicenseWindowController: NSWindowController {
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var licenseKeyTextField: NSTextField!
    @IBOutlet weak var useLicenseButton: NSButton!

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func didClickPurchaseLicenseButton(_ sender: NSButton) {
        let purchaseURL = URL(string: "https://quill.morishin.me/purchase.html")!
        NSWorkspace.shared.open(purchaseURL)
    }

    @IBAction func didClickUseLicenseButton(_ sender: NSButton) {
        let inputLicense = License(email: emailTextField.stringValue, licenseKey: licenseKeyTextField.stringValue)
        let isValid = LicenseManager.validateLicenseKey(license: inputLicense)
        if isValid {
            try! LicenseManager.saveLicense(license: inputLicense)
            let alert = NSAlert()
            alert.messageText = "Thank you for purchasing! Enjoy 🎉"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            close()
        } else {
            let alert = NSAlert()
            alert.messageText = "Invalid License Key"
            alert.informativeText = "Please confirm email address and license key."
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

//extension LicenseWindowController: NSTextFieldDelegate {
//    func controlTextDidChange(_ obj: Notification) {
//        useLicenseButton.isEnabled = !emailTextField.stringValue.isEmpty && !licenseKeyTextField.stringValue.isEmpty
//    }
//}
