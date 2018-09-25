//
//  HangulComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

@import Hangul;

#import "CIMComposer.h"

@class GureumConfiguration;

@interface HanjaComposer : CIMComposer {
    NSMutableArray *_candidates;
    NSMutableString *bufferedString;
    NSString *composedString;
    NSString *commitString;

    BOOL _mode;
}

- (void)updateHanjaCandidates;
- (void)updateFromController:(id)controller;

@property(nonatomic, readonly) HGHanjaTable *characterTable, *wordTable, *reversedTable, *MSSymbolTable, *emoticonTable, *emoticonReversedTable;
@property(nonatomic, retain) NSArray *candidates;
@property(nonatomic, assign) BOOL mode;

@end
