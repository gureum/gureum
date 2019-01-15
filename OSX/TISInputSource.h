//
//  TISInputSource.h
//  Gureum
//
//  Created by Jeong YunWon on 2014. 10. 29..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

@import Carbon;

#define TISPropertyInputSourceCategory          (NSString *)kTISPropertyInputSourceCategory
#define TISPropertyInputSourceType              (NSString *)kTISPropertyInputSourceType
#define TISPropertyInputSourceIsASCIICapable    (NSString *)kTISPropertyInputSourceIsASCIICapable
#define TISPropertyInputSourceIsEnableCapable   (NSString *)kTISPropertyInputSourceIsEnableCapable
#define TISPropertyInputSourceIsSelectCapable   (NSString *)kTISPropertyInputSourceIsSelectCapable
#define TISPropertyInputSourceIsEnabled         (NSString *)kTISPropertyInputSourceIsEnabled
#define TISPropertyInputSourceIsSelected        (NSString *)kTISPropertyInputSourceIsSelected
#define TISPropertyInputSourceID                (NSString *)kTISPropertyInputSourceID
#define TISPropertyBundleID                     (NSString *)kTISPropertyBundleID
#define TISPropertyInputModeID                  (NSString *)kTISPropertyInputModeID
#define TISPropertyLocalizedName                (NSString *)kTISPropertyLocalizedName

#define TISPropertyInputSourceLanguages         (NSString *)kTISPropertyInputSourceLanguages
#define TISPropertyUnicodeKeyLayoutData         (NSString *)kTISPropertyUnicodeKeyLayoutData
#define TISPropertyIconRef                      (NSString *)kTISPropertyIconRef
#define TISPropertyIconImageURL                 (NSString *)kTISPropertyIconImageURL

#define TISCategoryKeyboardInputSource          (NSString *)kTISCategoryKeyboardInputSource
#define TISCategoryPaletteInputSource           (NSString *)kTISCategoryPaletteInputSource
#define TISCategoryInkInputSource               (NSString *)kTISCategoryInkInputSource

#define TISTypeKeyboardLayout                   (NSString *)kTISTypeKeyboardLayout
#define TISTypeKeyboardInputMethodWithoutModes  (NSString *)kTISTypeKeyboardInputMethodWithoutModes
#define TISTypeKeyboardInputMethodModeEnabled   (NSString *)kTISTypeKeyboardInputMethodModeEnabled
#define TISTypeKeyboardInputMode                (NSString *)kTISTypeKeyboardInputMode
#define TISTypeCharacterPalette                 (NSString *)kTISTypeCharacterPalette
#define TISTypeKeyboardViewer                   (NSString *)kTISTypeKeyboardViewer
#define TISTypeInk                              (NSString *)kTISTypeInk

#define TISNotifySelectedKeyboardInputSourceChanged (NSString *)kTISNotifySelectedKeyboardInputSourceChanged
#define TISNotifyEnabledKeyboardInputSourcesChanged (NSString *)kTISNotifyEnabledKeyboardInputSourcesChanged

NS_ASSUME_NONNULL_BEGIN

@interface TISInputSource : NSObject {
    TISInputSourceRef _ref;
}

- (id)propertyForKey:(NSString *)key;

@property(nonatomic,readonly) TISInputSourceRef ref;
@property(nonatomic,readonly) NSString *category, *type;
@property(nonatomic,readonly) BOOL ASCIICapable, enableCapable, selectCapable;
@property(nonatomic,readonly) BOOL enabled, selected;
@property(nonatomic,readonly) NSString *identifier, *bundleIdentifier, *inputModeIdentifier;
@property(nonatomic,readonly) NSString *localizedName;
@property(nonatomic,readonly) NSArray *languages;
@property(nonatomic,readonly) NSData *layoutData;
@property(nonatomic,readonly) NSURL *iconImageURL;

- (void)select;
- (void)deselect;
- (void)enable;
- (void)disable;

+ (NSArray *)sourcesWithProperties:(NSDictionary *)properties includeAllInstalled:(BOOL)includeAllInstalled;
+ (instancetype)currentSource;
+ (instancetype)currentLayoutSource;
+ (instancetype)currentASCIICapableSource;
+ (instancetype)currentASCIICapableLayoutSource;
+ (instancetype)sourceForLanguage:(NSString *)language;
+ (NSArray *)ASCIICapableSources;
+ (void)setInputMethodKeyboardLayoutOverride:(TISInputSource *)source;
+ (TISInputSource *)inputMethodKeyboardLayoutOverride;
+ (void)register:(NSURL *)location;

@end

NS_ASSUME_NONNULL_END
