//
//  File.swift
//  
//
//  Created by Nicolai Dam on 03/06/2023.
//

import Foundation
import CommonCrypto

/// Interface
struct PKCEClient {
    /// Generating a code verifier for PKCE
    var generateCodeVerifier: () -> String?
    /// Generating a code challenge for PKCE
    var generateCodeChallenge: (_ codeVerifier: String?) -> String?
}

extension PKCEClient {
    
    /// Live implementation
    static let live = Self(
        generateCodeVerifier: {
            var buffer = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
            let codeVerifier = Data(buffer).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            return codeVerifier
        },
        generateCodeChallenge: { codeVerifier in
            guard let verifier = codeVerifier, let data = verifier.data(using: .utf8) else { return nil }
            
            var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
            }
            let hash = Data(buffer)
            
            let challenge = hash.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
                .trimmingCharacters(in: .whitespaces)
            return challenge
        }
    )
}

