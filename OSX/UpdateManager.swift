//
//  UpdateManager.swift
//  OSX
//
//  Created by Jeong YunWon on 01/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation


class UpdateManager {

    public static let shared = UpdateManager()

    struct VersionInfo {
        var recent: String
        var current: String
        var download: String
        var note: String
    }

    func requestRecentVersion() -> VersionInfo? {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        var url: URL
        if currentVersion.contains("-pre") {
            url = URL(string: "http://gureum.io/version-pre.txt")!
        } else {
            url = URL(string: "http://gureum.io/version.txt")!
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        request.cachePolicy = .reloadIgnoringCacheData
        guard let data = try? NSData(contentsOf: request, error: ()) else {
            return nil
        }
        if data.length == 0 { // 위에서 제대로 안걸림
            return nil
        }
        let verstring = String(data: data as Data, encoding: String.Encoding.utf8)!
        var components = verstring.components(separatedBy: "::")
        let version = VersionInfo(recent: components[0], current: currentVersion, download: components[1], note: components[2])
        return version
    }

    func notifyUpdate(info: VersionInfo) {
        let notification = NSUserNotification()
        notification.title = "구름 입력기 업데이트 알림"
        notification.hasActionButton = true
        notification.hasReplyButton = false
        notification.actionButtonTitle = "업데이트"
        notification.otherButtonTitle = "취소"
        notification.informativeText = "최신 버전: \(info.recent) 현재 버전: \(info.current)\n\(info.note)"
        notification.userInfo = ["download": info.download]

        NSUserNotificationCenter.default.deliver(notification)
    }

    func notifyUpdateIfNeeded() {
        guard let info = requestRecentVersion() else {
            return
        }
        guard info.recent != info.current else {
            return
        }
        guard info.download.count > 0 else {
            return
        }
        self.notifyUpdate(info: info)
    }
}
