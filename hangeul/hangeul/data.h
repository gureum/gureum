//
//  data.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_DATA__
#define __HANGEUL_DATA__

namespace hangeul {

    namespace Initial {
        enum Type {
            G = 1,
            GG = 2,
            N = 3,
            D = 4,
            DD = 5,
            R = 6,
            M = 7,
            B = 8,
            BB = 9,
            S = 10,
            SS = 11,
            NG = 12,
            J = 13,
            JJ = 14,
            CH = 15,
            K = 16,
            T = 17,
            P = 18,
            H = 19,
        };
        extern Initial::Type FromConsonant[31];
    }

    namespace Vowel {
        enum Type {
            A = 1,
            Ae = 2,
            Ya = 3,
            Yae = 4,
            Eo = 5,
            E = 6,
            Yeo = 7,
            Ye = 8,
            O = 9,
            Wa = 10,
            Wae = 11,
            Oe = 12,
            Yo = 13,
            U = 14,
            Weo = 15,
            We = 16,
            Wi = 17,
            Yu = 18,
            Eu = 19,
            Ui = 20,
            I = 21,
        };
    }

    namespace Final {
        enum Type {
            _ = 0,
            G = 1,
            GG = 2,
            GS = 3,
            N = 4,
            NJ = 5,
            NH = 6,
            D = 7,
            R = 8,
            RG = 9,
            RM = 10,
            RB = 11,
            RS = 12,
            RT = 13,
            RP = 14,
            RH = 15,
            M = 16,
            B = 17,
            BS = 18,
            S = 19,
            SS = 20,
            NG = 21,
            J = 22,
            CH = 23,
            K = 24,
            T = 25,
            P = 26,
            H = 27,
        };
        extern Final::Type FromConsonant[31];
    }

    namespace Consonant {
        enum Type {
            G = 1,
            GG = 2,
            GS = 3,
            N = 4,
            NJ = 5,
            NH = 6,
            D = 7,
            DD = 8,
            R = 9,
            RG = 10,
            RM = 11,
            RB = 12,
            RS = 13,
            RT = 14,
            RP = 15,
            RH = 16,
            M = 17,
            B = 18,
            BB = 19,
            BS = 20,
            S = 21,
            SS = 22,
            NG = 23,
            J = 24,
            JJ = 25,
            CH = 26,
            K = 27,
            T = 28,
            P = 29,
            H = 30,
        };
    }
}

#endif
