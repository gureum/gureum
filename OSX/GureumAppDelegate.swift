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
    @objc static var _sharedInputManager = CIMInputManager()
    
    struct VersionInfo {
        var recent: String
        var current: String
        var download: String
        var note: String
    }
    
    @objc override func awakeFromNib(){
        HGKeyboard.initialize()
        
        guard let info = (NSApp.delegate as! GureumAppDelegate).getRecentVersion() else {
            return
        }
        guard  info.recent != info.current else {
            return
        }
        guard info.download.count > 0 else {
            return
        }
        
        var fmt = "현재 사용하고 있는 구름 입력기는 \(info.current) 이고 최신 버전은 \(info.recent) 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다."
        if info.note.count != 0 {
            fmt += " 업데이트 요약은 \(info.note) 입니다."
        }
        let alert = NSAlert()
        alert.messageText = "구름 입력기 업데이트 확인"
        alert.addButton(withTitle: "확인")
        alert.addButton(withTitle: "취소")
        alert.informativeText = fmt
        
        alert.beginSheetModalForEmptyWindow(completionHandler: {(modalResponse: NSApplication.ModalResponse) -> Void in
            if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                NSWorkspace.shared.open(URL(string: info.download)!)
            }
        })
    }
    
    @objc func sharedInputManager() -> CIMInputManager! {
        return GureumAppDelegate._sharedInputManager
    }
    
    @objc func composer(server: IMKServer, client: Any) -> CIMComposer {
        let composer: CIMComposer = GureumComposer()
        return composer
    }
    
    func getRecentVersion() -> VersionInfo? {
        let url = URL(string: "http://gureum.io/version.txt")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 0.5
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
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
