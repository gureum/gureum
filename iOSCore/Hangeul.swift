//
//  Hangeul.swift
//  iOS
//
//  Created by Jeong YunWon on 8/5/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

func context_get_composed_unicodes(context: UnsafeMutablePointer<()>) -> [UnicodeScalar] {
    let buffer = unicodevector_create()
    context_get_composed(context, buffer)
    let size = unicodevector_size(buffer)
    var result: [UnicodeScalar] = []
    for i in 0..<size {
        let unicode = unicodevector_get(buffer, i)
        result.append(UnicodeScalar(unicode))
    }
    unicodevector_free(buffer)
    return result
}

func context_get_commited_unicodes(context: UnsafeMutablePointer<()>) -> [UnicodeScalar] {
    return []; // temp
    let buffer = unicodevector_create()
    context_get_commited(context, buffer)
    let size = unicodevector_size(buffer)
    var result: [UnicodeScalar] = []
    for i in 0..<size {
        let unicode = unicodevector_get(buffer, i)
        result.append(UnicodeScalar(unicode))
    }
    unicodevector_free(buffer)
    return result
}

func unicodes_to_string(unicodes: [UnicodeScalar]) -> String {
    var result = ""
    for unicode in unicodes {
        result.append(unicode)
    }
    return result
}