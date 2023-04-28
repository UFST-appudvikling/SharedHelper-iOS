//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
//

import Foundation
public protocol KeychainHelperProtocol {
    static func create(cfDictionary: CFDictionary) -> Bool
    static func update(cfDictionary: CFDictionary) -> Bool
    static func remove(cfDictionary: CFDictionary) -> Bool
    static func search(matching cfDictionary: CFDictionary) -> Data?
}
