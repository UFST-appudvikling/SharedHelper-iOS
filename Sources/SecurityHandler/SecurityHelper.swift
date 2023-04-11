import Foundation
import Security

private let secClass = kSecClass as String
private let secAttrService = kSecAttrService as String
private let secAttrGeneric = kSecAttrGeneric as String
private let secAttrAccount = kSecAttrAccount as String
private let secMatchLimit = kSecMatchLimit as String
private let secReturnData = kSecReturnData as String
private let secValueData = kSecValueData as String
private let secAttrAccessible = kSecAttrAccessible as String

public class SecurityHelper {

    public
    static func search(matching identifier: String) -> Data? {
        var dictionary = setupSearchDirectory(for: identifier)
        
        // Limit search results to one
        dictionary[secMatchLimit] = kSecMatchLimitOne
        
        // Specify we want NSData/CFData returned
        dictionary[secReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(dictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    public static func string(matching identifier: String) -> String? {
        guard let data = self.search(matching: identifier) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    @discardableResult
    public static func create(value: String, forIdentifier identifier: String) -> Bool {
        var dictionary = setupSearchDirectory(for: identifier)
        
        let encodedValue = value.data(using: .utf8)
        dictionary[secValueData] = encodedValue
        
        // Protect the keychain entry so its only valid when the device is unlocked
        dictionary[secAttrAccessible] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        
        let status = SecItemAdd(dictionary as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecDuplicateItem:
            return self.update(value: value, forIdentifier: identifier)
        default:
            return false
        }
    }
    
    @discardableResult
    public static func update(value: String, forIdentifier identifier: String) -> Bool {
        let dictionary = setupSearchDirectory(for: identifier)
        
        let encodedValue = value.data(using: .utf8)
        let update = [secValueData: encodedValue]
        
        let status = SecItemUpdate(dictionary as CFDictionary, update as CFDictionary)
        
        return status == errSecSuccess
    }
    
    @discardableResult
    public static func remove(identifier: String) -> Bool {
        let dictionary = setupSearchDirectory(for: identifier)
        
        let status = SecItemDelete(dictionary as CFDictionary)
        return status == errSecSuccess
    }
    
    private static func setupSearchDirectory(for identifier: String) -> [String: Any] {
        // We are looking for passwords
        var searchDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
        
        // Identify our access
        searchDictionary[secAttrService] = Bundle.main.bundleIdentifier
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier = identifier.data(using: .utf8)
        searchDictionary[secAttrGeneric] = encodedIdentifier
        searchDictionary[secAttrAccount] = encodedIdentifier
        
        return searchDictionary
    }
}
