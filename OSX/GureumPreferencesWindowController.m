//
//  GureumPreferences.m
//  CharmIM
//
//  Created by youknowone on 11. 9. 22..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumPreferencesWindowController.h"

#import "HangulComposer.h"
#import "Gureum-Swift.h"

#define DEBUG_PREFERENCE FALSE

@interface GureumPreferencesWindowController ()

- (void)loadFromConfiguration;
- (void)showPreferenceViewWithIdentifier:(id)identifier animate:(BOOL)animate;

@end

static NSArray *GureumPreferencesShortcutBehaviors = nil;
static NSArray *GureumPreferencesHangulLayouts = nil;
static NSArray *GureumPreferencesHangulLayoutLocalizedNames = nil;
static NSArray *GureumPreferencesHangulSyllablePresentations = nil;

@implementation GureumPreferencesWindowController

+ (void)initialize {
    [super initialize];
    GureumPreferencesShortcutBehaviors = [[NSArray alloc] initWithObjects:
                                          NSLocalizedStringFromTable(@"ShortcutBehaviorNone", @"Hangul", @""),
                                          NSLocalizedStringFromTable(@"ShortcutBehaviorExchangeLanguage", @"Hangul", @""),
                                          NSLocalizedStringFromTable(@"ShortcutBehaviorHanjaMode", @"Hangul", @""),
                                          NSLocalizedStringFromTable(@"ShortcutBehaviorChangeToEnglish", @"Hangul", @""),
                                          NSLocalizedStringFromTable(@"ShortcutBehaviorChangeToKorean", @"Hangul", @""),
                                          nil];
    GureumPreferencesHangulLayouts = [[NSArray alloc] initWithObjects:
                     @"org.youknowone.inputmethod.Gureum.han2",
                     @"org.youknowone.inputmethod.Gureum.han2classic",
                     @"org.youknowone.inputmethod.Gureum.han3final",
                     @"org.youknowone.inputmethod.Gureum.han3finalloose",
                     @"org.youknowone.inputmethod.Gureum.han390",
                     @"org.youknowone.inputmethod.Gureum.han390loose",
                     @"org.youknowone.inputmethod.Gureum.han3noshift",
                     @"org.youknowone.inputmethod.Gureum.han3classic",
                     //@"org.youknowone.inputmethod.Gureum.han3layout2",
                     @"org.youknowone.inputmethod.Gureum.hanroman",
                     @"org.youknowone.inputmethod.Gureum.hanahnmatae",
                     @"org.youknowone.inputmethod.Gureum.han3-2011",
                     @"org.youknowone.inputmethod.Gureum.han3-2011loose",
                     @"org.youknowone.inputmethod.Gureum.han3-2012",
                     @"org.youknowone.inputmethod.Gureum.han3-2012loose",
                     @"org.youknowone.inputmethod.Gureum.han3finalnoshift",
                     @"org.youknowone.inputmethod.Gureum.han3-2014",
                     @"org.youknowone.inputmethod.Gureum.han3-2015",
                     nil];

    NSDictionary *info = [NSBundle mainBundle].localizedInfoDictionary;
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *layout in GureumPreferencesHangulLayouts) {
        [names addObject:info[layout]];
    }
    GureumPreferencesHangulLayoutLocalizedNames = [[NSArray alloc] initWithArray:names];

    GureumPreferencesHangulSyllablePresentations = [[NSArray alloc] initWithObjects:
                                                    NSLocalizedStringFromTable(@"HangulPresentationRemoveFillers", @"Hangul", @""),
                                                    NSLocalizedStringFromTable(@"HangulPresentationAllFillers", @"Hangul", @""),
                                                    NSLocalizedStringFromTable(@"HangulPresentationRemoveNonJungseongFiller", @"Hangul", @""),
                                                    NSLocalizedStringFromTable(@"HangulPresentationHideFromFiller", @"Hangul", @""),
                                                    NSLocalizedStringFromTable(@"HangulPresentationHideFromJungseongFiller", @"Hangul", @""),
                                                    nil];
}

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    self->preferenceViews = [[NSDictionary alloc] initWithObjectsAndKeys:
                             shortcutPreferenceView, @"Shortcut",
                             gureumPreferenceView, @"Gureum",
                             hangulPreferenceView, @"Hangul",
                             nil];

    [self loadFromConfiguration];
    [self showPreferenceViewWithIdentifier:@"Shortcut" animate:YES];
}

- (void)dealloc {
    [self->preferenceViews release];
    [super dealloc];
}

#pragma mark -

- (void)selectPreferenceItem:(NSToolbarItem *)sender {
    NSString *identifier = sender.itemIdentifier;
    dlog(DEBUG_PREFERENCE, @"preference identifier: %@", identifier);
    [self showPreferenceViewWithIdentifier:identifier animate:YES];
}

#pragma mark NSToolbar delegate

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    return YES;
}

#pragma mark - private

- (void)showPreferenceViewWithIdentifier:(id)identifier animate:(BOOL)animate {
    NSView *newPreferenceView = self->preferenceViews[identifier];
    if (newPreferenceView == nil) return;

    NSArray *preferenceSubviews = self->preferenceContainerView.subviews;
    NSView *oldPreferenceView = preferenceSubviews.count > 0 ? preferenceSubviews[0] : nil;

    // Remove old one
    if (oldPreferenceView == newPreferenceView) return;
    [oldPreferenceView removeFromSuperview];

    // Arrange
    CGFloat toolbarHeight = NSHeight(self.window.frame) - NSHeight((self.window.contentView).frame);

    NSRect containerRect = self->preferenceContainerView.frame;
    containerRect.size = newPreferenceView.frame.size;
    containerRect.origin.y = commonButtonsView.frame.size.height;

    NSRect windowFrame = self.window.frame;
    windowFrame.size = containerRect.size;
    windowFrame.size.height += toolbarHeight;
    windowFrame.size.height += commonButtonsView.frame.size.height;
    CGFloat heightDiff = windowFrame.size.height - self.window.frame.size.height;
    windowFrame.origin.y -= heightDiff; // keep origin y
    [self.window setFrame:windowFrame display:YES animate:animate];

    self->preferenceContainerView.frame = containerRect;

    // Add new one
    [self->preferenceContainerView addSubview:newPreferenceView];
}

- (void)cancelAndClose:(id)sender {
    self->cancel = YES;
    [self.window close];
}

- (void)helpChangeShortcut:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"도움말" defaultButton:@"확인" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Space 또는 ⇧Space 로 초기화하고 새로 설정할 수 있습니다."];
    [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

#pragma NSWindow delegate

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"notification: %@", notification);
    if (!self->cancel) {
        [self saveToConfiguration:nil];
    }
    self->cancel = NO;
}

#pragma NSComboBox dataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return GureumPreferencesHangulLayouts.count;
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    return [GureumPreferencesHangulLayoutLocalizedNames indexOfObject:string];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    if (aComboBox == defaultHangulInputModeComboBox) {
        return GureumPreferencesHangulLayoutLocalizedNames[index];
    }
    if (aComboBox == hangulCombinationModeComposingComboBox || aComboBox == hangulCombinationModeCommitingComboBox) {
        return GureumPreferencesHangulSyllablePresentations[index];
    }
    assert(NO);
    return nil;
}

@end

