//
//  GureumAppDelegate.m
//  Gureum
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "GureumAppDelegate.h"

#import "CIMInputManager.h"
#import "GureumComposer.h"

#import "GureumPreferencesWindowController.h"

@implementation GureumAppDelegate
@synthesize menu;

- (void)awakeFromNib {
    [Crashlytics startWithAPIKey:@"1b5d8443c3eabba778b0d97bff234647af846181"];

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
    NSString *download = (__bridge id)contextInfo;
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gureum.io/version.txt"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
    NSData *data = [NSData dataWithContentsOfURLRequest:request error:&error];
    if (data == nil || error != nil) {
        return nil;
    }
    NSString *verstring = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
    if (verstring == nil || error != nil) {
        return nil;
    }
    NSArray *components = [verstring componentsSeparatedByString:@"::"];
    if (components.count < 2) {
        return nil;
    }
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
