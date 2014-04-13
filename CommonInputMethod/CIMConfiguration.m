//
//  CIMConfiguration.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMConfiguration.h"
#import "HangulComposer.h"

NSString * kCIMLastHangulInputMode = @"CIMLastHangulInputMode";

NSString * kCIMInputModeExchangeKeyModifier = @"CIMInputModeExchangeKeyModifier";
NSString * kCIMInputModeExchangeKeyCode = @"CIMInputModeExchangeKeyCode";
NSString * kCIMInputModeHanjaKeyModifier = @"CIMInputModeHanjaKeyModifier";
NSString * kCIMInputModeHanjaKeyCode = @"CIMInputModeHanjaKeyCode";
NSString * kCIMOptionKeyBehavior = @"CIMHangulOptionKeyBehavior";
NSString * kCIMHangulCombinationModeComposing = @"CIMHangulCombinationModeComposing";
NSString * kCIMHangulCombinationModeCommiting = @"CIMHangulCombinationModeCommiting";

NSString * kCIMSharedInputManager = @"CIMSharedInputManager";
NSString * kCIMAutosaveDefaultInputMode = @"CIMAutosaveDefaultInputMode";
NSString * kCIMRomanModeByEscapeKey = @"CIMRomanModeByEscapeKey";
NSString * kCIMZeroWidthSpaceForLayoutExchange = @"CIMZeroWidthSpaceForLayoutExchange";
NSString * kCIMZeroWidthSpaceForBlankComposedString = @"CIMZeroWidthSpaceForBlankComposedString";


CIMConfiguration *CIMDefaultUserConfiguration;

@implementation CIMConfiguration
@synthesize  userDefaults;

+ (void)initialize {
    [super initialize];
    CIMDefaultUserConfiguration = [[self alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (id)init {
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (id)initWithUserDefaults:(NSUserDefaults *)aUserDefaults {
    self = [super init];
    if (self != nil) {
        self->pFieldKeys = [[NSMutableDictionary alloc] init];
        
        struct CIMConfigurationStringItem tempStringItems[CIMConfigurationStringItemCount] = {
            { kCIMLastHangulInputMode, &self->lastHangulInputMode, nil },
        };
        for (NSInteger i = 0; i < CIMConfigurationStringItemCount; i++ ) {
            struct CIMConfigurationStringItem *item = &tempStringItems[i];
            self->stringItems[i] = tempStringItems[i];
            self->pFieldKeys[@((unsigned long)item->pConfiguration)] = item->name;
        }

        struct CIMConfigurationIntegerItem tempIntegerItems[CIMConfigurationIntegerItemCount] = {
            { kCIMInputModeExchangeKeyModifier, &self->inputModeExchangeKeyModifier, NSShiftKeyMask },
            { kCIMInputModeExchangeKeyCode, &self->inputModeExchangeKeyCode, 0x31 },
            { kCIMInputModeHanjaKeyModifier, &self->inputModeHanjaKeyModifier, NSAlternateKeyMask },
            { kCIMInputModeHanjaKeyCode, &self->inputModeHanjaKeyCode, 0x24 },
            { kCIMOptionKeyBehavior, &self->optionKeyBehavior, 0 },
            { kCIMHangulCombinationModeComposing, &self->hangulCombinationModeComposing, (NSInteger)HangulCharacterCombinationWithoutFiller },
            { kCIMHangulCombinationModeCommiting, &self->hangulCombinationModeCommiting, (NSInteger)HangulCharacterCombinationWithoutFiller },
        };
        for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++ ) {
            self->integerItems[i] = tempIntegerItems[i];
        }
        struct CIMConfigurationBoolItem tempBoolItems[CIMConfigurationBoolItemCount] = {
            { kCIMSharedInputManager, &self->sharedInputManager, NO },
            { kCIMAutosaveDefaultInputMode, &self->autosaveDefaultInputMode, YES },
            { kCIMRomanModeByEscapeKey, &self->romanModeByEscapeKey, NO },
            { kCIMZeroWidthSpaceForBlankComposedString, &self->zeroWidthSpaceForBlankComposedString, NO },
            { kCIMZeroWidthSpaceForLayoutExchange, &self->zeroWidthSpaceForLayoutExchange, NO },
        };
        for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++ ) {
            self->boolItems[i] = tempBoolItems[i];
        }
        self->originConfigurations = [[NSMutableDictionary alloc] init];
        self.userDefaults = aUserDefaults;
    }
    return self;
}

- (void)dealloc {
    self.userDefaults = nil;
    [self->originConfigurations release];
    [self->pFieldKeys release];
    [super dealloc];
}

- (void)setUserDefaults:(NSUserDefaults *)aUserDefaults {
    [self saveAllConfigurations];
    [self->userDefaults autorelease];
    self->userDefaults = [aUserDefaults retain];
    [self loadAllConfigurations];
}

- (void)loadAllConfigurations {
    if (self->userDefaults == nil) return;
    [self->userDefaults synchronize];
    for (int i = 0; i < CIMConfigurationStringItemCount; i++ ) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        dlog(TRUE, @"** CIMConfiguration -loadAllConfigurations count: %d / object: %@", i, object);
        if (object == nil) { object = item.defaultValue; }
        [*item.pConfiguration autorelease];
        *item.pConfiguration = [object retain];
        if (object != nil) {
            self->originConfigurations[item.name] = object;
        } else {
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++ ) {
        struct CIMConfigurationIntegerItem item = self->integerItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object integerValue] : item.defaultValue;
        self->originConfigurations[item.name] = @(*item.pConfiguration);
    }
    for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++ ) {
        struct CIMConfigurationBoolItem item = self->boolItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object boolValue] : item.defaultValue;
        self->originConfigurations[item.name] = @(*item.pConfiguration);
    }
}

- (void)saveAllConfigurations {
    if (self->userDefaults == nil) return;
    for (int i = 0; i < CIMConfigurationStringItemCount; i++) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        NSString *value = *item.pConfiguration;
        if (value != nil && ![value isEqual:self->originConfigurations[item.name]]) {
            [self->userDefaults setObject:value forKey:item.name];
            self->originConfigurations[item.name] = value;
        } else if (value == nil) {
            [self->userDefaults removeObjectForKey:item.name];
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    for (int i = 0; i < CIMConfigurationIntegerItemCount; i++) {
        struct CIMConfigurationIntegerItem item = self->integerItems[i];
        NSInteger rawValue = *item.pConfiguration;
        NSNumber *value = @(rawValue);
        if (![value isEqual:self->originConfigurations[item.name]]) {
            [self->userDefaults setObject:value forKey:item.name];
            self->originConfigurations[item.name] = value;
        }
    }
    for (int i = 0; i < CIMConfigurationBoolItemCount; i++) {
        struct CIMConfigurationBoolItem item = self->boolItems[i];
        BOOL rawValue = *item.pConfiguration;
        NSNumber *value = @(rawValue);
        if (![value isEqual:self->originConfigurations[item.name]]) {
            [self->userDefaults setObject:value forKey:item.name];
            self->originConfigurations[item.name] = value;
        }
    }
    [self->userDefaults synchronize];
}

- (void)saveConfigurationForStringField:(NSString **)pField {
    NSString *configurationKey = self->pFieldKeys[@((unsigned long)pField)];
    if (![*pField isEqualToString:self->originConfigurations[configurationKey]]) {
        [self->userDefaults setObject:*pField forKey:configurationKey];
        self->originConfigurations[configurationKey] = *pField;
    }
}

+ (CIMConfiguration *)userDefaultConfiguration {
    return CIMDefaultUserConfiguration;
}

@end
