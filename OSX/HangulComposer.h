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

@class HGInputContext;

/*!
    @brief  libhangul을 사용하는 합성기

    libhangul의 input context를 사용하는 합성기이다. -init 로는 두벌식 합성기가 설정된다.

    @coclass HGInputContext
*/
@interface HangulComposer : NSObject<CIMComposerDelegate> {
    HGInputContext *_Nonnull _inputContext;
    NSMutableString *_Nonnull _commitString;
    id bridge;
}
@property(nonatomic, retain) NSMutableString *commitString; // Swift bridge support

@property(nonatomic, readonly, nonnull) HGInputContext *inputContext;
- (HGInputContext *)inputContext;

/*!
    @brief  libhangul의 input context를 사용하는 합성기를 초기화한다.
    @param  identifier  libhangul의 @ref hangul_ic_select_keyboard 를 참고한다.
*/
- (instancetype)initWithKeyboardIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
/*!
    @brief  현재 context의 배열을 바꾼다.
    @param  identifier  libhangul의 @ref hangul_ic_select_keyboard 를 참고한다.
*/
- (void)setKeyboardWithIdentifier:(NSString *)identifier;

@end

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
