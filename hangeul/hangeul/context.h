//
//  context.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_CONTEXT__
#define __HANGEUL_CONTEXT__

#include <vector>
#include <hangeul/phase.h>

namespace hangeul {
    class Context {
    protected:
        StateList states;
        Phase *processor;
        Phase *decoder;

    public:
        Context(Phase *processor, Phase *decoder) { this->processor = processor; this->decoder = decoder; }

        void put(InputSource input) {
            State state;
            state[1] = input;
            this->states.push_front(state);
            auto res = this->processor->put(this->states);
            this->states = res.states;
        }

        void flush() {
            this->states.front()[-1] = 1;
        }

        UnicodeVector commited() {
            UnicodeVector result;
            while (this->states.size() > 0) {
                // FIXME: not a STL way yet
                result.push_back(this->states.back()[0]);
                this->states.pop_back();
            }
            if (this->states.size() && this->states.back()[-1]) {
                result.push_back(this->states.back()[0]);
                this->states.pop_back();
            }
            return result;
        }
        
        UnicodeVector state() {
            StateList copied = states;
            copied.reverse();
            UnicodeVector result;
            for (auto state: copied) {
                result.push_back(state[0]);
            }
            return result;
        }
    };
}

#endif
