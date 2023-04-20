//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation
protocol StaticCryptoHelperProtocol {
    static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data
}
