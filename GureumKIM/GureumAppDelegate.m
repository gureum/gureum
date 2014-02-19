//
//  GureumAppDelegate.m
//  GureumKIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import "GureumAppDelegate.h"

#import "CIMInputManager.h"
#import "GureumComposer.h"

#import "GureumPreferencesWindowController.h"

@implementation GureumAppDelegate
@synthesize menu;

- (void)awakeFromNib {
    self->sharedInputManager = [[CIMInputManager alloc] init];

    NSDictionary *versionInfo = [[GureumAppDelegate sharedAppDelegate] getRecentVersion];

    NSString *recent = versionInfo[@"recent"];
    NSString *current = versionInfo[@"current"];
    NSString *download = versionInfo[@"download"];
    NSString *note = versionInfo[@"note"];

    if (![recent isEqualToString:current] && download.length > 0) {
        NSString *fmt = @"현재 사용하고 있는 구름 입력기는 %@ 이고 최신 버전은 %@ 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다.";
        if (note.length) {
            fmt = [fmt stringByAppendingFormat:@" 업데이트 요약은 '%@' 입니다.", note];
        }
        NSAlert *alert = [NSAlert alertWithMessageText:@"구름 입력기 업데이트 확인" defaultButton:@"확인" alternateButton:@"취소" otherButton:nil informativeTextWithFormat:fmt, current, recent];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:[download retain]];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSString *download = (id)contextInfo;
    if (returnCode == NSAlertDefaultReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:download]];
    }
    [download release];
}


- (void)dealloc {
    [self->sharedInputManager release];
    [super dealloc];
}

- (CIMInputManager *)sharedInputManager {
    return self->sharedInputManager;
}

- (CIMComposer *)composerWithServer:(IMKServer *)server client:(id)client {
    dlog(TRUE, @"**** New blank composer generated ****");
    CIMComposer *composer = [[GureumComposer alloc] init];
    return [composer autorelease];                         
}

- (NSDictionary *)getRecentVersion {
    NSError *error = nil;
    NSString *verstring = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://gureum.org/version.txt"] encoding:NSUTF8StringEncoding error:&error];
    if (verstring == nil || error) {
        return nil;
    }
    NSArray *components = [verstring componentsSeparatedByString:@"::"];
    NSString *recentVersion = components[0];
    NSString *recentDownload = components[1];
    NSString *releaseNote = nil;
    if (components.count >= 3) {
        releaseNote = components[2];
    }
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

    if (!recentVersion || !currentVersion || !recentDownload) {
        NSLog(@"- Recent Version: %@", recentVersion);
        NSLog(@"- Current Version: %@", currentVersion);
        NSLog(@"- Recent Download: %@", recentDownload);
        return nil;
    }

    if (releaseNote) {
        return @{@"recent": recentVersion, @"current": currentVersion, @"download": recentDownload, @"note": releaseNote};
    }
    return @{@"recent": recentVersion, @"current": currentVersion, @"download": recentDownload};
}

+ (GureumAppDelegate *)sharedAppDelegate {
    return (id)[NSApp delegate];
}

@end
