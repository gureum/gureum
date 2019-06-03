//
//  TISInputSource.m
//  Gureum
//
//  Created by Jeong YunWon on 2014. 10. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import FoundationExtension;

#import "TISInputSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface TISInputSourceError : NSError

- (instancetype)initWithCode:(OSStatus)err NS_DESIGNATED_INITIALIZER;
+ (instancetype)errorWithCode:(OSStatus)err;

@end

@implementation TISInputSourceError

- (instancetype)initWithCode:(OSStatus)err {
    return [super initWithDomain:@"TISInputSource" code:err userInfo:@{}];
}

+ (instancetype)errorWithCode:(OSStatus)err {
    return [[self alloc] initWithCode:err];
}

@end


@interface TISInputSource ()

- (instancetype)initWithRef:(TISInputSourceRef)ref;

@end


@implementation TISInputSource

@synthesize ref=_ref;

- (instancetype)init {
    return nil;
}

- (instancetype)initWithRef:(TISInputSourceRef)ref {
    self = [super init];
    if (self != nil) {
        CFRetain(ref);
        self->_ref = ref;
    }
    return self;
}

- (void)dealloc {
    if (self->_ref) {
        CFRelease(self->_ref);
    }
}

- (NSString *)description {
    return [@"<%@(%@)>" format:self.class.name, self.identifier];
}

- (id)propertyForKey:(NSString *)key {
    return (__bridge id)TISGetInputSourceProperty(self->_ref, (__bridge CFStringRef)key);
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

NSArray *_TISSourceInputRefToObject(NSArray *refs) {
    return [refs arrayByMappingOperator:^id(id obj) {
        TISInputSourceRef ref = (__bridge TISInputSourceRef)obj;
        CFRetain(ref);
        id source = [[TISInputSource alloc] initWithRef:ref];
        assert(source);
        return source;
    }];
}

+ (instancetype)sourceForLanguage:(NSString *)language {
    TISInputSourceRef ref = TISCopyInputSourceForLanguage((__bridge CFStringRef)language);
    return [[self alloc] initWithRef:ref];
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

@end

NS_ASSUME_NONNULL_END
