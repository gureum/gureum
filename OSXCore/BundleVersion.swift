//
//  BundleVersion.swift
//  OSXCore
//
//  Created by Jeong YunWon on 2020/07/18.
//  Copyright © 2020 youknowone.org. All rights reserved.
//

import Foundation

public extension Bundle {
    var version: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    var isExperimental: Bool {
        guard let current = version else {
            return false
        }
        return current.contains("-experimental") || current.contains("-rc")
    }
}
