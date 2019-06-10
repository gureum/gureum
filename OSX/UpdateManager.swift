//
//  UpdateManager.swift
//  OSX
//
//  Created by Jeong YunWon on 01/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Foundation
import FoundationExtension

class UpdateManager {
    static let shared = UpdateManager()
    static let bundleVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

    class VersionInfo {
        let current: String? = UpdateManager.bundleVersion
        let data: [String: String]
        init(data: [String: String]) {
            self.data = data
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

    func fetchVersionInfo(from url: URL) -> VersionInfo? {
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
        return VersionInfo(data: info)
    }

    func fetchOfficialVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version.json")!
        return fetchVersionInfo(from: url)
    }

    func fetchExperimentalVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version-experimental.json")!
        return fetchVersionInfo(from: url)
    }

    func fetchAutoUpdateVersionInfo() -> VersionInfo? {
        guard let current = UpdateManager.bundleVersion else {
            return nil
        }
        if current.contains("-experimental") || current.contains("-rc") {
            return fetchExperimentalVersionInfo()
        } else {
            return fetchOfficialVersionInfo()
        }
    }

    func notifyUpdate(info: VersionInfo) {
        let notification = NSUserNotification()
        notification.title = "구름 입력기 업데이트 알림"
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
        notifyUpdate(info: info)
    }
}
