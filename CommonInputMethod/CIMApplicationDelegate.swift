//
//  CIMApplicationDelegate.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 6..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Cocoa
import Foundation

@objc protocol CIMApplicationDelegate: NSObjectProtocol {
    //! @brief  언어 설정에 추가될 메뉴
    @objc var menu: NSMenu! { get }
}
