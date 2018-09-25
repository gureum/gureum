//
//  HangulComposer.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 1..
//  Copyright 2011 youknowone.org. All rights reserved.
//

@import Hangul;

#import "HanjaComposer.h"

#import "CIMInputController.h"
#import "Gureum-Swift.h"

#define DEBUG_HANGULCOMPOSER FALSE
#define DEBUG_HANJACOMPOSER FALSE


@class CIMInputController;

@interface HanjaComposer ()

@property(nonatomic,retain) NSString *composedString, *commitString;

@end

@implementation HanjaComposer
@synthesize mode=_mode, composedString, commitString, candidates;

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self->bufferedString = [[NSMutableString alloc] init];
    }
    return self;
}

- (HangulComposer *)hangulComposer {
    return (id)self.delegate;
}

// 한글 입력기가 지금까지 완료한 조합 + 현재 진행 중인 조합
- (NSString *)originalString {
    return [self->bufferedString stringByAppendingString:self.hangulComposer.composedString];
}

- (void)setComposedString:(NSString *)string {
    self->composedString = string;
}

- (void)setCommitString:(NSString *)string {
    self->commitString = string;
}

- (NSString *)dequeueCommitString {
    NSString *res = self->commitString;
    if (res.length > 0) {
        [self->bufferedString setString:@""];
        self.commitString = @"";
    }
    return res;
}

- (void)cancelComposition {
    [self.hangulComposer cancelComposition];
    [self.hangulComposer dequeueCommitString];
    self.commitString = [self.commitString stringByAppendingString:self.composedString];
    [self->bufferedString setString:@""];
    self.composedString = @"";
}

- (void)composerSelected:(id)sender {
    [self->bufferedString setString:@""];
    self.commitString = @"";
}

- (void)updateHanjaCandidates {
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates");
    NSString *dequeueCommitString = self.hangulComposer.dequeueCommitString;
    // step 1: 한글 입력기에서 조합 완료된 글자를 가져옴
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates step1");
    [self->bufferedString appendString:dequeueCommitString];
    // step 2: 일단 화면에 한글이 표시되도록 조정
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates step2");
    self.composedString = self.originalString;
    // step 3: 키가 없거나 검색 결과가 키 prefix와 일치하지 않으면 후보를 보여주지 않는다.
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates step3");
    NSString *keyword = self.originalString;
    if (keyword.length == 0) {
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates no keywords");
        self.candidates = nil;
    } else {
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates candidates");
        NSMutableArray *candidates = [NSMutableArray array];
        for (HGHanjaTable *table in @[self.emoticonTable, self.MSSymbolTable, self.wordTable, self.reversedTable, self.emoticonReversedTable, self.characterTable]) {
            dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates getting list for table: %@", table);
            HGHanjaList *list = [table hanjasByPrefixSearching:keyword];
            dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates getting list: %@", list);
            for (HGHanja *hanja in list) {
                dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates hanja: %@", hanja);
                [candidates addObject:[NSString stringWithFormat:@"%@: %@", hanja.value, hanja.comment]];
            }
        }
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates candidating");
        if (candidates.count > 0 && [GureumConfiguration shared].showsInputForHanjaCandidates) {
            [candidates insertObject:keyword atIndex:0];
        }
        self.candidates = candidates;
    }
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateHanjaCandidates showing: %d", self.candidates != nil);
}

- (void)updateFromController:(CIMInputController *)controller {
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer updateFromController:");
    NSRange markedRange = [controller.client markedRange];
    NSRange selectedRange = [controller.client selectedRange];
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController: marked: %@ selected: %@", NSStringFromRange(markedRange), NSStringFromRange(selectedRange));
    if ((markedRange.length == 0 || markedRange.length == NSNotFound) && selectedRange.length > 0) {
        NSString *selectedString = [controller.client attributedSubstringFromRange:selectedRange].string;
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController: selected string: %@", selectedString);
        [controller.client setMarkedText:selectedString selectionRange:selectedRange replacementRange:selectedRange];
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController: try marking: %@ / selected: %@", NSStringFromRange([controller.client markedRange]), NSStringFromRange([controller.client selectedRange]));
        self->bufferedString.string = selectedString;
        dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController: so buffer is: %@", self->bufferedString);
        self.mode = NO;
    }
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController super");
    [self updateHanjaCandidates];
    dlog(DEBUG_HANJACOMPOSER, @"HanjaComposer -updateFromController done");
}

- (BOOL)hasCandidates {
    return self.candidates.count > 0;
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    NSString *value = [candidateString.string componentsSeparatedByString:@":"][0];
    self.composedString = @"";
    self.commitString = value;
    [self.hangulComposer cancelComposition];
    [self.hangulComposer dequeueCommitString];
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    // TODO: 설정 추가
//    if (candidateString.length == 0) {
//        self.composedString = self.originalString;
//    } else {
//        NSString *value = [[candidateString string] componentsSeparatedByString:@":"][0];
//        self.composedString = value;
//    }
}

- (HGHanjaTable *)characterTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"hanjac" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (HGHanjaTable *)wordTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"hanjaw" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (HGHanjaTable *)reversedTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"hanjar" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (HGHanjaTable *)MSSymbolTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"mssymbol" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (HGHanjaTable *)emoticonTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoticon" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (HGHanjaTable *)emoticonReversedTable {
    static HGHanjaTable *sharedHanjaTable = nil;
    if (sharedHanjaTable == nil) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoticonr" ofType:@"txt" inDirectory:@"hanja"];
        sharedHanjaTable = [[HGHanjaTable alloc] initWithContentOfFile:path];
    }
    return sharedHanjaTable;
}

- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller inputText:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender {
    CIMInputTextProcessResult result = [self.delegate inputController:controller inputText:string key:keyCode modifiers:flags client:sender];
    switch (keyCode) {
        // backspace
        case 51: if (result == CIMInputTextProcessResultNotProcessed) {
            if (self.originalString.length > 0) {
                // 조합 중인 글자가 없을 때 backspace가 들어오면 조합이 완료된 글자 중 마지막 글자를 지운다.
                [self->bufferedString deleteCharactersInRange:NSMakeRange(self->bufferedString.length - 1, 1)];
                self.composedString = self.originalString;
                result = CIMInputTextProcessResultProcessed;
            } else {
                // 글자를 모두 지우면 한자 모드에서 빠져 나간다.
                self.mode = NO;
            }
        }   break;
        // space
        case 49: {
            [self.hangulComposer cancelComposition]; // 강제로 조합중인 문자 추출
            [self->bufferedString appendString:self.hangulComposer.dequeueCommitString];
            // 단어 뜻 검색을 위해 공백 문자도 후보 검색에 포함한다.
            if (self->bufferedString.length > 0) {
                [self->bufferedString appendString:@" "];
                result = CIMInputTextProcessResultProcessed;
            } else {
                result = CIMInputTextProcessResultNotProcessedAndNeedsCommit;
            }
        }   break;
        // esc
        case 0x35: {
            self.mode = NO;
            // step 1: 조합중인 한글을 모두 가져옴
            [self.hangulComposer cancelComposition];
            [self->bufferedString appendString:self.hangulComposer.dequeueCommitString];
            // step 2: 한글을 그대로 커밋
            self.composedString = self.originalString;
            [self cancelComposition];
            // step 3: 한자 후보 취소
            self.candidates = nil; // 후보 취소
            return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
        }   break;
        default:
            break;
    }
    [self updateHanjaCandidates];
    if (result == CIMInputTextProcessResultNotProcessedAndNeedsCommit) {
        [self cancelComposition];
        return result;
    }
    if (self.commitString.length == 0) {
        return result == CIMInputTextProcessResultProcessed;
    } else {
        return CIMInputTextProcessResultNotProcessedAndNeedsCommit;
    }
}

@end
