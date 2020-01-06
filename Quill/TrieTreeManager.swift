import Foundation
import TrieSwift

class TrieTreeManager: NSObject {
    @objc static let shared = TrieTreeManager()
    @objc var snippets: [[String]]

    private let tree = TrieTree<Character, String>()

    override init() {
        if let contents = try? NSArray(contentsOf: ConfigManager.configFilePath(type: .snippets), error: ()), let casted = contents as? [[String]] {
            snippets = casted
        } else {
            snippets = [["img", "<img src=\"\" width=\"320\"/>"]]
        }
        super.init()
        snippets.forEach { tree.insertValue(for: $0[0], value: $0[1]) }
    }

    @objc func addSnippet(with key: String, value: String) throws {
        tree.insertValue(for: key, value: value)
        if let index = snippets.firstIndex(where: { $0[0] == key }) {
            snippets[index] = [key, value]
        } else {
            snippets.append([key, value])
        }
        try writeSnippetsToFile()
    }

    @objc func removeSnippet(with key: String) throws {
        tree.removeValue(for: key)
        snippets.removeAll { $0[0] == key }
        try writeSnippetsToFile()
    }

    func nextState(key: Character) -> TrieTree<Character, String>.State {
        return tree.nextState(key: key)
    }

    private func writeSnippetsToFile() throws {
        let path = ConfigManager.configFilePath(type: .snippets)
        let directory = path.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
        }
        try NSArray(array: snippets).write(to: path)
    }
}
