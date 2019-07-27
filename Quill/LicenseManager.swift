import Foundation
import CommonCrypto

struct License {
    var email: String
    var licenseKey: String
}

struct LicenseManager {
    private static let privateKey: String = "JoLwaQL7APBqghViZR7f47XbG7up3zR9XPNiiEH9BmPv2BiZjpAJhxRcd8uLYNmR"

    static var isActivated: Bool {
        return loadLicense().map { validateLicenseKey(license: $0) } ?? false
    }

    static func loadLicense() -> License? {
        guard let data = NSDictionary(contentsOf: ConfigManager.configFilePath(type: .license)),
            let email = data["email"] as? String,
            let licenseKey = data["license_key"] as? String else { return nil }
        return License(email: email, licenseKey: licenseKey)
    }

    static func saveLicense(license: License) throws {
        try ConfigManager.save(data: [
            "email": license.email,
            "license_key": license.licenseKey,
        ], for: .license)
    }

    static func validateLicenseKey(license: License) -> Bool {
        return license.licenseKey == "\(license.email)\(LicenseManager.privateKey)".sha256
    }
}

@objc class LicenseManagerForObjC: NSObject {
    @objc class var isActivated: Bool {
        return LicenseManager.isActivated
    }

    @objc class var email: String? {
        return LicenseManager.loadLicense()?.email
    }

    @objc class var licenseKey: String? {
        return LicenseManager.loadLicense()?.licenseKey
    }
}
