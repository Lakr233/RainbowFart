//
//  DanmakuView.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import SwiftUI

struct DanmakuPlacerView: View {
    var body: some View {
        DanmakuView()
            .frame(width: 400)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
}

struct DanmakuView: View {
    @StateObject var danmakuPublisher = DanmakuPublisher.shared
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(danmakuPublisher.list) { danmaku in
                Text(danmaku.text)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(4)
                    .background(.thinMaterial.opacity(0.5))
                    .cornerRadius(4)
            }
            
            Text(danmakuPublisher.streamingBuffer)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .truncationMode(.head)
                .padding(4)
                .background(.thinMaterial.opacity(0.5))
                .cornerRadius(4)
                .opacity(danmakuPublisher.streamingBuffer.count > 0 ? 1 : 0)
        }
        .animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 1), value: danmakuPublisher.list)
        .animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 1), value: danmakuPublisher.streamingBuffer)
    }
}
