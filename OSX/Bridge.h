//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <Foundation/Foundation.h>
#import <FoundationExtension/FoundationExtension.h>
#import <InputMethodKit/InputMethodKit.h>

#import <Hangul/HGInputContext.h>
#import "NSAlert+Workaround.h"

#import "CIMCommon.h"
#import "CIMInputController.h"
#import "CIMInputHandler.h"
#import "GureumComposer.h"
#import "HangulComposer.h"
#import "GureumAppDelegate.h"

@interface HangulComposer (HangulCharacterCombinationMode)

+ (NSString * _Nonnull)commitStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString * _Nonnull)composedStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;

@end

