//
//  AppDelegate.swift
//  PreferencesApp
//
//  Created by Jeong YunWon on 2018. 9. 20..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Fabric.with([Crashlytics.self])
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}
