//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
//

import XCTest
import Foundation
import CryptoKit
import Security
@testable import SecurityHandler

final class CryptoHelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testEncryptDecrypt() {
        let originalData = "Hello, CryptoHelper!".data(using: .utf8)!
        
        do {
            let encryptedData = try SecurityHandler.CryptoHelper.encryptDataTest(originalData, symmetricKeyIdentifier: "com.example.symmetricKeyIdentifier", keychain: MockKeychainHelper.self)
            let decryptedData = try SecurityHandler.CryptoHelper.decryptDataTest(encryptedData, symmetricKeyIdentifier: "com.example.symmetricKeyIdentifier", keychain: MockKeychainHelper.self)
            XCTAssertEqual(originalData, decryptedData, "Original data and decrypted data should be equal")
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func testGetEncryptedKeyByUsingRSAPublicKey() {
        do {
            _ = try SecurityHandler.CryptoHelper.getEncryptedKeyByUsingRSAPublicKeyTest(symmetricKeyIdentifier: "com.example.symmetricKeyIdentifier", keychain: MockKeychainHelper.self)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
}
