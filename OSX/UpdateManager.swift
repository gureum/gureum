//
//  UpdateManager.swift
//  OSX
//
//  Created by Jeong YunWon on 01/01/2019.
//  Copyright © 2019 youknowone.org. All rights reserved.
//

import Alamofire
import Foundation
import GureumCore

class UpdateManager {
    static let shared = UpdateManager()

    struct UpdateInfo: Decodable {
        let version: String
        let description: String
        let url: String

        enum CodingKeys: String, CodingKey {
            case version
            case description
            case url
        }
    }

    struct VersionInfo {
        let current: String? = Bundle.main.version
        let update: UpdateInfo
        let experimental: Bool
    }

    func fetchUpdateInfo(from url: URL) -> UpdateInfo? {
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 0.5
        urlRequest.cachePolicy = .reloadIgnoringCacheData

        let request = AF.request(urlRequest)
//        request.responseJSON {
//            data in
//            print("data!", data)
//        }

        var info: UpdateInfo?
        request.validate().responseDecodable(of: UpdateInfo.self) { response in
            guard let result = response.value else { return }
            info = result
        }
        return info
    }

    func fetchStableVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version.json")!
        guard let update = fetchUpdateInfo(from: url) else {
            return nil
        }
        return VersionInfo(update: update, experimental: false)
    }

    func fetchExperimentalVersionInfo() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version-experimental.json")!
        guard let update = fetchUpdateInfo(from: url) else {
            return nil
        }
        return VersionInfo(update: update, experimental: true)
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
        notification.informativeText = "최신 버전: \(info.update.version) 현재 버전: \(info.current ?? "-")\n\(info.update.description)"
        notification.userInfo = ["url": info.update.url]

        NSUserNotificationCenter.default.deliver(notification)
    }

    func notifyUpdateIfNeeded() {
        guard let info = fetchAutoUpdateVersionInfo() else {
            return
        }
        guard info.update.version != info.current else {
            return
        }
        UpdateManager.notifyUpdate(info: info)
    }
}
