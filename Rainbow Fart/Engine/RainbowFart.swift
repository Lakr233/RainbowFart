//
//  RainbowFart.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import Foundation

// do the test if needed
//
//  DispatchQueue.global().async {
//      let ret = RainbowFart.makeFart(keyword: "你好？") { str in
//          print(str, separator: "", terminator: "")
//          fflush(stdout)
//      }
//      print(ret)
//  }
//
//  success("你好👋！看到你，我心情愉悦😁，感觉今天会是个充满希望的一天！🌟\n")

class RainbowFart {
    private var timer: Timer!
    private var request: String?
    
    private init() {
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.timerCall()
        })
        RunLoop.main.add(timer, forMode: .common)
    }
    
    static let caller = RainbowFart()
    
    func buildPrompt(embedKeyword keyword: String) -> String {
        """
        你是一位彩虹屁制造机，专门负责夸夸和你说话的我。你说话非常有技巧，比如：
        1、使用惊叹号、省略号等标点符号增强表达力，营造紧迫感和惊喜感。
        2、使用emoji表情符号，来增加标题的活力 👏 🎉 🌈 🎀
        3、采用具有挑战性和悬念的表述，引发读、“无敌者好奇心，例如“暴涨词汇量”了”、“拒绝焦虑”等
        4、利用正面刺激和负面激，诱发读者的本能需求和动物基本驱动力，如“离离原上谱”、“你不知道的项目其实很赚”等
        5、融入热点话题和实用工具，提高文章的实用性和时效性，如“2023年必知”、“chatGPT狂飙进行时”等
        6、描述具体的成果和效果，强调标题中的关键词，使其更具吸引力，例如“英语底子再差，搞清这些语法你也能拿130+”

        下面是我所键入的内容：
        \(keyword)

        接下来，请查看上面的关键词，并用一句精炼简短的语句赞赏我。请直接与我对话，直接夸我。
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func makeFart(keyword: String) {
        if Thread.isMainThread {
            DispatchQueue.global().async {
                self.makeFart(keyword: keyword)
            }
            return
        }
        print("[+] making fart with keyword: \(keyword)")
        InterfereEngine.main.terminateAll()
        DanmakuPublisher.shared.streamingBuffer = ""
        let ans = InterfereEngine.main.interfere(
            prompt: buildPrompt(embedKeyword: buildPrompt(embedKeyword: keyword))
        ) { streamingToken in
            DanmakuPublisher.shared.streamingBuffer += streamingToken
        }
        DanmakuPublisher.shared.streamingBuffer = ""
        InterfereEngine.main.decode(result: ans) { fart in
            DanmakuPublisher.shared.insert(danmakuText: fart)
        } error: { err in
            print(err.localizedDescription)
        }
    }
    
    func reuqestFart(keyword: String) {
        request = keyword
    }
    
    func timerCall() {
        let request = request
        self.request = nil
        guard let request else { return }
        makeFart(keyword: request)
    }
}
