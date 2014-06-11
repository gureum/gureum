//
//  hangul.cpp
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#include <hangeul/hangeul.h>
#include <hangeul/hangul.h>

extern "C" {
    void *_context() {
        auto phase = new hangeul::KSX5002::FromQwertyPhase();
        return new hangeul::Context(phase, phase);
    }

    uint32_t _put(void *context, uint32_t input) {
        auto con = (hangeul::Context *)context;
        con->put(input);
        auto res = con->commited();
        if (res.size() == 0) {
            return 0;
        } else {
            return res[0];
        }
    }

    uint32_t _state(void *context) {
        auto con = (hangeul::Context *)context;
        auto res = con->state();
        if (res.size() == 0) {
            return 0;
        } else {
            return res[0];
        }
    }

    uint32_t _flush(void *context) {
        return 0;
    }

}