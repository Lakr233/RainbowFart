//
//  AXMonitor.swift
//  Rainbow Fart
//
//  Created by QAQ on 2023/7/11.
//

import AppKit
import Foundation

class AXMonitor {
    static let main = AXMonitor()

    var timer: Timer!
    private init() {
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.timerCall()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    private var lastAcquire: String = ""

    func timerCall() {
        guard let str = getActiveTextFieldValue() else { return }
        guard lastAcquire != str else { return }
        lastAcquire = str
        sendToEngine(text: str)
    }

    func sendToEngine(text: String) {
        var keyword = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if keyword.count > 50 {
            keyword.removeFirst(keyword.count - 50)
        }
        keyword = keyword.replacingOccurrences(of: "\n", with: " ")
        keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        RainbowFart.caller.reuqestFart(keyword: keyword)
    }

    func getActiveTextFieldValue() -> String? {
        let systemWideElement: AXUIElement = AXUIElementCreateSystemWide()

        var focusedApp: AnyObject?
        AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedApplicationAttribute as CFString,
            &focusedApp
        )
        guard let focusedApp else { return nil }
        
        var focusedElement: AnyObject?
        AXUIElementCopyAttributeValue(
            focusedApp as! AXUIElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        guard let focusedElement else { return nil }

        var elementValue: AnyObject?
        AXUIElementCopyAttributeValue(
            focusedElement as! AXUIElement,
            kAXValueAttribute as CFString,
            &elementValue
        )
        guard let elementValue else { return nil }

        var selectedRangeValue: AnyObject?
        AXUIElementCopyAttributeValue(
            focusedElement as! AXUIElement,
            kAXSelectedTextRangeAttribute as CFString,
            &selectedRangeValue
        )
        guard let selectedRangeValue else { return nil }
        
        let fullText = elementValue as? String
        var range = CFRangeMake(0, 0)
        AXValueGetValue(selectedRangeValue as! AXValue, AXValueType.cfRange, &range)
        
        guard range.location > 0 || range.length > 0, let fullText else { return nil }
        
        var ans: String?
        if range.length > 0 {
            // selected, return selected string
            guard range.location + range.length <= fullText.utf16.count else { return nil }
            let startIndex = String.Index(utf16Offset: range.location, in: fullText)
            let endIndex = String.Index(utf16Offset: range.location + range.length, in: fullText)
            ans = String(fullText[startIndex..<endIndex])
        } else {
            // not selected, return preceding text
            guard range.location <= fullText.utf16.count else { return nil }
            let index = String.Index(utf16Offset: range.location, in: fullText)
            ans = String(fullText[..<index])
        }
        return ans
    }
    
    public static func accessibilityPermissionGranted() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}


// For some reason values don't get described in this enum, so we have to do it manually.
extension AXError: CustomStringConvertible {
  fileprivate var valueAsString: String {
    switch (self) {
    case .success:
      return "Success"
    case .failure:
      return "Failure"
    case .illegalArgument:
      return "IllegalArgument"
    case .invalidUIElement:
      return "InvalidUIElement"
    case .invalidUIElementObserver:
      return "InvalidUIElementObserver"
    case .cannotComplete:
      return "CannotComplete"
    case .attributeUnsupported:
      return "AttributeUnsupported"
    case .actionUnsupported:
      return "ActionUnsupported"
    case .notificationUnsupported:
      return "NotificationUnsupported"
    case .notImplemented:
      return "NotImplemented"
    case .notificationAlreadyRegistered:
      return "NotificationAlreadyRegistered"
    case .notificationNotRegistered:
      return "NotificationNotRegistered"
    case .apiDisabled:
      return "APIDisabled"
    case .noValue:
      return "NoValue"
    case .parameterizedAttributeUnsupported:
      return "ParameterizedAttributeUnsupported"
    case .notEnoughPrecision:
      return "NotEnoughPrecision"
    @unknown default:
        return "Unknown"
    }
  }

  public var description: String {
    return "AXError.\(valueAsString)"
  }
}
