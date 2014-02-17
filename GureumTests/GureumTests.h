//
//  CharmIMTests.h
//  CharmIMTests
//
//  Created by youknowone on 11. 8. 31..
//  Copyright 2011 youknowone.org. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CIMInputController.h"

@interface CharmIMTests : SenTestCase {
@private
    CIMInputController *controller;
    CIMMockClient *client;
}

@end
