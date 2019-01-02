//
//  CIMApplicationDelegate.swift
//  Gureum
//
//  Created by KMLee on 2018. 9. 6..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol CIMApplicationDelegate: NSObjectProtocol {
    /*!
     @brief  합성기 생성
     
     입력 소스 별로 사용할 합성기를 만들어 반환한다.
     */
    @objc func composer(server: IMKServer!, client: Any!) -> CIMComposer
    //! @brief  언어 설정에 추가될 메뉴
    @objc var menu: NSMenu! { get }
}
