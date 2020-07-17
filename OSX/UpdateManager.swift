//
//  UpdateManager.swift
//  OSX
//
//  Created by Jeong YunWon on 01/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation
import FoundationExtension
import GureumCore

class UpdateManager {
    static let shared = UpdateManager()

    class VersionInfo {
        let current: String? = Bundle.main.version
        let data: [String: String]
        let experimental: Bool
        init(data: [String: String], experimental: Bool) {
            self.data = data
            self.experimental = experimental
        }

        var recent: String? {
            return data["version"]
        }

        var url: URL? {
            guard let URLString = data["url"] else {
                return nil
            }
            return URL(string: URLString)
        }

        var description: String? {
            return data["description"]
        }
    }

    func fetchVersionInfo(from url: URL, experimental: Bool) -> VersionInfo? {
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        request.cachePolicy = .reloadIgnoringCacheData
        guard let data = try? NSData(contentsOf: request, error: ()) else {
            return nil
        }
        if data.length == 0 { // 위에서 제대로 안걸림
            return nil
        }
        guard let info = try? JSONSerialization.jsonObject(with: data as Data) as? [String: String] else {
            return nil
        }
        return VersionInfo(data: info, experimental: experimental)
    }

    func fetchStableVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version.json")!
        return fetchVersionInfo(from: url, experimental: false)
    }

    func fetchExperimentalVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version-experimental.json")!
        return fetchVersionInfo(from: url, experimental: true)
    }

    func fetchAutoUpdateVersionInfo() -> VersionInfo? {
        switch Configuration.shared.updateMode {
        case .None:
            return nil
        case .Stable:
            return fetchStableVersionInfo()
        case .Experimental:
            return fetchExperimentalVersionInfo()
        }
    }

    class func notifyUpdate(info: VersionInfo) {
        let notification = NSUserNotification()
        var title = "구름 입력기 업데이트 알림"
        if info.experimental {
            title += " (실험 버전)"
        }
        notification.title = title
        notification.hasActionButton = true
        notification.hasReplyButton = false
        notification.actionButtonTitle = "업데이트"
        notification.otherButtonTitle = "취소"
        notification.informativeText = "최신 버전: \(info.recent ?? "-") 현재 버전: \(info.current ?? "-")\n\(info.description ?? "")"
        if let url = info.url {
            // URL object is not delivered
            notification.userInfo = ["url": url.absoluteString]
        }

        NSUserNotificationCenter.default.deliver(notification)
    }

    func notifyUpdateIfNeeded() {
        guard let info = fetchAutoUpdateVersionInfo() else {
            return
        }
        guard info.recent != info.current else {
            return
        }
        guard info.url != nil else {
            return
        }
        UpdateManager.notifyUpdate(info: info)
    }
}
