//
//  AppDelegate.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/10.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let popover = StatusBarPopover()
    var windowControllers: [NSWindowController] = []

    func applicationDidFinishLaunching(_: Notification) {
        while !checkAndRequestAccessibilityPermissions() { }
        
        let rainbowImage = NSImage(named: "Rainbow")!
        rainbowImage.size = .init(width: 18, height: 18)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = rainbowImage
        statusItem.button?.target = self
        statusItem.button?.action = #selector(activateStatusMenu(_:))

        NSApp.setActivationPolicy(.accessory)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bootstrap),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        bootstrap()

        _ = AXMonitor.main
    }

    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        .terminateNow
    }

    @objc
    func activateStatusMenu(_: Any) {
        popover.showPopover(statusItem: statusItem)
    }

    @objc
    func bootstrap() {
        for windowController in windowControllers {
            windowController.close()
        }
        windowControllers.removeAll()

        for screen in NSScreen.screens {
            windowControllers.append(createWindowController(for: screen))
        }
    }

    private func createWindowController(for screen: NSScreen) -> NSWindowController {
        let controller = DanmakuWindowController(screen: screen)
        controller.window?.setFrameOrigin(screen.frame.origin)
        controller.window?.setContentSize(screen.frame.size)
        controller.window?.makeKeyAndOrderFront(nil)
        return controller
    }
    
    private func checkAndRequestAccessibilityPermissions() -> Bool {
        if AXMonitor.accessibilityPermissionGranted() {
            print("[+] accessibility permission granted")
            return true
        } else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "请启用 “辅助功能” 权限后再试一次"
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return false
        }
    }
}
