import Foundation
import CryptoKit
import Security

public extension SecurityHelper {
     class CryptoHelper {
        public static func encryptData(_ data: Data,
                                       symmetricKeyIdentifier: String) throws -> Data {
            let sealedBox = try AES.GCM.seal(data, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier))
            guard let combined = sealedBox.combined else { throw CustomError.encryptionError(errorDescription: "Error: sealedBox.combined didnt work")}
            return combined
        }

        public static func decryptData(_ encryptedData: Data,
                                       symmetricKeyIdentifier: String) throws -> Data {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier))
            return decryptedData
        }
         
         public static func getEncryptedKeyByUsingRSAPublicKey(publicKeyData:Data? = nil,
                                                               symmetricKeyIdentifier: String) throws -> Data {
             let rsaKey = try CryptoHelper.rsaPublicKeyFromPEM(derKey: publicKeyData)
             let aesKeyData = try CryptoHelper.loadSymmetricKeyData(symmetricKeyIdentifier: symmetricKeyIdentifier)
             //TODO: use rsaEncryptionOAEPSHA256 in algorithm instead.
             return try CryptoHelper.encryptData(data: aesKeyData, publicKey: rsaKey)
         }
        
    }
}

extension SecurityHelper.CryptoHelper {
    private static func getSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey {
        do {
            return try SecurityHelper.CryptoHelper.loadSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier)
        } catch {
            return try SecurityHelper.CryptoHelper.generateAndStoreSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier)
        }
    }
    private static func storeSymmetricKey(_ key: SymmetricKey, symmetricKeyIdentifier: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlocked,
            [],
            nil
        )
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: symmetricKeyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessControl as String: accessControl!
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw CustomError.keychainError(errorDescription: NSOSStatusErrorDomain + String(Int(status)))
        }
    }

    private static func loadSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey {
        let keyData = try loadSymmetricKeyData(symmetricKeyIdentifier: symmetricKeyIdentifier)
        return SymmetricKey(data: keyData)
    }
        
    private static func loadSymmetricKeyData(symmetricKeyIdentifier: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: symmetricKeyIdentifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound, status == errSecSuccess else {
            throw CustomError.keychainError(errorDescription: NSOSStatusErrorDomain + String(Int(status)))
        }
        if let keyData = item as? Data {
            return keyData
        } else {
            throw CustomError.invalidData
        }
    }


    private static func generateAndStoreSymmetricKey(symmetricKeyIdentifier: String) throws -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        try storeSymmetricKey(key, symmetricKeyIdentifier: symmetricKeyIdentifier)
        return key
    }
    
    private static func loadRSAPublicKey() throws -> Data {
        let resourceFileName = "key"
        
        guard let fileURL = Bundle.module.url(forResource: resourceFileName, withExtension: nil) else {
            throw CustomError.resourceError(errorDescription: "Error: Resource file not found")
        }
        
        do {
            let keyData = try Data(contentsOf: fileURL)
            return keyData
        } catch {
            throw CustomError.invalidData
        }
    }
    private static func rsaPublicKeyFromPEM(derKey: Data?) throws -> SecKey {
        let derKey = try loadRSAPublicKey()
        let base64Key = derKey.base64EncodedString()
        
        guard let base64Data = Data(base64Encoded: base64Key) else {
            throw CustomError.invalidData
        }
        
        let options: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(base64Data as CFData, options as CFDictionary, &error) else {
            throw CustomError.unknownError(errorDescription: (String(describing: error)))
        }
        
        return key
    }
    
    private static func encryptData(algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1, data: Data, publicKey: SecKey) throws -> Data {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
            
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw CustomError.algorithmError(errorDescription: "Algorithm not supported")
            }

            var error: Unmanaged<CFError>?
            if let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) {
                return encryptedData as Data
            } else {
                if let error = error {
                    throw CustomError.encryptionError(errorDescription: error.takeRetainedValue().localizedDescription)
                } else {
                    throw CustomError.encryptionError(errorDescription: "Encryption failed")
                }
            }
    }
}
