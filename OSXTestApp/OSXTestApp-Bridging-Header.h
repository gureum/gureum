//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

@import PreferencePanes;

@interface NSPrefPaneBundle: NSObject

- (instancetype)initWithPath:(id)arg1;
- (BOOL)instantiatePrefPaneObject;
- (NSPreferencePane *)prefPaneObject;

@property(readonly) NSBundle *bundle;

@end
