//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation
protocol CryptoHelperProtocol {
    static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data
    static func decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data
}
