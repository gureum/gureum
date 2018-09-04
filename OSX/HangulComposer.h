//
//  HangulComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Hangul/HGCharacter.h>
#import <Hangul/HGHanja.h>
#import "CIMComposer.h"

typedef NS_ENUM(unsigned int, HangulCharacterCombinationMode) {
    // 채움 문자는 모두 지우고 결합해 표현한다.
    HangulCharacterCombinationWithoutFiller = 0,
    // 없는 자소가 있더라도 모두 채움 문자와 결합해 표현한다.
    HangulCharacterCombinationWithFiller = 1,
    // 중성이 빠졌을 경우만 채움 문자를 이용한다.
    HangulCharacterCombinationWithOnlyJungseongFiller = 2,
    // 채움 문자 뒤는 숨긴다.
    HangulCharacterCombinationHiddenOnFiller = 3,
    // 중성 채움 문자 뒤는 숨긴다.
    HangulCharacterCombinationHiddenOnJungseongFiller = 4,
};
#define HangulCharacterCombinationModeCount 5

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

@property(nonatomic, readonly) HangulComposer *hangulComposer;
@property(nonatomic, readonly) HGHanjaTable *characterTable, *wordTable, *reversedTable, *MSSymbolTable, *emoticonTable, *emoticonReversedTable;
@property(nonatomic, retain) NSArray *candidates;
@property(nonatomic, assign) BOOL mode;

@end
