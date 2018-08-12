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

- (void)loadFromConfiguration {
    GureumConfiguration *configuration = [[GureumConfiguration alloc] init];

    // shortcut
//    self->leftCommandBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->leftCommandKeyShortcutBehavior];
//    self->leftOptionBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->leftOptionKeyShortcutBehavior];
//    self->leftControlBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->leftControlKeyShortcutBehavior];
//    self->rightCommandBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->rightCommandKeyShortcutBehavior];
//    self->rightOptionBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->rightOptionKeyShortcutBehavior];
//    self->rightControlBehaviorComboBox.stringValue = GureumPreferencesShortcutBehaviors[configuration->rightControlKeyShortcutBehavior];
//    self->inputModeExchangeKeyRecorderCell.keyCombo = SRMakeKeyCombo(configuration->inputModeExchangeKeyCode, configuration->inputModeExchangeKeyModifier);
//    self->inputModeHanjaKeyRecorderCell.keyCombo = SRMakeKeyCombo(configuration->inputModeHanjaKeyCode, configuration->inputModeHanjaKeyModifier);
//    self->inputModeEnglishKeyRecorderCell.keyCombo = SRMakeKeyCombo(configuration->inputModeEnglishKeyCode, configuration->inputModeEnglishKeyModifier);
//    self->inputModeKoreanKeyRecorderCell.keyCombo = SRMakeKeyCombo(configuration->inputModeKoreanKeyCode, configuration->inputModeKoreanKeyModifier);

    // common
    dlog(DEBUG_PREFERENCE, @"default input mode: %d", configuration.autosaveDefaultInputMode);
    self->autosaveDefaultInputModeCheckbox.integerValue = configuration.autosaveDefaultInputMode;
    dlog(DEBUG_PREFERENCE, @"last hangul input mode: %@", configuration.lastHangulInputMode);
    NSInteger index = [GureumPreferencesHangulLayouts indexOfObject:configuration.lastHangulInputMode];
    self->defaultHangulInputModeComboBox.stringValue = GureumPreferencesHangulLayoutLocalizedNames[index];
    self->romanModeByEscapeKeyCheckbox.integerValue = configuration.romanModeByEscapeKey;

    // hangul
    [self->optionKeyBehaviorComboBox selectItemAtIndex:configuration.optionKeyBehavior];
    self->showsInputForHanjaCandidatesCheckbox.integerValue = configuration.showsInputForHanjaCandidates;

    self->hangulCombinationModeComposingComboBox.stringValue = GureumPreferencesHangulSyllablePresentations[configuration.hangulCombinationModeComposing];
    self->hangulCombinationModeCommitingComboBox.stringValue = GureumPreferencesHangulSyllablePresentations[configuration.hangulCombinationModeCommiting];
}

- (void)saveToConfiguration:(id)sender {
    GureumConfiguration *configuration = [[GureumConfiguration alloc] init];

    // shortcut
//    configuration->leftCommandKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->leftCommandBehaviorComboBox.stringValue];
//    configuration->leftOptionKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->leftOptionBehaviorComboBox.stringValue];
//    configuration->leftControlKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->leftControlBehaviorComboBox.stringValue];
//    configuration->rightCommandKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->rightCommandBehaviorComboBox.stringValue];
//    configuration->rightOptionKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->rightOptionBehaviorComboBox.stringValue];
//    configuration->rightControlKeyShortcutBehavior = [GureumPreferencesShortcutBehaviors indexOfObject:self->rightControlBehaviorComboBox.stringValue];
//    configuration->inputModeExchangeKeyCode = self->inputModeExchangeKeyRecorderCell.keyCombo.code;
//    configuration->inputModeExchangeKeyModifier = self->inputModeExchangeKeyRecorderCell.keyCombo.flags;
//    configuration->inputModeHanjaKeyCode = self->inputModeHanjaKeyRecorderCell.keyCombo.code;
//    configuration->inputModeHanjaKeyModifier = self->inputModeHanjaKeyRecorderCell.keyCombo.flags;
//    configuration->inputModeEnglishKeyCode = self->inputModeEnglishKeyRecorderCell.keyCombo.code;
//    configuration->inputModeEnglishKeyModifier = self->inputModeEnglishKeyRecorderCell.keyCombo.flags;
//    configuration->inputModeKoreanKeyCode = self->inputModeKoreanKeyRecorderCell.keyCombo.code;
//    configuration->inputModeKoreanKeyModifier = self->inputModeKoreanKeyRecorderCell.keyCombo.flags;

    // common
    /*
    configuration->autosaveDefaultInputMode = self->autosaveDefaultInputModeCheckbox.integerValue;
    NSInteger index = [GureumPreferencesHangulLayoutLocalizedNames indexOfObject:self->defaultHangulInputModeComboBox.stringValue];
    configuration->lastHangulInputMode = GureumPreferencesHangulLayouts[index];
    configuration->optionKeyBehavior = self->optionKeyBehaviorComboBox.indexOfSelectedItem;
    configuration->romanModeByEscapeKey = self->romanModeByEscapeKeyCheckbox.integerValue;

    // hangeul
    configuration->showsInputForHanjaCandidates = self->showsInputForHanjaCandidatesCheckbox.integerValue;
    configuration->hangulCombinationModeComposing = [GureumPreferencesHangulSyllablePresentations indexOfObject:self->hangulCombinationModeComposingComboBox.stringValue];
    configuration->hangulCombinationModeCommiting = [GureumPreferencesHangulSyllablePresentations indexOfObject:self->hangulCombinationModeCommitingComboBox.stringValue];

    [configuration saveAllConfigurations];
     */
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

