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
FOUNDATION_EXTERN NSString *kCIMLastHangulInputMode;

#define CIMConfigurationIntegerItemCount 6
/* Gureum */
FOUNDATION_EXTERN NSString *kCIMInputModeExchangeKeyModifier;
FOUNDATION_EXTERN NSString *kCIMInputModeExchangeKeyCode;
FOUNDATION_EXTERN NSString *kCIMInputModeHanjaKeyModifier;
FOUNDATION_EXTERN NSString *kCIMInputModeHanjaKeyCode;
/* Hangul */
FOUNDATION_EXTERN NSString *kCIMHangulCombinationModeComposing;
FOUNDATION_EXTERN NSString *kCIMHangulCombinationModeCommiting;

#define CIMConfigurationBoolItemCount 3
/* Common */
FOUNDATION_EXTERN NSString *kCIMSharedInputManager;
/* Gureum */
FOUNDATION_EXTERN NSString *kCIMAutosaveDefaultInputMode;
FOUNDATION_EXTERN NSString *kCIMRomanModeByEscapeKey;


#define defCIMConfigurationItem(NAME, TYPE) struct NAME { NSString *name; TYPE *pConfiguration; TYPE defaultValue; }

defCIMConfigurationItem(CIMConfigurationStringItem, NSString *);
defCIMConfigurationItem(CIMConfigurationIntegerItem, NSInteger);
defCIMConfigurationItem(CIMConfigurationBoolItem, BOOL);

#undef defCIMConfigurationItem

#define CIMConfigurationSetObjectForField(CONF, OBJ, FIELD)   { [CONF->FIELD autorelease]; CONF->FIELD = [OBJ retain]; }

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
    NSInteger inputModeExchangeKeyModifier, inputModeExchangeKeyCode;
    NSInteger inputModeHanjaKeyModifier, inputModeHanjaKeyCode;
    NSInteger hangulCombinationModeComposing, hangulCombinationModeCommiting;
    BOOL sharedInputManager;
    BOOL autosaveDefaultInputMode;
    BOOL romanModeByEscapeKey;
}
@property(nonatomic, retain) NSUserDefaults *userDefaults;

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)saveAllConfigurations;
- (void)loadAllConfigurations;
- (void)saveConfigurationForStringField:(NSString **)pField;

+ (CIMConfiguration *)userDefaultConfiguration;

@end
