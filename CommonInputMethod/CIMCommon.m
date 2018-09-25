//
//  CIMCommon.m
//  CharmIM
//
//  Created by Jeong YunWon on 12. 12. 24..
//  Copyright (c) 2012 youknowone.org. All rights reserved.
//

#import "CIMCommon.h"

NS_ASSUME_NONNULL_BEGIN

const char CIMKeyMapLower[CIMKeyMapSize] = {
    'a', 's', 'd', 'f', 'h', 'g', 'z', 'x',
    'c', 'v',   0, 'b', 'q', 'w', 'e', 'r',
    'y', 't', '1', '2', '3', '4', '6', '5',
    '=', '9', '7', '-', '8', '0', ']', 'o',
    'u', '[', 'i', 'p',   0, 'l', 'j','\'',
    'k', ';','\\', ',', '/', 'n', 'm', '.',
      0,   0, '`',
};
const char CIMKeyMapUpper[CIMKeyMapSize] = {
    'A', 'S', 'D', 'F', 'H', 'G', 'Z', 'X',
    'C', 'V',   0, 'B', 'Q', 'W', 'E', 'R',
    'Y', 'T', '!', '@', '#', '$', '^', '%',
    '+', '(', '&', '_', '*', ')', '}', 'O',
    'U', '{', 'I', 'P',   0, 'L', 'J', '"',
    'K', ':', '|', '<', '?', 'N', 'M', '>',
      0,   0, '~',
};

NS_ASSUME_NONNULL_END
