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
ICEXTERN NSString *kCIMLastHangulInputMode;

#define CIMConfigurationIntegerItemCount 6
/* Gureum */
ICEXTERN NSString *kCIMInputModeExchangeKeyModifier;
ICEXTERN NSString *kCIMInputModeExchangeKeyCode;
ICEXTERN NSString *kCIMInputModeHanjaKeyModifier;
ICEXTERN NSString *kCIMInputModeHanjaKeyCode;
/* Hangul */
ICEXTERN NSString *kCIMHangulCombinationModeComposing;
ICEXTERN NSString *kCIMHangulCombinationModeCommiting;

#define CIMConfigurationBoolItemCount 2
/* Common */
ICEXTERN NSString *kCIMSharedInputManager;
/* Gureum */
ICEXTERN NSString *kCIMAutosaveDefaultInputMode;


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
}
@property(nonatomic, retain) NSUserDefaults *userDefaults;

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)saveAllConfigurations;
- (void)loadAllConfigurations;
- (void)saveConfigurationForStringField:(NSString **)pField;

+ (CIMConfiguration *)userDefaultConfiguration;

@end
