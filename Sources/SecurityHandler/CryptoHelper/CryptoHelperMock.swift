//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
//

import Foundation
import CryptoKit
import Security
extension SecurityHandler {
    class MockCryptoHelper: CryptoHelperProtocol {
        static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data {
            try CryptoHelper.encryptDataTest(data, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: MockKeychainHelper.self)
        }
        
        static func decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data {
            try CryptoHelper.decryptDataTest(encryptedData, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: MockKeychainHelper.self)
        }
    }

}
