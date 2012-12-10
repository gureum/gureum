//
//  CIMInputControllerGureum.m
//  CharmIM
//
//  Created by youknowone on 12. 1. 7..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

#import "CIMInputControllerGureum.h"

@implementation CIMInputController (Gureum)

- (IBAction)checkRecentVersion:(id)sender {
    NSError *error = nil;
    NSString *verstring = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://gureum.org/version.txt"] encoding:NSUTF8StringEncoding error:&error];
    NSArray *components = [verstring componentsSeparatedByString:@"::"];
    NSString *recentVersion = [components objectAtIndex:0];
    NSString *recentDownload = [components objectAtIndex:1];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    if ([recentVersion isEqualToString:currentVersion]) {
        NSString *fmt = @"현재 사용하고 있는 구름 입력기 %@ 는 최신 버전입니다.";
        NSAlert *alert = [NSAlert alertWithMessageText:@"구름 입력기 업데이트 확인" defaultButton:@"확인" alternateButton:nil otherButton:nil informativeTextWithFormat:fmt, currentVersion];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:NULL];
    } else {
        NSString *fmt = @"현재 사용하고 있는 구름 입력기는 %@ 이고 최신 버전은 %@ 입니다.";
        if (recentDownload.length == 0) {
            fmt = [fmt stringByAppendingString:@" 곧 업데이트 링크가 준비될 예정입니다."];
        }
        NSAlert *alert = [NSAlert alertWithMessageText:@"구름 입력기 업데이트 확인" defaultButton:@"확인" alternateButton:nil otherButton:nil informativeTextWithFormat:fmt, currentVersion, recentVersion];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:NULL];
        if (recentDownload.length > 0) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:recentDownload]];
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