//
//  main.swift
//  Gureum
//
//  Created by Jeong YunWon on 2018. 9. 26..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Cocoa

//_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

//dlog(TRUE, @"******* CharmIM initialized! *******")
let mainNibName = Bundle.main.infoDictionary!["NSMainNibFile"] as! String
let nib = NSNib(nibNamed: NSNib.Name(mainNibName), bundle: Bundle.main)!
if nib.instantiate(withOwner: NSApplication.shared, topLevelObjects: nil) == false {
    dlog(true, "!! CharmIM fails to load Main Nib File !!")
}
//dlog(TRUE, @"****   Main bundle %@ loaded   ****", mainNibName)
NSApplication.shared.run()
//dlog(TRUE, @"******* CharmIM finalized! *******")
