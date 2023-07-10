//
//  DanmakuWindow.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import Cocoa
import SwiftUI

class DanmakuWindow: NSWindow {
    override init(contentRect: NSRect, styleMask _: NSWindow.StyleMask, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: backing,
            defer: flag
        )

        isOpaque = false
        alphaValue = 1
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = NSColor.clear
        ignoresMouseEvents = true
        isMovable = false
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
        ]
        level = .statusBar
        hasShadow = false
    }

    override var canBecomeKey: Bool {
        false
    }

    override var canBecomeMain: Bool {
        false
    }
}

class DanmakuWindowController: NSWindowController {
    convenience init(screen: NSScreen) {
        let window = DanmakuWindow(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        self.init(window: window)
        contentViewController = NSHostingController(rootView: DanmakuPlacerView())
    }
}
