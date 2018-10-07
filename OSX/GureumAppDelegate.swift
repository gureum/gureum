//
//  GureumAppDelegate.swift
//  Gureum
//
//  Created by 혜원 on 2018. 8. 27..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation
import Hangul

class NotificationCenterDelegate: NSObject, NSUserNotificationCenterDelegate{
    var download: String!

    override init(){
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
        case .actionButtonClicked:
            NSWorkspace.shared.open(URL(string: download)!)
        case .contentsClicked:
            NSWorkspace.shared.open(URL(string: download)!)
        default:
            break;
        }
    }
}

@objcMembers class GureumAppDelegate: NSObject, NSApplicationDelegate, CIMApplicationDelegate {
    @IBOutlet @objc var menu: NSMenu!
    @objc var sharedInputManager: CIMInputManager!
    let configuration = GureumConfiguration.shared()
    var notificationCenter = NSUserNotificationCenter.default
    var notificationCenterDelegate = NotificationCenterDelegate()

    struct VersionInfo {
        var recent: String
        var current: String
        var download: String
        var note: String
    }

    @objc override func awakeFromNib(){
        HGKeyboard.initialize()
        sharedInputManager = CIMInputManager()
        checkUpdate()
    }

    @objc func composer(server: IMKServer!, client: Any!) -> CIMComposer {
        let composer: CIMComposer = GureumComposer()
        return composer
    }

    func checkUpdate() {
        guard let info = (NSApp.delegate as! GureumAppDelegate).getRecentVersion() else {
            return
        }
        guard info.recent != info.current else {
            return
        }
        guard info.download.count > 0 else {
            return
        }
        guard info.recent != configuration.skippedVersion else {
            return
        }

        let fmt = "현재 버젼: \(info.current) 최신 버젼: \(info.recent)\n클릭 시 업데이트 페이지로 이동합니다."
        let notification = NSUserNotification()

        notification.title = "구름 입력기 업데이트 확인"
        notification.hasActionButton = true
        notification.hasReplyButton = false
        notification.actionButtonTitle = "업데이트"
        notification.otherButtonTitle = "취소"
        notification.informativeText = fmt
        notificationCenterDelegate.download = info.download

        notificationCenter.deliver(notification)
    }
    
    func getRecentVersion() -> VersionInfo? {
        return nil
        let url = URL(string: "http://gureum.io/version.txt")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        request.cachePolicy = .reloadIgnoringCacheData
        guard let data = try? NSData(contentsOf: request, error: ()) else {
            return nil
        }
        if data.length == 0 { // 위에서 제대로 안걸림
            return nil
        }
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let verstring = String(data: data as Data, encoding: String.Encoding.utf8)!
        var components = verstring.components(separatedBy: "::")
        let version = VersionInfo(recent: components[0], current: currentVersion, download: components[1], note: components[2])
        return version
    }
}
