//
//  type.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 8..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_TYPE__
#define __HANGEUL_TYPE__

#include <stdint.h>
#include <vector>
#include <map>
#include <list>

namespace hangeul {
    typedef uint32_t InputSource;
    typedef uint32_t Unicode;
    class State: public std::map<int32_t, int32_t> {
    public:
        static State InputSource(int32_t input) {
            State state;
            state[1] = input;
            return state;
        }
    };
    typedef std::list<State> StateList;
    typedef std::vector<Unicode> UnicodeVector;

    enum KeyPosition { // platform independent position
        KeyPositionGrave = 0x00,
        KeyPosition1 = 0x01,
        KeyPosition2,
        KeyPosition3,
        KeyPosition4,
        KeyPosition5,
        KeyPosition6,
        KeyPosition7,
        KeyPosition8,
        KeyPosition9,
        KeyPosition0,
        KeyPositionMinus,
        KeyPositionEqual,
        KeyPositionBackslash, // 0x0d
        KeyPositionBackspace, // 0x0e
        KeyPositionTab = 0x10,
        KeyPositionQ = 0x11,
        KeyPositionW,
        KeyPositionE,
        KeyPositionR,
        KeyPositionT,
        KeyPositionY,
        KeyPositionU,
        KeyPositionI,
        KeyPositionO,
        KeyPositionP,
        KeyPositionBracketLeft,
        KeyPositionBracketRight, // 0x1c
        KeyPositionA = 0x21,
        KeyPositionS,
        KeyPositionD,
        KeyPositionF,
        KeyPositionG,
        KeyPositionH,
        KeyPositionJ,
        KeyPositionK,
        KeyPositionL,
        KeyPositionColon,
        KeyPositionQuote,
        KeyPositionEnter, // 0x2b
        KeyPositionLeftShift = 0x30,
        KeyPositionZ = 0x31,
        KeyPositionX,
        KeyPositionC,
        KeyPositionV,
        KeyPositionB,
        KeyPositionN,
        KeyPositionM,
        KeyPositionComma,
        KeyPositionPeriod,
        KeyPositionSlash, // 0x3a
        KeyPositionEsc = 0x3e,
        KeyPositionRightShift = 0x3f,
        KeyPositionSpace = 0x40,
        KeyPositionDelete = 0x41,
        KeyPositionLeft = 0x42,
        KeyPositionRight,
        KeyPositionUp,
        KeyPositionDown,
        KeyPositionHome = 0x46,
        KeyPositionEnd,
        KeyPositionPageUp,
        KeyPositionPageDown,
        KeyPositionLeftControl = 0x4a,
        KeyPositionLeftOS,
        KeyPositionLeftAlt,
        KeyPositionRightAlt,
        KeyPositionRightOS,
        KeyPositionRightControl, // 0x4f
        KeyPositionPad0 = 0x50,
        KeyPositionPad1,
        KeyPositionPad2,
        KeyPositionPad3,
        KeyPositionPad4,
        KeyPositionPad5,
        KeyPositionPad6,
        KeyPositionPad7,
        KeyPositionPad8,
        KeyPositionPad9,
        KeyPositionPadDecimal = 0x5f,
        KeyPositionPadPeriod = 0x60,
        KeyPositionPadPlus,
        KeyPositionPadMinus,
        KeyPositionPadMultiply,
        KeyPositionPadDivide,
        KeyPositionPadEqual,
        KeyPositionPadEnter,
        KeyPositionPadClear,
        KeyPositionISOSection = 0xd0,
        KeyPositionYen = 0xd2,
        KeyPositionUnderscore,
        KeyPositionPadComma,
        KeyPositionEisu,
        KeyPositionKana,
        KeyPositionFunction = 0xe0,
        KeyPositionF1 = 0xe1,
        KeyPositionF2,
        KeyPositionF3,
        KeyPositionF4,
        KeyPositionF5,
        KeyPositionF6,
        KeyPositionF7,
        KeyPositionF8,
        KeyPositionF9,
        KeyPositionF10,
        KeyPositionF11,
        KeyPositionF12,
        KeyPositionF13,
        KeyPositionF14,
        KeyPositionF15,
        KeyPositionF16,
        KeyPositionF17,
        KeyPositionF18,
        KeyPositionF19,
        KeyPositionF20,
    };

    typedef uint32_t KeyStroke;
    //KeyStroke KeyStrokeFromPositionAndModifiers(KeyPosition position, bool modifiers[5]) {
    //    return (modifiers[0] << 16) + (modifiers[1] << 17) + (modifiers[2] << 18) + (modifiers[3] << 19) + (modifiers[4] << 20) + position; // altshift, shift, control, alt, OS
    //}

}


#endif