//
//  DanmakuStatus.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import Foundation

class DanmakuPublisher: ObservableObject {
    @Published var streamingBuffer: String = ""
    @Published var list: [Danmaku] = []

    static let shared = DanmakuPublisher()
    private init() {
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.timerCall()
        })
        RunLoop.main.add(timer, forMode: .common)
    }

    private let maxHolder = 4
    private let interval: TimeInterval = 8
    private var timer: Timer!

    struct Danmaku: Identifiable, Equatable {
        let id: UUID
        let text: String
        let createdAt: Date

        init(text: String) {
            self.text = text
            id = .init()
            createdAt = .init()
        }
    }

    public func insert(danmakuText text: String) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.insert(danmakuText: text)
            }
            return
        }

        while list.count > maxHolder - 1, !list.isEmpty {
            list.removeFirst()
        }
        list.append(.init(text: text))
    }

    public func timerCall() {
        // RunLoop.main.add(timer, forMode: .common)
        // so we are good to go?

        list = list.filter { $0.createdAt + interval > Date.now }
    }
}
