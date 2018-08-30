//
//  Hangeul.swift
//  iOS
//
//  Created by Jeong YunWon on 8/5/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

func context_get_composed_unicode(context: UnsafeMutableRawPointer) -> UInt32 {
    let buffer = unicodevector_create()
    context_get_composed(context, buffer)
    let size = unicodevector_size(buffer)
    let result = size == 0 ? 0 : unicodevector_get(buffer, 0)
    unicodevector_free(buffer)
    return result
}

func context_get_commited_unicode(context: UnsafeMutableRawPointer) -> UInt32 {
    let buffer = unicodevector_create()
    context_get_commited(context, buffer)
    let size = unicodevector_size(buffer)
    let result = size == 0 ? 0 : unicodevector_get(buffer, 0)
    unicodevector_free(buffer)
    return result
}
