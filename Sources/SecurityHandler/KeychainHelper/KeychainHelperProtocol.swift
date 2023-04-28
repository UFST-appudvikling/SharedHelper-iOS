//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
//

import Foundation
/// Documentaion
/// The KeychainHelperProtocol is a Protocol for KeychainHelper.
/// It's been design to be used in KeychainHelper.swift and not being exposed to the public.
public protocol KeychainHelperProtocol {
    static func create(cfDictionary: CFDictionary) -> Bool
    static func update(cfDictionary: CFDictionary) -> Bool
    static func remove(cfDictionary: CFDictionary) -> Bool
    static func search(matching cfDictionary: CFDictionary) -> Data?
}
