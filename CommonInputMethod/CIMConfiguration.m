//
//  CIMConfiguration.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMConfiguration.h"

NSString * kCIMLastHangulInputMode = @"CIMLastHangulInputMode";

NSString * kCIMInputModeExchangeKeyModifier = @"CIMInputModeExchangeKeyModifier";
NSString * kCIMInputModeExchangeKeyCode = @"CIMInputModeExchangeKeyCode";
NSString * kCIMInputModeHanjaKeyModifier = @"CIMInputModeHanjaKeyModifier";
NSString * kCIMInputModeHanjaKeyCode = @"CIMInputModeHanjaKeyCode";
NSString * kCIMHangulCombinationModeComposing = @"CIMHangulCombinationModeComposing";
NSString * kCIMHangulCombinationModeCommiting = @"CIMHangulCombinationModeCommiting";

NSString * kCIMSharedInputManager = @"CIMSharedInputManager";
NSString * kCIMAutosaveDefaultInputMode = @"CIMAutosaveDefaultInputMode";

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
            [self->pFieldKeys setObject:item->name forKey:[NSNumber numberWithUnsignedLong:(unsigned long)item->pConfiguration]];
        }

        struct CIMConfigurationIntegerItem tempIntegerItems[CIMConfigurationIntegerItemCount] = {
            { kCIMInputModeExchangeKeyModifier, &self->inputModeExchangeKeyModifier, NSShiftKeyMask },
            { kCIMInputModeExchangeKeyCode, &self->inputModeExchangeKeyCode, 0x31 },
            { kCIMInputModeHanjaKeyModifier, &self->inputModeHanjaKeyModifier, NSAlternateKeyMask },
            { kCIMInputModeHanjaKeyCode, &self->inputModeHanjaKeyCode, 0x24 },
            { kCIMHangulCombinationModeComposing, &self->hangulCombinationModeComposing, 0 },
            { kCIMHangulCombinationModeCommiting, &self->hangulCombinationModeCommiting, 0 },
        };
        for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++ ) {
            self->integerItems[i] = tempIntegerItems[i];
        }
        struct CIMConfigurationBoolItem tempBoolItems[CIMConfigurationBoolItemCount] = {
            { kCIMSharedInputManager, &self->sharedInputManager, NO },
            { kCIMAutosaveDefaultInputMode, &self->autosaveDefaultInputMode, YES },
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
    for (NSInteger i = 0; i < CIMConfigurationStringItemCount; i++ ) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        ICLog(TRUE, @"** CIMConfiguration -loadAllConfigurations count: %d / object: %@", i, object);
        if (object == nil) { object = item.defaultValue; }
        [*item.pConfiguration autorelease];
        *item.pConfiguration = [object retain];
        if (object != nil) {
            [self->originConfigurations setObject:object forKey:item.name];
        } else {
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++ ) {
        struct CIMConfigurationIntegerItem item = self->integerItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object integerValue] : item.defaultValue;
        [self->originConfigurations setObject:[NSNumber numberWithInteger:*item.pConfiguration] forKey:item.name];
    }
    for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++ ) {
        struct CIMConfigurationBoolItem item = self->boolItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object boolValue] : item.defaultValue;
        [self->originConfigurations setObject:[NSNumber numberWithBool:*item.pConfiguration] forKey:item.name];
    }
}

- (void)saveAllConfigurations {
    if (self->userDefaults == nil) return;
    for (NSInteger i = 0; i < CIMConfigurationStringItemCount; i++ ) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        NSString *value = *item.pConfiguration;
        if (value != nil && ![value isEqual:[self->originConfigurations objectForKey:item.name]]) {
            [self->userDefaults setObject:value forKey:item.name];
            [self->originConfigurations setObject:value forKey:item.name];
        } else if (value == nil) {
            [self->userDefaults removeObjectForKey:item.name];
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    // TODO: save integer, bool config
    [self->userDefaults synchronize];
}

- (void)saveConfigurationForStringField:(NSString **)pField {
    NSString *configurationKey = [self->pFieldKeys objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)pField]];
    if (![*pField isEqualToString:[self->originConfigurations objectForKey:configurationKey]]) {
        [self->userDefaults setObject:*pField forKey:configurationKey];
        [self->originConfigurations setObject:*pField forKey:configurationKey];
    }
}

+ (CIMConfiguration *)userDefaultConfiguration {
    return CIMDefaultUserConfiguration;
}

@end
