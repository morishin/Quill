/*
 * "Hello Swift, Goodbye Obj-C."
 * Converted by 'objc2swift'
 *
 * https://github.com/yahoojapan/objc2swift
 */

import Foundation
import Cocoa

class AppController: NSObject, KeyMonitorDelegate {
    var mainWindowController: NSWindowController?
    var licenseWindowController: NSWindowController?
    var mainViewController: MainViewController?

    private let trieTree = TrieTreeManager.shared
    private let keyMonitor: KeyMonitor
    private var mainWindow: NSWindow?

    @objc func openMainWindow() {
        licenseWindowController?.close()
        if mainWindow == nil {
            let viewController = MainViewController(nibName: "MainViewController", bundle: nil)
            mainViewController = viewController
            let window = createWindowWithContentView(view: viewController.view)
            window.title = "Quill - \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString").flatMap(String.init(describing:)) ?? "")"
            mainWindow = window
            mainWindowController = NSWindowController(window: window)
        }
        mainWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func openLicenseWindow() {
        mainWindowController?.close()
        licenseWindowController = LicenseWindowController(windowNibName: "LicenseWindowController")
        licenseWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func keyUp(character: Character) {
        let state = trieTree.nextState(key: character)
        if case let .accept(key, value) = state {
            let pboard = NSPasteboard.general
            let savedPasteboardItems = pboard.save()
            pboard.clearContents()
            pboard.setString(value, forType: .string)
            self.postDeleteAndPasteEvent(nDeletes: key.count)
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            pboard.restore(savedPasteboardItems)
        }
    }

    override init() {
        keyMonitor = KeyMonitor()
        super.init()
        keyMonitor.delegte = self
    }

    func postDeleteAndPasteEvent(nDeletes: Int) {
        let source = CGEventSource(stateID: .combinedSessionState)

        let kVK_Delete = 0x33
        let kVK_ANSI_V = 0x09

        guard
            let deleteDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Delete), keyDown: true),
            let deleteUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Delete), keyDown: false),
            let pasteCommandDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true),
            let pasteCommandUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        else { return assertionFailure() }

        pasteCommandDown.flags = CGEventFlags.maskCommand

        (0...nDeletes).forEach { _ in
            deleteDown.post(tap: .cgSessionEventTap)
            deleteUp.post(tap: .cgSessionEventTap)
        }

        pasteCommandDown.post(tap: .cgSessionEventTap)
        pasteCommandUp.post(tap: .cgSessionEventTap)
    }

    func createWindowWithContentView(view: NSView) -> NSWindow {
        let frame = NSMakeRect(0, 0, view.frame.size.width, view.frame.size.height + 22)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable]
        let rect = NSWindow.contentRect(forFrameRect: frame, styleMask: styleMask)
        let window = NSWindow(contentRect: rect, styleMask: styleMask, backing: .buffered, defer: false)
        window.center()
        window.contentView = view
        return window
    }
}
