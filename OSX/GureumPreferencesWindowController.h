//
//  GureumPreferencesWindowController.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 22..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SRRecorderCell;

@interface GureumPreferencesWindowController : NSWindowController<NSWindowDelegate, NSToolbarDelegate, NSComboBoxDataSource> {
@private
    IBOutlet NSView *preferenceContainerView;
    IBOutlet NSView *commonButtonsView;
    IBOutlet NSView *shortcutPreferenceView, *gureumPreferenceView, *hangulPreferenceView;
    NSDictionary *preferenceViews;
    BOOL cancel;

    /* Shortcut Preferences */
    IBOutlet NSComboBox *leftCommandBehaviorComboBox;
    IBOutlet NSComboBox *leftOptionBehaviorComboBox;
    IBOutlet NSComboBox *leftControlBehaviorComboBox;
    IBOutlet NSComboBox *rightCommandBehaviorComboBox;
    IBOutlet NSComboBox *rightOptionBehaviorComboBox;
    IBOutlet NSComboBox *rightControlBehaviorComboBox;
    IBOutlet SRRecorderCell *inputModeExchangeKeyRecorderCell;
    IBOutlet SRRecorderCell *inputModeHanjaKeyRecorderCell;
    IBOutlet SRRecorderCell *inputModeEnglishKeyRecorderCell;
    IBOutlet SRRecorderCell *inputModeKoreanKeyRecorderCell;

    /* Gureum Preferences */
    IBOutlet NSButton *autosaveDefaultInputModeCheckbox;
    IBOutlet NSComboBox *defaultHangulInputModeComboBox;
    IBOutlet NSComboBox *optionKeyBehaviorComboBox;

    IBOutlet NSButton *romanModeByEscapeKeyCheckbox;
    IBOutlet NSButton *zeroWidthSpaceForLayoutExchangeCheckbox;

    /* Hangul Preferences */
    IBOutlet NSButton *showsInputForHanjaCandidatesCheckbox;

    IBOutlet NSComboBox *hangulCombinationModeComposingComboBox;
    IBOutlet NSComboBox *hangulCombinationModeCommitingComboBox;
}

- (IBAction)saveToConfiguration:(id)sender;
- (IBAction)selectPreferenceItem:(id)sender;
- (IBAction)cancelAndClose:(id)sender;

- (IBAction)helpChangeShortcut:(id)sender;

@end
