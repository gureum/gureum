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
    @objc var _sharedInputManager:CIMInputManager?
    
    @objc override func awakeFromNib(){
        HGKeyboard.initialize()
        
        _sharedInputManager = CIMInputManager()
       
        let versionInfo = (NSApp.delegate as! GureumAppDelegate).getRecentVersion()
        
        let recent = versionInfo["recent"]
        let current = versionInfo["current"]
        let download = versionInfo["download"]
        let note: String? = versionInfo["note"]
        
        if recent != current && (download?.count)! > 0 {
            var fmt = "현재 사용하고 있는 구름 입력기는 \(current ?? "") 이고 최신 버전은 \(recent ?? "") 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다."
            if note?.count != 0 {
                fmt += " 업데이트 요약은 \(note ?? "") 입니다."
            }
            let alert = NSAlert()
            alert.messageText = "구름 입력기 업데이트 확인"
            alert.addButton(withTitle: "확인")
            alert.addButton(withTitle: "취소")
            alert.informativeText = fmt
            
            assert(NSApp.windows.count > 0)
            let window = NSApp.windows[0]
            alert.beginSheetModalForEmptyWindow(completionHandler: {(modalResponse: NSApplication.ModalResponse) -> Void in
                if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                    self.alertDidEnd(contextInfo: download!)
                }
                NSLog("alert done")
            })
            
        }
    }
    
    @objc func alertDidEnd(contextInfo: String){
        if let downloadUrl = URL(string: contextInfo) {
            NSWorkspace.shared.open(downloadUrl)
        }
    }
    
    @objc func sharedInputManager() -> CIMInputManager! {
        return self._sharedInputManager
    }
    
    @objc func composer(server: IMKServer, client: Any) -> CIMComposer{
        let composer:CIMComposer = GureumComposer()
        return composer
    }
    
    @objc func getRecentVersion() -> Dictionary<String, String> {
        let url = URL(string: "http://gureum.io/version.txt")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        guard let data = try? NSData(contentsOf: request, error: ()) else {
            return [:]
        }
        let verstring = try! String(data: data as Data, encoding: String.Encoding.utf8)
        var components = verstring?.components(separatedBy: "::")
        let recentVersion = components![0]
        let recentDownload = components![1]
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        if (components?.count)! >= 3 {
            let releaseNote = components?[2]
            return ["recent": recentVersion, "current": currentVersion, "download": recentDownload, "note": releaseNote ?? ""]
        }
        else{
            return ["recent": recentVersion, "current": currentVersion, "download": recentDownload]
            
        }
    }
}
