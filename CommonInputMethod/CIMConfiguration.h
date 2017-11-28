//
//  CIMConfiguration.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CIMConfigurationStringItemCount 1
/* Gureum */
FOUNDATION_EXTERN NSString *CIMLastHangulInputMode;

#define CIMConfigurationIntegerItemCount 17
/* Shortcut */
FOUNDATION_EXTERN NSString *CIMLeftCommandKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMLeftOptionKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMLeftControlKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMRightCommandKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMRightOptionKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMRightControlKeyShortcutBehavior;
FOUNDATION_EXTERN NSString *CIMInputModeExchangeKeyModifier;
FOUNDATION_EXTERN NSString *CIMInputModeExchangeKeyCode;
FOUNDATION_EXTERN NSString *CIMInputModeHanjaKeyModifier;
FOUNDATION_EXTERN NSString *CIMInputModeHanjaKeyCode;
FOUNDATION_EXTERN NSString *CIMInputModeEnglishKeyModifier;
FOUNDATION_EXTERN NSString *CIMInputModeEnglishKeyCode;
FOUNDATION_EXTERN NSString *CIMInputModeKoreanKeyModifier;
FOUNDATION_EXTERN NSString *CIMInputModeKoreanKeyCode;
/* Gureum */
FOUNDATION_EXTERN NSString *CIMOptionKeyBehavior;
/* Hangul */
FOUNDATION_EXTERN NSString *CIMHangulCombinationModeComposing;
FOUNDATION_EXTERN NSString *CIMHangulCombinationModeCommiting;

#define CIMConfigurationBoolItemCount 5
/* Common */
FOUNDATION_EXTERN NSString *CIMSharedInputManager;
/* Gureum */
FOUNDATION_EXTERN NSString *CIMAutosaveDefaultInputMode;
FOUNDATION_EXTERN NSString *CIMRomanModeByEscapeKey;
FOUNDATION_EXTERN NSString *CIMShowsInputForHanjaCandidates;

#define defCIMConfigurationItem(NAME, TYPE) \
    struct NAME {                           \
        NSString *name;            \
        TYPE *pConfiguration;               \
        TYPE defaultValue;                  \
    }

defCIMConfigurationItem(CIMConfigurationStringItem, NSString *);
defCIMConfigurationItem(CIMConfigurationIntegerItem, NSInteger);
defCIMConfigurationItem(CIMConfigurationBoolItem, BOOL);

#undef defCIMConfigurationItem

#define CIMConfigurationSetObjectForField(CONF, OBJ, FIELD)                                                            \
    {                                                                                                                  \
        [CONF->FIELD autorelease];                                                                                     \
        CONF->FIELD = [OBJ retain];                                                                                    \
    }

@class CIMConfiguration;

extern CIMConfiguration *CIMDefaultUserConfiguration;

/*!
    @brief  NSUserDefaults 에 설정을 저장하고 가져온다.
*/
@interface CIMConfiguration : NSObject {
  @private
    NSMutableDictionary *pFieldKeys;
    struct CIMConfigurationStringItem stringItems[CIMConfigurationStringItemCount];
    struct CIMConfigurationIntegerItem integerItems[CIMConfigurationIntegerItemCount];
    struct CIMConfigurationBoolItem boolItems[CIMConfigurationBoolItemCount];
    NSMutableDictionary *originConfigurations;
    NSUserDefaults *userDefaults;
  @public
    NSString *lastHangulInputMode;
    NSInteger leftCommandKeyShortcutBehavior;
    NSInteger leftOptionKeyShortcutBehavior;
    NSInteger leftControlKeyShortcutBehavior;
    NSInteger rightCommandKeyShortcutBehavior;
    NSInteger rightOptionKeyShortcutBehavior;
    NSInteger rightControlKeyShortcutBehavior;
    NSInteger inputModeExchangeKeyModifier, inputModeExchangeKeyCode;
    NSInteger inputModeHanjaKeyModifier, inputModeHanjaKeyCode;
    NSInteger inputModeEnglishKeyModifier, inputModeEnglishKeyCode;
    NSInteger inputModeKoreanKeyModifier, inputModeKoreanKeyCode;
    NSInteger optionKeyBehavior;
    NSInteger hangulCombinationModeComposing, hangulCombinationModeCommiting;
    BOOL sharedInputManager;
    BOOL autosaveDefaultInputMode;
    BOOL romanModeByEscapeKey;
    BOOL showsInputForHanjaCandidates;
}
@property(nonatomic, retain) NSUserDefaults *userDefaults;

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)saveAllConfigurations;
- (void)loadAllConfigurations;
- (void)saveConfigurationForStringField:(NSString **)pField;

+ (CIMConfiguration *)userDefaultConfiguration;

@end
