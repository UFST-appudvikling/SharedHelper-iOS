//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation

class MockCryptoHelper: StaticCryptoHelperProtocol {
    static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data {
        // Implement the mock encryption logic here
        return data // Just returning the data without encryption as an example
    }
    
    static func decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data {
        // Implement the mock decryption logic here
        return encryptedData // Just returning the data without decryption as an example
    }
}
