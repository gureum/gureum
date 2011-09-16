//
//  CIMAppDelegate.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CIMInputManager;
@class CIMComposer;

@protocol CIMApplicationDelegate<NSObject>

/*!
    @brief  공용 입력 처리기
*/
@property(nonatomic, readonly) CIMInputManager *sharedInputManager;
/*!
    @brief  합성기 생성
 
    입력 소스 별로 사용할 합성기를 만들어 반환한다.
*/
- (CIMComposer *)composerWithServer:(IMKServer *)server client:(id)client;

@end

#define CIMAppDelegate ((NSObject<CIMApplicationDelegate> *)[[NSApplication sharedApplication] delegate])