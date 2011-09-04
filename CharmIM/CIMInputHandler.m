//
//  CIMInputHandler.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"
#import "CIMInputHandler.h"
#import "CIMHangulComposer.h"

#define DEBUG_INPUTHANDLER TRUE

@implementation CIMInputHandler
@synthesize manager;

- (id)initWithManager:(CIMInputManager *)aManager {
    self = [super init];
    ICLog(DEBUG_INPUTHANDLER, @"** CIMInputHandler inited: %@ / with manage: %@", self, aManager);
    if (self) {
        self->manager = aManager;
    }
    return self;
}

- (void)setManager:(CIMInputManager *)aManager {
    self->manager = aManager;
}

#pragma - IMKServerInputTextData

- (BOOL)inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)sender {   
    if (flags & NSCommandKeyMask) {
        // 특정 애플리케이션에서 커맨드 키 입력을 선점하지 못하는 문제를 회피한다.
        ICLog(TRUE, @"-- CIMInputHandler -inputText: Command key input / returned NO");
        return NO;
    }
    return [self->manager.currentComposer inputText:string key:keyCode modifiers:flags client:sender];
}

@end