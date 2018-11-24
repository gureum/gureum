//
//  GureumAppDelegate.swift
//  Gureum
//
//  Created by 혜원 on 2018. 8. 27..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
import Crashlytics
import Fabric
import Foundation
import GureumCore
import Hangul

class NotificationCenterDelegate: NSObject, NSUserNotificationCenterDelegate {
    static let appDefault = NotificationCenterDelegate()

    func userNotificationCenter(_: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let download = userInfo["download"] as? String else {
            return
        }
        switch notification.activationType {
        case .actionButtonClicked:
            fallthrough
        case .contentsClicked:
            NSWorkspace.shared.open(URL(string: download)!)
        default:
            break
        }
    }
}

class GureumAppDelegate: NSObject, NSApplicationDelegate, GureumApplicationDelegate {
    @IBOutlet var menu: NSMenu!

    let configuration = Configuration.shared
    let notificationCenterDelegate = NotificationCenterDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])

        NSUserNotificationCenter.default.delegate = notificationCenterDelegate
        let notificationCenter = NSUserNotificationCenter.default
        #if DEBUG
            let notification = NSUserNotification()
            notification.title = "디버그 빌드 알림"
            notification.hasActionButton = false
            notification.hasReplyButton = false
            notification.informativeText = "이 버전은 디버그 빌드입니다. 키 입력이 로그로 남을 수 있어 안전하지 않습니다."
            notificationCenter.deliver(notification)
        #else
            Fabric.with([Crashlytics.self])
            Fabric.with([Answers.self])
        #endif

        UpdateManager.shared.notifyUpdateIfNeeded()

        // IMKServer를 띄워야만 입력기가 동작한다
        _ = InputMethodServer.shared

        reportLastInputMode()
    }

    func reportLastInputMode() {
        let lastInputModes = ["Roman": self.configuration.lastRomanInputMode, "Hangul": self.configuration.lastHangulInputMode]
        Answers.logCustomEvent(withName: "LastInputMode", customAttributes: lastInputModes)
    }
}
