//
//  CIMInputControllerGureum.swift
//  Gureum
//
//  Created by KMLee on 2018. 8. 24..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

extension CIMInputController {
    @IBAction func checkRecentVersion(_: Any) {
        guard let info = UpdateManager.shared.requestRecentVersion() else {
            return
        }

        if info.recent == info.current {
            let fmt = "현재 사용하고 있는 구름 입력기 \(info.current) 는 최신 버전입니다."
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            alert.informativeText = fmt
            alert.runModal()
        } else {
            var fmt = "현재 사용하고 있는 구름 입력기는 \(info.current) 이고 최신 버전은 \(info.recent) 입니다. 업데이트는 로그아웃하거나 " + "재부팅해야 적용됩니다."
            if info.note.count != 0 {
                fmt = fmt + " 업데이트 요약은 '\(info.note)' 입니다."
            }
            if info.download.count == 0 {
                fmt = fmt + " 곧 업데이트 링크가 준비될 예정입니다."
            }
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            alert.informativeText = fmt
            alert.runModal()
            if info.download.count > 0 {
                if let downloadUrl = URL(string: info.download) {
                    NSWorkspace.shared.open(downloadUrl)
                }
            }
        }
    }

    @IBAction func openWebsite(_: Any) {
        if let url = URL(string: "http://gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func openWebsiteHelp(_: Any) {
        if let url = URL(string: "http://dan.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func openWebsiteSource(_: Any) {
        if let url = URL(string: "http://ssi.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }

    @IBAction func openWebsiteIssues(_: Any) {
        if let url = URL(string: "http://meok.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }
}
