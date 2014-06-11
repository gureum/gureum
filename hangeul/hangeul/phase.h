//
//  phase.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 7..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_PHASE__
#define __HANGEUL_PHASE__

#include <cassert>
#include <string>

#include <hangeul/util.h>
#include <hangeul/data.h>
#include <hangeul/type.h>

namespace hangeul {
    extern State empty_state;

    struct PhaseResult {
        StateList states;
        bool processed;

        static PhaseResult Stop() { PhaseResult result; result.processed = false; return result; }
        static PhaseResult Make(StateList states, bool processed) {
            PhaseResult res = { states, processed };
            return res;
        }
    };

    class Phase { // abstract
    public:
        virtual PhaseResult put(StateList states) = 0;
        virtual PhaseResult put_state(StateList states, State new_state) {
            states.push_front(new_state);
            return this->put(states);
        }

        static State InitialState() { assert(false); State state; return state; }
        static std::string InputType() { assert(false); return ""; }
        static std::string OutputType() { assert(false); return ""; }

        bool validate_get(uint32_t key) { return true; }
        bool validate_set(uint32_t key, uint32_t value) { return true; }

        virtual ~Phase() { }
    };

    class MultiplePhase: public Phase {
        bool freeWhenDone;
    protected:
        std::vector<Phase *> phases;
    public:
        MultiplePhase(bool freeWhenDone = true) {
            this->freeWhenDone = freeWhenDone;
        }
        MultiplePhase(std::vector<Phase *> phases, bool freeWhenDone = true) {
            this->phases = phases;
            this->freeWhenDone = freeWhenDone;
        }
        virtual ~MultiplePhase() {
            if (freeWhenDone) {
                for (auto& phase: phases) {
                    delete phase;
                }
            }
        }
    };

    class CombinedPhase: public MultiplePhase {
    public:
        virtual PhaseResult put(StateList state);
    };

    //! try-failthen
    class FallbackPhase: public MultiplePhase {
    public:
        virtual PhaseResult put(StateList state);
    };

    //! try-finally
    class PostProcessPhase: public MultiplePhase {
    public:
        virtual PhaseResult put(StateList states);
    };

    //! state[1]->state[1] 변환
    class InputSourceTransformationPhase: public Phase { // abstract
        virtual PhaseResult put(StateList states) { return PhaseResult::Make(states, false); }
    };

    //! state[1]->state[2] 변환
    class KeyStrokePhase: public Phase { // abstract
        virtual PhaseResult put(StateList states) { return PhaseResult::Make(states, false); }
    };

    //! state[2]->... 변환
    class AnnotationPhase: public Phase { // abstract
        virtual PhaseResult put(StateList states) { return PhaseResult::Make(states, false); }
    };

    class QwertyToKeyStrokePhase: public KeyStrokePhase {
    public:
        virtual PhaseResult put(StateList states);

        static std::string InputType() { return "inputsource-qwerty"; }
        static std::string OutputType() { return "keystroke"; }
    };

    class MacKeycodeToKeyStrokePhase: public KeyStrokePhase {
    public:
        virtual PhaseResult put(StateList state);

        static std::string InputType() { return "inputsource-keycode-mac"; }
        static std::string OutputType() { return "keystroke"; }
    };

}

#endif