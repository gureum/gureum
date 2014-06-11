//
//  KSX5002.cpp
//  hangeul
//
//  Created by Jeong YunWon on 2014. 7. 5..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#include "KSX5002.h"

namespace hangeul {

    namespace KSX5002 {
        UnicodeVector Decoder::decode(State state) {
            UnicodeVector unicodes;
            if (state['a'] && state['b']) {
                auto v = 0xac00;
                v += (Initial::FromConsonant[state['a']] - 1) * 21 * 28;
                v += (state['b'] - 1) * 28;
                if (state['c']) {
                    v += Final::FromConsonant[state['c']];
                }
                unicodes.push_back(v);
            }
            else if (state['a'] && !state['b']) {
                auto v = 0x3131 + state['a'] - 1;
                unicodes.push_back(v);
            }
            else if (!state['a'] && !state['b']) {
                auto v = 0x314f + state['b'] - 1;
                unicodes.push_back(v);
            }
            else {
                unicodes.push_back(state[0]);
            }
            return unicodes;
        }

        PhaseResult KeyStrokeToAnnotationPhase::put(StateList states) {
            #define A(C) { AnnotationClass::ASCII, C }
            #define F(C) { AnnotationClass::Function, KeyPosition ## C }
            #define C(C) { AnnotationClass::Consonant, Consonant:: C }
            #define V(C) { AnnotationClass::Vowel, Vowel:: C }
            #define E() { AnnotationClass::Function, 0 }

            static Annotation map[] = {
                A('`'), A('1'), A('2'), A('3'), A('4'), A('5'), A('6'), A('7'), A('8'), A('9'), A('0'), A('-'), A('='), A('\\'), F(Backspace),  E(),
                A('\t'), C(B), C(J), C(D), C(G), C(S), V(Yo), V(Yeo), V(Ya), V(Ae), V(E), A('['),  A(']'), E(), E(), E(),
                E(), C(M), C(N), C(NG), C(R), C(H), V(O), V(Eo), V(A), V(I), A(';'), A('\''), F(Enter), E(), E(), E(),
                E(), C(K), C(T), C(CH), C(P), V(Yu), V(U), V(Eu), A(','), A('.'), A('/'), E(), E(), E(), E(), E(),
            };

            #undef A
            #undef F
            #undef C
            #undef V

            auto& state = states.front();
            auto input = state[2];
            Annotation stroke = map[input & 0xff];
            switch (stroke.type) {
                case AnnotationClass::Consonant:
                    state['a'] = stroke.data;
                    break;
                case AnnotationClass::Vowel:
                    state['b'] = stroke.data;
                    break;
                case AnnotationClass::ASCII:
                    state[0] = stroke.data;
                    break;
                case AnnotationClass::Function:
                    state[2] = stroke.data;
                    break;
                default:
                    break;
            }

            return PhaseResult::Make(states, true);
        }

        PhaseResult JasoCombinationPhase::put(StateList states) {
            if (states.size() == 1) {
                return PhaseResult::Make(states, false);
            }
            auto iter = states.begin();
            auto& state = *iter;
            iter++;
            auto& secondary = *iter;
            bool combined = false;
            if (state['a'] && secondary['c']) {
                #define R(A, B, X) {Consonant::A, Consonant::B, Consonant::X}
                const Consonant::Type table[][3] = {
                    R(G, S, GS),
                    R(N, J, NJ),
                    R(N, H, NH),
                    R(R, G, RG),
                    R(R, M, RM),
                    R(R, B, RB),
                    R(R, S, RS),
                    R(R, T, RT),
                    R(R, P, RP),
                    R(R, H, RH),
                };
                #undef R
                auto c1 = state['a'];
                auto c2 = secondary['c'];
                for (auto& rule: table) {
                    if (c1 == rule[0] && c2 == rule[1]) {
                        secondary['c'] = rule[2];
                        combined = true;
                        break;
                    }
                }
            }
            else if (state['b'] && secondary['b']) {
#define R(A, B, X) {Vowel::A, Vowel::B, Vowel::X}
                const Vowel::Type table[][3] = {
                    R(O, A, Wa),
                    R(O, Ae, Wae),
                    R(O, I, Oe),
                    R(U, Eo, Weo),
                    R(U, E, We),
                    R(U, I, Wi),
                    R(Eu, I, Ui),
                };
#undef R
                auto c1 = state['b'];
                auto c2 = secondary['b'];
                for (auto& rule: table) {
                    if (c1 == rule[0] && c2 == rule[1]) {
                        secondary['b'] = rule[2];
                        combined = true;
                        break;
                    }
                }
            }
            if (combined) {
                states.erase(states.begin());
                return PhaseResult::Make(states, true);
            }
            return PhaseResult::Make(states, true);
        }

        PhaseResult AnnotationToCombinationPhase::put(StateList states) {
            auto iter = states.begin();
            auto& state = states.front();
            if (!state['a'] && !state['b'] && !state['c']) {
                return PhaseResult::Make(states, true);
            }
            if (states.size() == 1) {
                return PhaseResult::Make(states, false);
            }
            iter++;
            auto& secondary = *iter;
            if (state['a']) {
                if (secondary['b'] && !secondary['c']) {
                    secondary['c'] = state['a'];
                    states.erase(states.begin());
                    return PhaseResult::Make(states, true);
                }
                else {
                    return PhaseResult::Make(states, false);
                }
            }
            else if (state['b']) {
                if (!secondary['b']) {
                    secondary['b'] = state['b'];
                    states.erase(states.begin());
                    return PhaseResult::Make(states, true);
                }
                else if (!state['a'] && secondary['c']) {
                    state['a'] = secondary['c'];
                    secondary['c'] = 0;
                    return PhaseResult::Make(states, true);
                }
                else {
                    return PhaseResult::Make(states, false);
                }
            }
            else {
                assert(false);
            }
            return PhaseResult::Make(states, false);
        }

    }

}