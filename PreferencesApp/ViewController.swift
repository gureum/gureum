//
//  ViewController.swift
//  PreferencesApp
//
//  Created by Jeong YunWon on 2018. 9. 20..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Cocoa


class TestWindowController: NSWindowController {
    
    override func windowDidLoad() {
        var _objects: NSArray? = nil
        guard (NSNib(nibNamed: NSNib.Name("Preferences"), bundle: nil)!.instantiate(withOwner: nil, topLevelObjects: &_objects)) else {
            NSLog("something wrong")
            assert(false)
            return
        }
        guard let objects = _objects else {
            assert(false)
            return
        }
        
        for object in objects {
            if object is NSApplication {
                continue
            }
            guard let window = object as? NSWindow else {
                continue
            }
            window.showsResizeIndicator = true
            self.window = window
            return
        }
    }
}
