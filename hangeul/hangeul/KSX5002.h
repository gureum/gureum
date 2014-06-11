//
//  KSX5002.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 7. 5..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __hangeul__KSX5002__
#define __hangeul__KSX5002__

#include <hangeul/phase.h>
#include <hangeul/decoder.h>

namespace hangeul { namespace KSX5002 {

    namespace AnnotationClass {
        enum Type {
            ASCII,
            Function,
            Consonant,
            Vowel,
        };
    }

    struct Annotation {
        AnnotationClass::Type type;
        uint32_t data;
    };

    class Decoder: public hangeul::Decoder {
        virtual UnicodeVector decode(State state);
    };

    //! state[2]->state['0', 'a', 'b', 'c'] - 날개셋 호환용
    class KeyStrokeToAnnotationPhase: public AnnotationPhase {
    public:
        virtual PhaseResult put(StateList state);

        static std::string InputType() { assert(false); return "keyposition"; }
        static std::string OutputType() { assert(false); return "annotation-ksx5002"; }
    };

    class JasoCombinationPhase: Phase {
    public:
        virtual PhaseResult put(StateList state);

        static std::string InputType() { assert(false); return "annotation-ksx5002"; }
        static std::string OutputType() { assert(false); return "annotation-ksx5002"; }
    };

    class AnnotationToCombinationPhase: Phase {
    public:
        virtual PhaseResult put(StateList state);

        static std::string InputType() { assert(false); return "annotation-ksx5002"; }
        static std::string OutputType() { assert(false); return "combination-ksx5002"; }
    };


    class FromQwertyPhase: public CombinedPhase {
    public:
        static std::string InputType() { assert(false); return "inputsource-qwerty"; }
        static std::string OutputType() { assert(false); return "combination-ksx5002"; }

        FromQwertyPhase() : CombinedPhase() {
            this->phases.push_back((Phase *)new QwertyToKeyStrokePhase());
            this->phases.push_back((Phase *)new KeyStrokeToAnnotationPhase());
            this->phases.push_back((Phase *)new JasoCombinationPhase());
            this->phases.push_back((Phase *)new AnnotationToCombinationPhase());
        }
    };

} }

#endif /* defined(__hangeul__KSX5002__) */
