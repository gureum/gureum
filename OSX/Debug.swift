//
//  Debug.swift
//  OSX
//
//  Created by Jeong YunWon on 05/10/2018.
//  Copyright © 2018 youknowone.org. All rights reserved.
//

import Foundation

#if DEBUG
func dlog(_ flag: Bool, _ format: String, _ args: CVarArg...) {
    guard flag else {
        return
    }
    NSLogv(format, getVaList(args))
}
#else
func dlog(_ args: CVarArg...) {
    // do nothing in release mode
}
#endif
