//
//  CIMInputControllerGureum.m
//  CharmIM
//
//  Created by youknowone on 12. 1. 7..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

#import "CIMInputControllerGureum.h"

#import "GureumAppDelegate.h"

@implementation CIMInputController (Gureum)

- (IBAction)checkRecentVersion:(id)sender {
    NSDictionary *versionInfo = [[GureumAppDelegate sharedAppDelegate] getRecentVersion];
    if (versionInfo == nil) {
        return;
    }

    NSString *recent = versionInfo[@"recent"];
    NSString *current = versionInfo[@"current"];
    NSString *download = versionInfo[@"download"];
    NSString *note = versionInfo[@"note"];

    if ([recent isEqualToString:current]) {
        NSString *fmt = @"현재 사용하고 있는 구름 입력기 %@ 는 최신 버전입니다.";
        NSAlert *alert = [NSAlert alertWithMessageText:@"구름 입력기 업데이트 확인" defaultButton:@"확인" alternateButton:nil otherButton:nil informativeTextWithFormat:fmt, current];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:NULL];
    } else {
        NSString *fmt = @"현재 사용하고 있는 구름 입력기는 %@ 이고 최신 버전은 %@ 입니다. 업데이트는 로그아웃하거나 재부팅해야 적용됩니다.";
        if (note.length) {
            fmt = [fmt stringByAppendingFormat:@" 업데이트 요약은 '%@' 입니다.", note];
        }
        if (download.length == 0) {
            fmt = [fmt stringByAppendingString:@" 곧 업데이트 링크가 준비될 예정입니다."];
        }
        NSAlert *alert = [NSAlert alertWithMessageText:@"구름 입력기 업데이트 확인" defaultButton:@"확인" alternateButton:nil otherButton:nil informativeTextWithFormat:fmt, current, recent];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        if (download.length > 0) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:download]];
        }
    }
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://gureum.org"]];
}

- (IBAction)openWebsiteHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://dan.gureum.org"]];
}

- (IBAction)openWebsiteSource:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://ssi.gureum.org"]];
}

- (IBAction)openWebsiteIssues:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://meok.gureum.org"]];
}

@end