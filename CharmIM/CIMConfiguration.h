//
//  CIMConfiguration.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CIMConfigurationStringItemCount 1
ICEXTERN NSString *kCIMLastHangulInputMode;

#define CIMConfigurationIntegerItemCount 2
ICEXTERN NSString *kCIMInputModeExchangeKeyModifier;
ICEXTERN NSString *kCIMInputModeExchangeKeyCode;

#define CIMConfigurationBoolItemCount 1
ICEXTERN NSString *kCIMSharedInputManager;


#define defCIMConfigurationItem(NAME, TYPE) struct NAME { NSString *name; TYPE *pConfiguration; TYPE defaultValue; }

defCIMConfigurationItem(CIMConfigurationStringItem, NSString *);
defCIMConfigurationItem(CIMConfigurationIntegerItem, NSInteger);
defCIMConfigurationItem(CIMConfigurationBoolItem, BOOL);

#undef defCIMConfigurationItem

#define CIMConfigurationSetObjectForField(CONF, OBJ, FIELD)   { [CONF->FIELD autorelease]; CONF->FIELD = [OBJ retain]; }

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
    BOOL sharedInputManager;
}
@property(nonatomic, retain) NSUserDefaults *userDefaults;

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)saveAllConfigurations;
- (void)loadAllConfigurations;
- (void)saveConfigurationForStringField:(NSString **)pField;

@end
