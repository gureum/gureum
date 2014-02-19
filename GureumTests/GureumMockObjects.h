//
//  GureumMockObjects.h
//  CharmIM
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface CIMMockClient : NSTextView 

- (NSString *)markedString;

@end


@interface VirtualApp: NSObject

@property(nonatomic,strong) CIMInputController *controller;
@property(nonatomic,strong) CIMMockClient *client;
- (BOOL)inputText:(NSString *)text key:(NSUInteger)keyCode modifiers:(NSUInteger)flags;

@end


@interface ModerateApp: VirtualApp

@end


@interface TerminalApp: VirtualApp

@end


@interface GreedyApp: VirtualApp

@end
