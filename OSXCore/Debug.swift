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

    func dassert(_ assertion: Bool) {
        assert(assertion)
    }
#else
    func dlog(_: CVarArg...) {
        // do nothing in release mode
    }

    func dassert(_: Bool) {
        // do nothing in release mode
    }
#endif
