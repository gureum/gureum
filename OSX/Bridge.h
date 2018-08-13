//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <Foundation/Foundation.h>
#import <InputMethodKit/InputMethodKit.h>

#import <Hangul/HGInputContext.h>

#import "CIMCommon.h"
#import "CIMInputController.h"
//#import "CIMConfiguration.h"
#import "GureumComposer.h"

#import "HangulComposer.h"

@interface HangulComposer (HangulCharacterCombinationMode)

+ (NSString * _Nonnull)commitStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;
+ (NSString * _Nonnull)composedStringByCombinationModeWithUCSString:(const HGUCSChar *)UCSString;

@end

