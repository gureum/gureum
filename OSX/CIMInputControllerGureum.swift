//
//  CIMInputControllerGureum.swift
//  OSX
//
//  Created by KMLee on 2018. 8. 24..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation
import Cocoa

extension CIMInputController {
    @IBAction func checkRecentVersion(_ sender: Any) {
        let versionInfo = GureumAppDelegate.shared().recentVersion
        if versionInfo == nil {
            return
        }
        
        let recent = versionInfo!["recent"] as? String
        let current = versionInfo!["current"] as? String
        let download = versionInfo!["download"] as? String
        let note = versionInfo!["note"] as? String
        
        if (recent == current) {
            let fmt = "현재 사용하고 있는 구름 입력기 \(current ?? "") 는 최신 버전입니다."
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            alert.informativeText = fmt
            alert.runModal()
        } else {
            var fmt = "현재 사용하고 있는 구름 입력기는 \(current ?? "") 이고 최신 버전은 \(recent ?? "") 입니다. 업데이트는 로그아웃하거나 " + "재부팅해야 적용됩니다."
            if note?.count != 0 {
                fmt = fmt + " 업데이트 요약은 '\(note ?? "")' 입니다."
            }
            if download?.count == 0 {
                fmt = fmt + " 곧 업데이트 링크가 준비될 예정입니다."
            }
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            alert.informativeText = fmt
            alert.runModal()
            if (download?.count)! > 0 {
                if let downloadUrl = URL(string: download ?? "") {
                    NSWorkspace.shared.open(downloadUrl)
                }
            }
        }
    }
    
    @IBAction func openWebsite(_ sender:Any) {
        if let url = URL(string: "http://gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openWebsiteHelp(_ sender:Any) {
        if let url = URL(string: "http://dan.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openWebsiteSource(_ sender:Any) {
        if let url = URL(string: "http://ssi.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openWebsiteIssues(_ sender:Any) {
        if let url = URL(string: "http://meok.gureum.io") {
            NSWorkspace.shared.open(url)
        }
    }
}
