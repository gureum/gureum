//
//  CIMConfiguration.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 4..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "CIMConfiguration.h"

NSString * kCIMLastHangulInputMode = @"CIMLastHangulInputMode";


@implementation CIMConfiguration
@synthesize  userDefaults;

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
        /*
        struct CIMConfigurationIntegerItem tempIntegerItems[CIMConfigurationIntegerItemCount] = {
            
        };
        for (NSInteger i = 0; i < CIMConfigurationIntegerItemCount; i++ ) {
            self->integerItems[i] = tempIntegerItems[i];
        }
        struct CIMConfigurationBoolItem tempBoolItems[CIMConfigurationBoolItemCount] = {

        };
        for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++ ) {
            self->boolItems[i] = tempBoolItems[i];
        }
        */
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
        [self->originConfigurations setObject:object forKey:item.name];
        *item.pConfiguration = object != nil ? [object integerValue] : item.defaultValue;
        [self->originConfigurations setObject:[NSNumber numberWithInteger:*item.pConfiguration] forKey:item.name];
    }
    for (NSInteger i = 0; i < CIMConfigurationBoolItemCount; i++ ) {
        struct CIMConfigurationBoolItem item = self->boolItems[i];
        id object = [self->userDefaults objectForKey:item.name];
        [self->originConfigurations setObject:object forKey:item.name];
        *item.pConfiguration = object != nil ? [object boolValue] : item.defaultValue;
        [self->originConfigurations setObject:[NSNumber numberWithBool:*item.pConfiguration] forKey:item.name];
    }
}

- (void)saveAllConfigurations {
    if (self->userDefaults == nil) return;
    for (NSInteger i = 0; i < CIMConfigurationStringItemCount; i++ ) {
        struct CIMConfigurationStringItem item = self->stringItems[i];
        NSString *value = *item.pConfiguration;
        if (value != nil && ![value isEqualToString:[self->originConfigurations objectForKey:item.name]]) {
            [self->userDefaults setObject:value forKey:item.name];
            [self->originConfigurations setObject:value forKey:item.name];
        } else if (value == nil) {
            [self->userDefaults removeObjectForKey:item.name];
            [self->originConfigurations removeObjectForKey:item.name];
        }
    }
    [self->userDefaults synchronize];
}

- (void)saveConfigurationForStringField:(NSString **)pField {
    NSString *configurationKey = [self->pFieldKeys objectForKey:[NSNumber numberWithUnsignedLong:(unsigned long)pField]];
    if (![*pField isEqualToString:[self->originConfigurations objectForKey:configurationKey]]) {
        [self->userDefaults setObject:*pField forKey:configurationKey];
        [self->originConfigurations setObject:*pField forKey:configurationKey];
    }
}

@end
