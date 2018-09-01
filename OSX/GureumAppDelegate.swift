//
//  GureumAppDelegate.swift
//  OSX
//
//  Created by 혜원 on 2018. 8. 27..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation

@objcMembers class GureumAppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet @objc var menu: NSMenu!
    
    @objc var recentVersion: String = ""
    @objc var recentDownload: String = ""
    @objc var releaseNote: String?
    @objc var currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    @objc var _sharedInputManager:CIMInputManager?
    
    @objc override func awakeFromNib(){
        HGKeyboard.initialize()
        
        _sharedInputManager = CIMInputManager()
        let x = getRecentVersion()
        
        if recentVersion != currentVersion && recentDownload.count > 0 {
            var fmt = "현재 사용하고 있는 구름 입력기는 \(currentVersion) 이고 최신 버전은 \(recentVersion) 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다."
            if releaseNote?.count != 0 {
                fmt += " 업데이트 요약은 \(releaseNote) 입니다."
            }
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            //alert.addButton(withTitle: "취소")
            alert.informativeText = fmt
            
            assert(NSApp.windows.count > 0)
            let window = NSApp.windows[0]
            alert.beginSheetModal(for: window)
            
        }
    }
    
    @objc func sharedInputManager() -> CIMInputManager! {
        return self._sharedInputManager
    }
    
    @objc func composer(server: IMKServer, client: Any) -> CIMComposer{
        let composer:CIMComposer = GureumComposer()
        return composer
    }
    
    @objc func getRecentVersion() -> Dictionary<String,Any> {
        NSLog("1")
        let url = URL(string: "http://gureum.io/version.txt")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        NSLog("2")
        guard let data = try? NSData(contentsOf: request, error: ()) else {
            NSLog("3")
            return [:]
        }
        
        NSLog("4")
        let verstring = try! String(data: data as Data, encoding: String.Encoding.utf8)
        var components = verstring?.components(separatedBy: "::")
        recentVersion = components![0]
        recentDownload = components![1]
        if (components?.count)! >= 3 {
            releaseNote = components?[2]
        }
        NSLog("5")
        return [:]
    }
}
