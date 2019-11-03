//
//  NSPrefPaneBundle.h
//  Gureum
//
//  Created by Jeong YunWon on 2014. 2. 19..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import Foundation;
@import PreferencePanes;

@interface NSPrefPaneBundle: NSObject

- (instancetype)initWithPath:(id)arg1;
- (BOOL)instantiatePrefPaneObject;
- (NSPreferencePane *)prefPaneObject;

@property(readonly) NSBundle *bundle;

@end
