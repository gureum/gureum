//
//  InputControllerGureum.swift
//  Gureum
//
//  Created by KMLee on 2018. 8. 24..
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation
import GureumCore

let preferencesWindow: NSWindowController = NSStoryboard(name: "Configuration", bundle: Bundle.main).instantiateInitialController() as! NSWindowController

// 왜 App delegate가 아니라 여기 붙는건지 모르겠다
extension InputController {
    @IBAction func showStandardAboutPanel(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(sender)
        answers.logMenu(name: "about")
    }

    @IBAction func showPreferencesWindow(_: Any) {
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindow.showWindow(nil)
    }

    private func checkVersion(mode: UpdateMode) {
        var title = ""
        var version = ""
        switch mode {
        case .Stable:
            title = "업데이트"
            version = "버전"
        case .Experimental:
            title = "실험 버전"
            version = "실험 버전"
        }
        UpdateManager.shared.requestVersionInfo(mode: mode) { info in
            guard let info = info else {
                let alert = NSAlert()
                alert.messageText = "구름 입력기 \(title) 확인"
                alert.addButton(withTitle: "확인")
                alert.informativeText = "\(title) 정보에 접근할 수 없습니다. 인터넷에 연결되어 있지 않거나 구름 업데이트의 버그일 수 있습니다."
                alert.runModal()
                return
            }
            if info.update.version == info.current {
                let fmt = "현재 사용하고 있는 구름 입력기 \(info.current ?? "-") 는 최신 \(version)입니다."
                let alert = NSAlert()
                alert.messageText = "구름 입력기 \(title) 확인"
                alert.addButton(withTitle: "확인")
                alert.informativeText = fmt
                alert.runModal()
            } else {
                var message = "현재 사용하고 있는 구름 입력기는 \(info.current ?? "-") 이고 최신 \(version)은 \(info.update.version) 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다."
                if !info.update.description.isEmpty {
                    message += " 업데이트 요약은 '\(info.update.description)' 입니다."
                }
                if let url = URL(string: info.update.url) {
                    NSWorkspace.shared.open(url)
                } else {
                    message += " 현재 업데이트 링크를 찾을 수 없습니다. 버그 리포트를 부탁드립니다."
                }
                let alert = NSAlert()
                alert.messageText = "구름 입력기 \(title) 확인"
                alert.addButton(withTitle: "확인")
                alert.informativeText = message
                alert.runModal()
            }
        }
    }

    @IBAction func checkRecentVersion(_: Any) {
        answers.logMenu(name: "check-version")
        checkVersion(mode: .Stable)
    }

    @IBAction func checkExperimentalVersion(_: Any) {
        answers.logMenu(name: "check-experimental")
        checkVersion(mode: .Experimental)
    }

    @IBAction func openWebsite(_: Any) {
        let url = URL(string: "http://gureum.io")!
        NSWorkspace.shared.open(url)
        answers.logMenu(name: "website")
    }

    @IBAction func openWebsiteHelp(_: Any) {
        let url = URL(string: "http://dan.gureum.io")!
        NSWorkspace.shared.open(url)
        answers.logMenu(name: "website-help")
    }

    @IBAction func openWebsiteSource(_: Any) {
        let url = URL(string: "http://ssi.gureum.io")!
        NSWorkspace.shared.open(url)
        answers.logMenu(name: "website-source")
    }

    @IBAction func openWebsiteIssues(_: Any) {
        let url = URL(string: "http://meok.gureum.io")!
        NSWorkspace.shared.open(url)
        answers.logMenu(name: "website-issues")
    }

    @IBAction func openWebsiteDonation(_: Any) {
        let url = URL(string: "http://donation.gureum.io")!
        NSWorkspace.shared.open(url)
        answers.logMenu(name: "website-donation")
    }
}
