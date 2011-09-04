//
//  GureumInputManager.h
//  CharmIM
//
//  Created by youknowone on 11. 9. 3..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InputMethodKit/InputMethodKit.h>

#import "CIMComposer.h"
#import "CIMConfiguration.h"

ICEXTERN NSString *kGureumInputSourceIdentifierQwerty;
ICEXTERN NSString *kGureumInputSourceIdentifierDvorak;
ICEXTERN NSString *kGureumInputSourceIdentifierDvorakQwertyCommand;
ICEXTERN NSString *kGureumInputSourceIdentifierColemak;
ICEXTERN NSString *kGureumInputSourceIdentifierColemakQwertyCommand;
ICEXTERN NSString *kGureumInputSourceIdentifierHan2;
ICEXTERN NSString *kGureumInputSourceIdentifierHan2Classic;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Final;
ICEXTERN NSString *kGureumInputSourceIdentifierHan390;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3NoShift;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Classic;
ICEXTERN NSString *kGureumInputSourceIdentifierHan3Layout2;
ICEXTERN NSString *kGureumInputSourceIdentifierHanAhnmatae;
ICEXTERN NSString *kGureumInputSourceIdentifierHanRoman;

@class CIMInputHandler;
@class CIMHangulComposer;

#define GureumManager [GureumInputManager sharedManager]
@interface GureumInputManager : NSObject<IMKServerInputTextData> {
@private
    IMKServer *server;
    IMKCandidates *candidates;
    CIMConfiguration *configuration;
    CIMInputHandler *handler;
    
    NSString *inputMode;
    CIMBaseComposer *romanComposer;
    CIMHangulComposer *hangulComposer;
    NSObject<CIMComposer> *currentComposer;
}

@property(nonatomic, readonly) IMKServer *server;
@property(nonatomic, readonly) IMKCandidates *candidates;
@property(nonatomic, readonly) CIMConfiguration *configuration;
@property(nonatomic, readonly) CIMInputHandler *handler;
@property(nonatomic, retain) NSString *inputMode;
@property(nonatomic, readonly) NSObject<CIMComposer> *currentComposer;

@end

@interface GureumInputManager (SharedObject)

+ (GureumInputManager *)sharedManager;

@end
