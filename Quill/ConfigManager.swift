import Foundation

struct ConfigManager {
    enum ConfigType: String {
        case snippets
        case license
    }

    static func configFilePath(type: ConfigType) -> URL {
        if let applicationDirectoryPath = FileManager.default.applicationSupportDirectory() {
            return URL(fileURLWithPath: applicationDirectoryPath.appending("\(type.rawValue).plist"))
        } else {
            return Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/\(type.rawValue).plist")
        }
    }

    static func save(data: [String: String], for type: ConfigType) throws {
        let path = ConfigManager.configFilePath(type: type)
        if !FileManager.default.fileExists(atPath: path.deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(atPath: path.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        }
        try NSDictionary(dictionary: data).write(to: path)
    }

    static func save(data: [Any], for type: ConfigType) throws {
        let path = ConfigManager.configFilePath(type: type)
        if !FileManager.default.fileExists(atPath: path.deletingLastPathComponent().path) {
            try FileManager.default.createDirectory(atPath: path.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
        }
        try NSArray(array: data).write(to: path)
    }
}

@objc class ConfigManagerForObjC: NSObject {
    @objc class var snippetsConfigFilePath: URL {
        return ConfigManager.configFilePath(type: .snippets)
    }
}
