//
//  CIMComposer.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 2..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMInputManager.h"
/*!
    @brief 실제로 문자를 합성하는 합성기의 프로토콜
    @discussion 입력기 전체의 상태에 영향을 끼치는 처리를 마친 후 출력할 글자를 조합하기 위해 CIMComposer로 입력을 전달한다. 기본적으로 자판마다 하나씩 구현하게 된다.
*/


@protocol CIMComposerDelegate<CIMInputTextDelegate>

@optional
//! @brief  입력기가 선택 됨
- (void)composerSelected:(id)sender;

@required
//! @brief  합성 중인 문자로 보여줄 문자열
@property(nonatomic, readonly) NSString *composedString;
//! @brief  합성을 취소하면 사용할 문자열
@property(nonatomic, readonly) NSString *originalString;
//! @brief  합성이 완료된 문자열
@property(nonatomic, readonly) NSString *commitString;
//! @brief  -commitString 을 반환하며 비움
- (NSString *)dequeueCommitString;
//! @brief  조합을 중지
- (void)cancelComposition;
//! @brief  조합 문맥 초기화
- (void)clearContext;

//! @brief  변환 후보 문자열 존재 여부
@property(nonatomic, readonly) BOOL hasCandidates;

@optional
//! @brief  변환 후보 문자열 리스트
@property(nonatomic, readonly) NSArray<NSString *> *candidates;
//! @brief  변환 후보 문자열 선택
- (void)candidateSelected:(NSAttributedString *)candidateString;
//! @brief  변환 후보 문자열 변경
- (void)candidateSelectionChanged:(NSAttributedString *)candidateString;

@required
- (CIMInputTextProcessResult)inputController:(CIMInputController *)controller commandString:(NSString *)string key:(NSInteger)keyCode modifiers:(NSEventModifierFlags)flags client:(id)sender;

@end

/*!
    @brief  일반적인 합성기 구조
 
    @warning    이 자체로는 동작하지 않는다. 상속하여 동작을 구현하거나 @ref CIMBaseComposer 를 사용한다.
*/
@interface CIMComposer : NSObject<CIMComposerDelegate> {
    id<CIMComposerDelegate> _delegate;
    NSString *_inputMode;
@public
    CIMInputManager *manager;
}
@property(nonatomic, retain) CIMInputManager *manager;
@property(nonatomic, retain) id<CIMComposerDelegate> delegate;
@property(nonatomic, retain, nonnull) NSString *inputMode;

@end
