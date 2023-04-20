//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 21/09/2022.
//

import Foundation
import SecurityHandler

extension AuthenticationHandler {
    private enum KeychainIdentifiers {
        static let tokenIdentifier = "TokenIdentifier"
    }

    final class KeychainHelper: NSObject {
        static func retrieveToken() -> TokenModel? {
            guard let wrappedToken = SecurityHandler.string(matching: KeychainIdentifiers.tokenIdentifier) else { return nil }
            return AuthenticationHandler.unwrap(wrappedToken: wrappedToken)
        }

        static func storeToken(_ token: TokenModel) {
            SecurityHandler.create(value: token.wrap, forIdentifier: KeychainIdentifiers.tokenIdentifier)
        }

        static func invalidateToken() {
            SecurityHandler.remove(identifier: KeychainIdentifiers.tokenIdentifier)
        }
    }
}
