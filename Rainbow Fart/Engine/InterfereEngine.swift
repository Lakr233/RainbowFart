//
//  Interfere.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/10.
//

import AuxiliaryExecute
import Foundation

private enum EngineDefinition: String {
    case binaryName = "interfere"
    case modelName = "chatglm2-ggml.bin"
}

private extension Optional {
    func unwrapOrFatal(_ messageOnFailure: String) -> Wrapped {
        guard let t = self else {
            fatalError(messageOnFailure)
        }
        return t
    }
}

public class InterfereEngine {
    static let main = InterfereEngine()

    typealias StreamingTextBlock = (String) -> Void
    typealias InterfereResult = Result<String, InterfereError>

    enum InterfereError: Error {
        case missingEngineExecutable
        case missingEngineModel
        case unableToExecute
        case terminated
        case unknown
    }

    private let bundleExecutable: URL
    private let bundleModel: URL

    private let accessLock = NSLock()
    private var runningEnginePids = Set<pid_t>()

    private init() {
        let execPath = Bundle.main
            .path(forResource: EngineDefinition.binaryName.rawValue, ofType: nil)
            .unwrapOrFatal("unable to find interfere engine executable")
        bundleExecutable = URL(fileURLWithPath: execPath)
        print("[+] loaded executable \(execPath)")

        let modelPath = Bundle.main
            .path(forResource: EngineDefinition.modelName.rawValue, ofType: nil)
            .unwrapOrFatal("unable to find interfere engine model")
        bundleModel = URL(fileURLWithPath: modelPath)
        print("[+] loaded model \(modelPath)")
    }
    
    func isAnyEngineExecuting() -> Bool {
        accessLock.lock()
        let ans = !runningEnginePids.isEmpty
        accessLock.unlock()
        return ans
    }

    func terminateAll() {
        accessLock.lock()
        runningEnginePids = runningEnginePids.filter {
            kill($0, SIGKILL)
            return false
        }
        accessLock.unlock()
    }

    @discardableResult
    func interfere(prompt: String, stream: StreamingTextBlock? = nil) -> InterfereResult {
        // ./interfere -m ./chatglm2-ggml.bin -p "你好"
        assert(!Thread.isMainThread, "interfere can not be called from main thread")
        var enginePid: pid_t? = nil
        defer {
            accessLock.lock()
            runningEnginePids.remove(enginePid ?? 0)
            accessLock.unlock()
        }

        let rec = AuxiliaryExecute.spawn(
            command: bundleExecutable.path,
            args: ["-m", bundleModel.path, "-p", prompt],
            environment: [:],
            timeout: 0
        ) { pid in
            print("[+] started engine with pid: \(pid)")
            enginePid = pid
            self.accessLock.lock()
            self.runningEnginePids.insert(pid)
            self.accessLock.unlock()
        } stdoutBlock: { str in
            stream?(str)
        } stderrBlock: { err in
            print("[?] \(enginePid ?? 0) stderr: \(err)")
        }

        if enginePid == nil, rec.pid <= 0 { return .failure(.unableToExecute) }
        if rec.exitCode == SIGKILL { return .failure(.terminated) }

        guard rec.exitCode == 0,
              rec.stdout.count > 0,
              rec.pid > 0
        else {
            return .failure(.unknown)
        }

        return .success(rec.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func decode(result: InterfereResult, success: (String) -> Void, error: (Error) -> Void) {
        switch result {
        case let .success(ans): success(ans)
        case let .failure(err): error(err)
        }
    }
}
