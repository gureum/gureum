//
//  CIMConfiguration.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMConfiguration.h"
#import "HangulComposer.h"

#define define_preference_key(NAME) NSString *NAME = @ #NAME

define_preference_key(CIMLastHangulInputMode);

define_preference_key(CIMLeftCommandKeyShortcutBehavior);
define_preference_key(CIMLeftOptionKeyShortcutBehavior);
define_preference_key(CIMLeftControlKeyShortcutBehavior);
define_preference_key(CIMRightCommandKeyShortcutBehavior);
define_preference_key(CIMRightOptionKeyShortcutBehavior);
define_preference_key(CIMRightControlKeyShortcutBehavior);
define_preference_key(CIMInputModeExchangeKeyModifier);
define_preference_key(CIMInputModeExchangeKeyCode);
define_preference_key(CIMInputModeHanjaKeyModifier);
define_preference_key(CIMInputModeHanjaKeyCode);
define_preference_key(CIMInputModeEnglishKeyModifier);
define_preference_key(CIMInputModeEnglishKeyCode);
define_preference_key(CIMInputModeKoreanKeyModifier);
define_preference_key(CIMInputModeKoreanKeyCode);
define_preference_key(CIMOptionKeyBehavior);
define_preference_key(CIMHangulCombinationModeComposing);
define_preference_key(CIMHangulCombinationModeCommiting);

define_preference_key(CIMSharedInputManager);
define_preference_key(CIMAutosaveDefaultInputMode);
define_preference_key(CIMRomanModeByEscapeKey);
define_preference_key(CIMShowsInputForHanjaCandidates);

CIMConfiguration *CIMDefaultUserConfiguration;

@implementation CIMConfiguration
@synthesize userDefaults;

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
            { CIMLastHangulInputMode, &self->lastHangulInputMode, nil },
        };
        for (NSInteger i = 0; i < CIMConfigurationStringItemCount; i++) {
            struct CIMConfigurationStringItem *item = &tempStringItems[i];
            self->stringItems[i] = tempStringItems[i];
            self->pFieldKeys[@((unsigned long)item->pConfiguration)] = item->name;
        }

        struct CIMConfigurationIntegerItem tempIntegerItems[CIMConfigurationIntegerItemCount] = {
            { CIMLeftCommandKeyShortcutBehavior, &self->leftCommandKeyShortcutBehavior, 0 },
            { CIMLeftOptionKeyShortcutBehavior, &self->leftOptionKeyShortcutBehavior, 0 },
            { CIMLeftControlKeyShortcutBehavior, &self->leftControlKeyShortcutBehavior, 0 },
            { CIMRightCommandKeyShortcutBehavior, &self->rightCommandKeyShortcutBehavior, 1 },
            { CIMRightOptionKeyShortcutBehavior, &self->rightOptionKeyShortcutBehavior, 2 },
            { CIMRightControlKeyShortcutBehavior, &self->rightControlKeyShortcutBehavior, 0 },
            { CIMInputModeExchangeKeyModifier, &self->inputModeExchangeKeyModifier, NSShiftKeyMask },
            { CIMInputModeExchangeKeyCode, &self->inputModeExchangeKeyCode, 0x31 },
            { CIMInputModeHanjaKeyModifier, &self->inputModeHanjaKeyModifier, NSAlternateKeyMask },
            { CIMInputModeHanjaKeyCode, &self->inputModeHanjaKeyCode, 0x24 },
            { CIMInputModeEnglishKeyModifier, &self->inputModeEnglishKeyModifier, 0 },
            { CIMInputModeEnglishKeyCode, &self->inputModeEnglishKeyCode, -1 },
            { CIMInputModeKoreanKeyModifier, &self->inputModeKoreanKeyModifier, 0 },
            { CIMInputModeKoreanKeyCode, &self->inputModeKoreanKeyCode, -1 },
            { CIMOptionKeyBehavior, &self->optionKeyBehavior, 0 },
            { CIMHangulCombinationModeComposing, &self->hangulCombinationModeComposing,
              (NSInteger)HangulCharacterCombinationWithoutFiller },
            { CIMHangulCombinationModeCommiting, &self->hangulCombinationModeCommiting,
              (NSInteger)HangulCharacterCombinationWithoutFiller },
        };
        for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++) {
            self->integerItems[i] = tempIntegerItems[i];
        }
        struct CIMConfigurationBoolItem tempBoolItems[CIMConfigurationBoolItemCount] = {
            { CIMSharedInputManager, &self->sharedInputManager, NO },
            { CIMAutosaveDefaultInputMode, &self->autosaveDefaultInputMode, YES },
            { CIMRomanModeByEscapeKey, &self->romanModeByEscapeKey, NO },
            { CIMShowsInputForHanjaCandidates, &self->showsInputForHanjaCandidates, NO },
        };
        for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++) {
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
    if (self->userDefaults == nil)
        return;
    [self->userDefaults synchronize];
    for (int i = 0; i < CIMConfigurationStringItemCount; i++) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        dlog(TRUE, @"** CIMConfiguration -loadAllConfigurations count: %d / object: %@", i, object);
        if (object == nil) {
            object = item.defaultValue;
        }
        [*item.pConfiguration autorelease];
        *item.pConfiguration = [object retain];
        if (object != nil) {
            self->originConfigurations[item.name] = object;
        } else {
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++) {
        struct CIMConfigurationIntegerItem item = self->integerItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object integerValue] : item.defaultValue;
        self->originConfigurations[item.name] = @(*item.pConfiguration);
    }
    for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++) {
        struct CIMConfigurationBoolItem item = self->boolItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        *item.pConfiguration = object != nil ? [object boolValue] : item.defaultValue;
        self->originConfigurations[item.name] = @(*item.pConfiguration);
    }

    if (!(0 <= self->hangulCombinationModeComposing && self->hangulCombinationModeComposing < HangulCharacterCombinationModeCount)) {
        self->hangulCombinationModeComposing = 0;
    }
    if (!(0 <= self->hangulCombinationModeCommiting && self->hangulCombinationModeCommiting < HangulCharacterCombinationModeCount)) {
        self->hangulCombinationModeCommiting = 0;
    }
}

- (void)saveAllConfigurations {
    if (self->userDefaults == nil)
        return;
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
