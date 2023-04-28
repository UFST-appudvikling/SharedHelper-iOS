import Foundation
import CryptoKit
import Security


public extension SecurityHandler {
    /// Documentaion
    /// The CryptoHelper is a way to encrypt and decrypt data.
    /// It has two main functions encryptData and decryptData.
    /// The public methods are:
    /// 1. encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data
    /// Parameters:
    /// data: The data to be encrypted.
    /// symmetricKeyIdentifier: The identifier to be used to uniquely identify the symmetric key in the Keychain.
    /// Returns: The encrypted data.
    /// Throws: An error of type CustomError.
    /// 2. decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data
    /// Parameters:
    /// encryptedData: The data to be decrypted.
    /// symmetricKeyIdentifier: The identifier to be used to uniquely identify the symmetric key in the Keychain.
    /// Returns: The decrypted data.
    /// Throws: An error of type CustomError.
    class CryptoHelper: CryptoHelperProtocol {
        public static func encryptData(_ data: Data,
                                       symmetricKeyIdentifier: String) throws -> Data {
            try encryptDataInternal(data, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: SecurityHandler.KeychainHelper.self )
        }
        static func encryptDataTest(_ data: Data,
                                    symmetricKeyIdentifier: String,
                                    keychain: KeychainHelperProtocol.Type) throws -> Data {
            try encryptDataInternal(data, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain:keychain )
        }
        private static func encryptDataInternal(_ data: Data,
                                                symmetricKeyIdentifier: String,
                                                keychain: KeychainHelperProtocol.Type) throws -> Data {
            let sealedBox = try AES.GCM.seal(data, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain))
            guard let combined = sealedBox.combined else { throw CustomError.encryptionError(errorDescription: "Error: sealedBox.combined didnt work")}
            return combined
        }
        
        public static func decryptData(_ encryptedData: Data,
                                       symmetricKeyIdentifier: String) throws -> Data {
            try decryptDataInternal(encryptedData, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: SecurityHandler.KeychainHelper.self)
        }
        static func decryptDataTest(_ encryptedData: Data,
                                    symmetricKeyIdentifier: String,
                                    keychain: KeychainHelperProtocol.Type) throws -> Data {
            try decryptDataInternal(encryptedData, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        }
        private static func decryptDataInternal(_ encryptedData: Data,
                                                symmetricKeyIdentifier: String,
                                                keychain: KeychainHelperProtocol.Type) throws -> Data {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: CryptoHelper.getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain))
            return decryptedData
        }
        public static func getEncryptedKeyByUsingRSAPublicKey(publicKeyData:Data? = nil,
                                                              symmetricKeyIdentifier: String) throws -> Data {
            try getEncryptedKeyByUsingRSAPublicKeyInternal(publicKeyData: publicKeyData, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain:  SecurityHandler.KeychainHelper.self)
        }
        static func getEncryptedKeyByUsingRSAPublicKeyTest(publicKeyData:Data? = nil,
                                                           symmetricKeyIdentifier: String,
                                                           keychain: KeychainHelperProtocol.Type) throws -> Data {
            try getEncryptedKeyByUsingRSAPublicKeyInternal(publicKeyData: publicKeyData, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        }
        private static func getEncryptedKeyByUsingRSAPublicKeyInternal(publicKeyData:Data? = nil,
                                                                       symmetricKeyIdentifier: String,
                                                                       keychain: KeychainHelperProtocol.Type) throws -> Data {
            try getSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
            let rsaKey = try CryptoHelper.rsaPublicKeyFromPEM(derKey: publicKeyData)
            let aesKeyData = try CryptoHelper.loadSymmetricKeyData(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
            //TODO: use rsaEncryptionOAEPSHA256 in algorithm instead.
            return try CryptoHelper.encryptKeyData(data: aesKeyData, publicKey: rsaKey)
        }
        
    }
}

extension SecurityHandler.CryptoHelper {
    /// Documentaion
    /// The getSymmetricKey is a way to get the symmetric key from the Keychain.
    /// It use the SecurityHandler.KeychainHelper to get the symmetric key from the Keychain.
    @discardableResult
    static func getSymmetricKey(symmetricKeyIdentifier: String,
                                keychain: KeychainHelperProtocol.Type) throws -> SymmetricKey {
        do {
            return try SecurityHandler.CryptoHelper.loadSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        } catch {
            return try SecurityHandler.CryptoHelper.generateAndStoreSymmetricKey(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        }
    }
    private static func storeSymmetricKey(_ key: SymmetricKey,
                                          symmetricKeyIdentifier: String,
                                          keychain: KeychainHelperProtocol.Type) throws {
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
        if !keychain.create(cfDictionary: query as CFDictionary) {
            throw SecurityHandler.CustomError.keychainError(errorDescription: "Not able to create/update")
        }
    }

    private static func loadSymmetricKey(symmetricKeyIdentifier: String,
                                         keychain: KeychainHelperProtocol.Type) throws -> SymmetricKey {
        let keyData = try loadSymmetricKeyData(symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        return SymmetricKey(data: keyData)
    }
        
    private static func loadSymmetricKeyData(symmetricKeyIdentifier: String,
                                             keychain: KeychainHelperProtocol.Type) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: symmetricKeyIdentifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        if let keyData = keychain.search(matching: query as CFDictionary) {
            return keyData
        } else {
            throw SecurityHandler.CustomError.invalidData
        }
    }


    private static func generateAndStoreSymmetricKey(symmetricKeyIdentifier: String,
                                                     keychain: KeychainHelperProtocol.Type) throws -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        try storeSymmetricKey(key, symmetricKeyIdentifier: symmetricKeyIdentifier, keychain: keychain)
        return key
    }
    
    private static func loadRSAPublicKey() throws -> Data {
        let resourceFileName = "key"
        
        guard let fileURL = Bundle.module.url(forResource: resourceFileName, withExtension: nil) else {
            throw SecurityHandler.CustomError.resourceError(errorDescription: "Error: Resource file not found")
        }
        
        do {
            let keyData = try Data(contentsOf: fileURL)
            return keyData
        } catch {
            throw SecurityHandler.CustomError.invalidData
        }
    }
    private static func rsaPublicKeyFromPEM(derKey: Data?) throws -> SecKey {
        let derKey = try loadRSAPublicKey()
        let base64Key = derKey.base64EncodedString()
        
        guard let base64Data = Data(base64Encoded: base64Key) else {
            throw SecurityHandler.CustomError.invalidData
        }
        
        let options: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(base64Data as CFData, options as CFDictionary, &error) else {
            throw SecurityHandler.CustomError.unknownError(errorDescription: (String(describing: error)))
        }
        
        return key
    }
    
    private static func encryptKeyData(algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1, data: Data, publicKey: SecKey) throws -> Data {
        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
            
            guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
                throw SecurityHandler.CustomError.algorithmError(errorDescription: "Algorithm not supported")
            }

            var error: Unmanaged<CFError>?
            if let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) {
                return encryptedData as Data
            } else {
                if let error = error {
                    throw SecurityHandler.CustomError.encryptionError(errorDescription: error.takeRetainedValue().localizedDescription)
                } else {
                    throw SecurityHandler.CustomError.encryptionError(errorDescription: "Encryption failed")
                }
            }
    }
}
