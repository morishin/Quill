/*
 * "Hello Swift, Goodbye Obj-C."
 * Converted by 'objc2swift'
 *
 * https://github.com/yahoojapan/objc2swift
 */

import Foundation
import AppKit

protocol KeyMonitorDelegate: NSObject {
    func keyUp(character: Character)
}

class KeyMonitor: NSObject {
    private var eventMonitor: Any?

    weak var delegte: KeyMonitorDelegate?

    override init() {
        super.init()
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyUp) { [weak self] event in
            if let character = event.characters?.first {
                self?.delegte?.keyUp(character: character)
            }
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
