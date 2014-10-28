//
//  TISInputSource.m
//  Gureum
//
//  Created by Jeong YunWon on 2014. 10. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#import "TISInputSource.h"

@interface TISInputSourceError : NSError

- (instancetype)initWithCode:(OSStatus)err;
+ (instancetype)errorWithCode:(OSStatus)err;

@end

@implementation TISInputSourceError

- (instancetype)initWithCode:(OSStatus)err {
    return [super initWithDomain:@"TISInputSource" code:err userInfo:@{}];
}

+ (instancetype)errorWithCode:(OSStatus)err {
    return [[[self alloc] initWithCode:err] autorelease];
}

@end


@interface TISInputSource ()

- (instancetype)initWithRef:(TISInputSourceRef)ref;

@end


@implementation TISInputSource

- (instancetype)init {
    [self release];
    return nil;
}

- (instancetype)initWithRef:(TISInputSourceRef)ref {
    self = [super init];
    if (self != nil) {
        self->_ref = ref;
    }
    return self;
}

- (void)dealloc {
    if (self->_ref) {
        CFRelease(self->_ref);
    }
    [super dealloc];
}

- (NSString *)description {
    return [@"<%@(%@)>" format:self.class.name, self.identifier];
}

- (id)propertyForKey:(NSString *)key {
    return (id)TISGetInputSourceProperty(self->_ref, (CFStringRef)key);
}

- (NSString *)category {
    return [self propertyForKey:TISPropertyInputSourceCategory];
}

- (NSString *)type {
    return [self propertyForKey:TISPropertyInputSourceType];
}

- (BOOL)ASCIICapable {
    return CFBooleanGetValue((CFBooleanRef)[self propertyForKey:TISPropertyInputSourceIsASCIICapable]);
}

- (BOOL)enableCapable {
    return CFBooleanGetValue((CFBooleanRef)[self propertyForKey:TISPropertyInputSourceIsEnableCapable]);
}

- (BOOL)selectCapable {
    return CFBooleanGetValue((CFBooleanRef)[self propertyForKey:TISPropertyInputSourceIsSelectCapable]);
}

- (BOOL)enabled {
    return CFBooleanGetValue((CFBooleanRef)[self propertyForKey:TISPropertyInputSourceIsEnabled]);
}

- (BOOL)selected {
    return CFBooleanGetValue((CFBooleanRef)[self propertyForKey:TISPropertyInputSourceIsSelected]);
}

- (NSString *)identifier {
    return [self propertyForKey:TISPropertyInputSourceID];
}

- (NSString *)bundleIdentifier {
    return [self propertyForKey:TISPropertyBundleID];
}

- (NSString *)inputModeIdentifier {
    return [self propertyForKey:TISPropertyInputModeID];
}

- (NSString *)localizedName {
    return [self propertyForKey:TISPropertyLocalizedName];
}

- (NSArray *)languages {
    return [self propertyForKey:TISPropertyInputSourceLanguages];
}

- (NSData *)layoutData {
    return [self propertyForKey:TISPropertyUnicodeKeyLayoutData];
}

- (NSURL *)iconImageURL {
    return [self propertyForKey:TISPropertyIconImageURL];
}

+ (CFTypeID)typeID {
    return TISInputSourceGetTypeID();
}

NSArray *_TISSourceInputRefToObject(NSArray *refs) {
    return [refs arrayByMappingOperator:^id(id obj) {
        TISInputSourceRef ref = (TISInputSourceRef)obj;
        CFRetain(ref);
        id source = [[[TISInputSource alloc] initWithRef:ref] autorelease];
        dassert(source);
        return source;
    }];
}

+ (NSArray *)sourcesWithProperties:(NSDictionary *)properties includeAllInstalled:(BOOL)includeAllInstalled {
    NSArray *refs = (NSArray *)TISCreateInputSourceList((CFDictionaryRef)properties, includeAllInstalled);
    NSArray *sources = _TISSourceInputRefToObject(refs);
    [refs release];
    return sources;
}

+ (instancetype)currentSource {
    TISInputSourceRef ref = TISCopyCurrentKeyboardInputSource();
    return [[self alloc] initWithRef:ref];
}

+ (instancetype)currentLayoutSource {
    TISInputSourceRef ref = TISCopyCurrentKeyboardLayoutInputSource();
    return [[self alloc] initWithRef:ref];
}

+ (instancetype)currentASCIICapableSource {
    TISInputSourceRef ref = TISCopyCurrentASCIICapableKeyboardInputSource();
    return [[self alloc] initWithRef:ref];
}

+ (instancetype)currentASCIICapableLayoutSource {
    TISInputSourceRef ref = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
    return [[self alloc] initWithRef:ref];
}

+ (NSArray *)sourcesForLanguage:(NSString *)language {
    NSArray *refs = (NSArray *)TISCopyInputSourceForLanguage((CFStringRef)language);
    NSArray *sources = _TISSourceInputRefToObject(refs);
    [refs release];
    return sources;
}

+ (NSArray *)ASCIICapableSources {
    NSArray *refs = (NSArray *)TISCreateASCIICapableInputSourceList();
    NSArray *sources = _TISSourceInputRefToObject(refs);
    [refs release];
    return sources;
}

- (void)select {
    OSStatus err = TISSelectInputSource(self->_ref);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

- (void)deselect {
    OSStatus err = TISDeselectInputSource(self->_ref);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

- (void)enable {
    OSStatus err = TISEnableInputSource(self->_ref);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

- (void)disable {
    OSStatus err = TISDisableInputSource(self->_ref);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

+ (void)setInputMethodKeyboardLayoutOverride:(TISInputSource *)source {
    OSStatus err = TISSetInputMethodKeyboardLayoutOverride(source->_ref);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

+ (TISInputSource *)inputMethodKeyboardLayoutOverride {
    TISInputSourceRef ref = TISCopyInputMethodKeyboardLayoutOverride();
    if (ref == nil) {
        return nil;
    }
    return [[self alloc] initWithRef:ref];
}

+ (void)register:(NSURL *)location {
    OSStatus err = TISRegisterInputSource((CFURLRef)location);
    if (err != 0) {
        @throw [TISInputSourceError errorWithCode:err];
    }
}

@end
