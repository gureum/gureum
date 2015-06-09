//
//  Hangeul.swift
//  Gureum
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

func unicodes_nfc_to_nfd(unicodes: [UnicodeScalar]) -> [UnicodeScalar] {
    let nfc_buffer = unicodevector_create()
    let nfd_buffer = unicodevector_create()
    for unicode in unicodes {
        unicodevector_append(nfc_buffer, Unicode(unicode))
    }

    nfc_to_nfd(nfc_buffer, nfd_buffer)

    var result: [UnicodeScalar] = []
    for i in 0..<unicodevector_size(nfd_buffer) {
        let unicode = unicodevector_get(nfd_buffer, i)
        result.append(UnicodeScalar(unicode))
    }

    unicodevector_free(nfc_buffer)
    unicodevector_free(nfd_buffer)
    return result
}