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
    
    이 클래스는 @link IMKServer @/link 에 의존하는 입력과 클라이언트에서의 결과 반영을 담당한다.
    IMKInputController가 내부 구현으로 의도하지 않은 동작을 하는 것을 방어하고 명시적으로 동작을 덮어쓰기 위해 IMKInputController를 직접 상속하고 모든 기능은 CIMInputReceiver로 위임한다.
 
    @coclass    CIMInputManager CIMInputReceiver
    @warning    이 클래스에는 IMKServer, 클라이언트와 독립적인 코드는 **절대로** 쓰지 않는다. IMKInputController의 내부 구현과 섞이면 디버그하기 어렵다.
*/

@import InputMethodKit;
@import IOKit.hid;

#import "CIMCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class CIMComposer;
@class CIMInputReceiver;
@class IOConnect;

typedef NS_ENUM(NSInteger, CIMInputControllerSpecialKeyCode) {
    CIMInputControllerSpecialKeyCodeCapsLockPressed = -1,
    CIMInputControllerSpecialKeyCodeCapsLockFlagsChanged = -2,
};

@interface CIMInputController : IMKInputController {
    CIMInputReceiver *_receiver;
    IOConnect *_ioConnect;
    IOHIDManagerRef _hidManager;
    BOOL _capsLockPressed;
}

@property(readonly) CIMInputReceiver *receiver; // temp bridge
@property(readonly) IOConnect *ioConnect; // temp bridge
@property(assign) BOOL capsLockPressed; // temp bridge

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
