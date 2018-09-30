//
//  CIMInputController.h
//  CharmIM
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

/*!
    @header
    @brief   입출력 환경을 다룬다.
*/

/*!
    @brief  OS에서 입력을 받아 처리기로 전달하고 결과를 클라이언트에 반영한다.
    
    이 클래스는 @link IMKServer @/link 에 의존하는 입력과 클라이언트에서의 결과 반영을 담당한다. OS 독립적인 처리를 위해 모든 입력을 @link CharmInputManager @/link 로 전달한다. CharmInputManager가 값 처리 후 보관하고 있는 결과를 가져와 클라이언트에 반영하는 것도 이 클래스의 몫이다.
 
    @coclass    CharmInputManager
    @warning    이 클래스에는 IMKServer, 클라이언트와 독립적인 코드는 **절대로** 쓰지 않는다. 디버그하기 화난다.
*/

@import InputMethodKit;

#import "CIMCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class CIMComposer;

@interface CIMInputReceiver : NSObject<CIMInputTextDelegate> {
    id _inputClient;
    CIMComposer *_composer;
    CIMInputController *_controller;
}

@property(nonatomic, readonly) id inputClient;
@property(nonatomic, readonly) CIMComposer *composer;

- (instancetype)initWithServer:(nullable IMKServer *)server delegate:(nullable id)delegate client:(nullable id)inputClient;

@end


@interface CIMInputReceiver(IMKServerInput)

- (BOOL)commitCompositionEvent:(id)sender controller:(CIMInputController *)controller;

@end


@class IOConnect;

@interface CIMInputController : IMKInputController {
    CIMInputReceiver *_receiver;
    IOConnect *_ioConnect;
}

@property(readonly) CIMComposer *composer; // temp bridge

@end

@interface CIMInputController (CIMMenu)

- (IBAction)showStandardAboutPanel:(id)sender;

@end


#if DEBUG

// no impleentation for this class here
@interface CIMMockInputClient: NSObject<IMKTextInput, IMKUnicodeTextInput>

- (id)initWithRealClient:(id)client;
@property(readonly) id _realClient;
//_clientTryRespondsToSelector:
//clientException
//inserting
//markedCharacterCount
- (void)setKeyboardType:(id)type;
- (NSRect)firstRectForCharacterRange:(NSRange)range;
//resetState
- (void)commit;
//isDictationHiliteCapableInputContext
//isBottomLineInputContext
//hidePalettesAtInsertionPoint
//insertText:replacementRange:validFlags:
//attributesForCharacterIndex:
//currentInputSourceBundleID
//deadKeyState
//keyboardType
//terminatePalette:
//isPaletteTerminated:
//inputSessionDoneSleep
//commitPendingInlineSession
- (NSString *)markedRangeValue; // string representation of marked text
//isTextPlaceholderAwareInputContext

@end

#endif

NS_ASSUME_NONNULL_END
