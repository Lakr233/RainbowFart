//
//  StatusBarPopover.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import Cocoa
import SwiftUI

struct StatusBarPopoverView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                Button("退出") { exit(0) }
            }
            Image("Avatar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64, alignment: .center)
            Text("彩虹屁天国！大家一起来～")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text("Copyright © 2023 [@Lakr233](https://twitter.com/Lakr233). All Rights Reserved.")
                .font(.system(size: 8, weight: .semibold, design: .rounded))
        }
        .frame(width: 400, alignment: .center)
        .padding()
    }
}

class StatusBarPopover: NSPopover {
    var eventMonitor: EventMonitor!

    override init() {
        super.init()
        contentViewController = NSHostingController(rootView: StatusBarPopoverView())
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
    }

    func mouseEventHandler(_: NSEvent?) {
        if isShown { hidePopover() }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func showPopover(statusItem: NSStatusItem) {
        if let statusBarButton = statusItem.button {
            show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            eventMonitor.start()
        }
    }

    func hidePopover() {
        performClose(nil)
        eventMonitor.stop()
    }
}
