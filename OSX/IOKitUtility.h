//
//  IOKitUtility.h
//  OSX
//
//  Created by Jeong YunWon on 2018. 9. 1..
//  Copyright © 2018년 youknowone.org. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/hidsystem/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDParameter.h>

NSEventModifierFlags CurrentModifierFlags(void);
