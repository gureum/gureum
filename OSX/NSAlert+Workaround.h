//
//  NSAlert+Workaround.h
//  OSX
//
//  Created by Jeong YunWon on 2018. 9. 2..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

@import Foundation;
@import AppKit;

@interface NSAlert (Workaround)

- (void)beginSheetModalForEmptyWindowWithCompletionHandler:(void (^ __nullable)(NSModalResponse returnCode))handler NS_AVAILABLE_MAC(10_9);

@end
