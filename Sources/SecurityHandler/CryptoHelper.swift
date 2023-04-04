//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 04/04/2023.
//

import Foundation
import CryptoKit
import Security

class CryptoHelper {
    public static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier))
        let combined = sealedBox.combined!
        return combined
    }

    public static func decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier))
        return decryptedData
    }
    
}

extension CryptoHelper {
    private static func getSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey {
        if let key = try CryptoHelper.loadSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier) {
            return key
        } else {
            return try CryptoHelper.generateAndStoreSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier)
        }
    }
    private static func storeSymmetricKey(_ key: SymmetricKey, symmetricKeyIdentifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: symmetricKeyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
    }

    private static func loadSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: symmetricKeyIdentifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
        }
        if let keyData = item as? Data {
            let key = SymmetricKey(data: keyData)
            return key
        }
        return nil
    }

    private static func generateAndStoreSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        try storeSymmetricKey(key, symmetricKeyIdentifier: "com.yourapp.identifier.symmetricKey")
        return key
    }
}
