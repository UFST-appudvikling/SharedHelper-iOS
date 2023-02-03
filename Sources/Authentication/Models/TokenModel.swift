//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation
public extension AuthenticationHandler {
    /// This is a Model that you expect from the package, some of the variables are optional but the AccessToken are there always.
    struct TokenModel: Codable {
        public var accessToken: String
        var expiresIn: Int
        var refreshExpiresIn: Int
        var refreshToken: String
        public var tokenType: String
        var idToken: String?
        public var sessionState: String?
        public var scope: String
        var expiresAt: Date {
            return Date().addingTimeInterval(TimeInterval(expiresIn))
        }
        var refreshExpiresAt: Date {
            return Date().addingTimeInterval(TimeInterval(refreshExpiresIn))
        }
        var wrap: String {
            let seperator = TokenModel.keychainValueSeparator
            return "\(accessToken)\(seperator)\(refreshToken)\(seperator)\(tokenType)\(seperator)\(expiresAt.timeIntervalSince1970)\(seperator)\(refreshExpiresAt.timeIntervalSince1970)"
        }
        static let keychainValueSeparator: String = "\t"
        static let tokenSeparator: String = "&"
        
        var accessTokenIsValid: Bool {
            Date().second(to: expiresAt) > 1
        }
        var refreshTokenIsValid: Bool {
            Date().second(to: refreshExpiresAt) > 1
        }
    }
}
internal extension AuthenticationHandler {
    // MARK: - Static Functions
    static func unwrap(wrappedToken: String) -> TokenModel? {
        let tokenComponents = wrappedToken.components(separatedBy: TokenModel.keychainValueSeparator)
        var accessToken: String?
        var refreshToken: String?
        var expirationDate: Date?
        var refreshExpirationDate: Date?
        var type: String?
        
        if tokenComponents.count > 4 {
            accessToken = tokenComponents[0]
            refreshToken = tokenComponents[1]
            type = tokenComponents[2]
            expirationDate = Date(timeIntervalSince1970: TimeInterval(Double(tokenComponents[3]) ?? 0.0))
            refreshExpirationDate = Date(timeIntervalSince1970: TimeInterval(Double(tokenComponents[4]) ?? 0.0))
        }
        
    
        guard
            let accToken = accessToken,
            let refrToken = refreshToken,
            let expiresDate = expirationDate,
            let refreshExpiresDate = refreshExpirationDate,
            let tokenType = type,
            let expiresIn = Calendar.current.dateComponents(
                [.second],
                from: Date(),
                to: expiresDate).second,
            let refreshExpiresIn = Calendar.current.dateComponents(
                [.second],
                from: Date(),
                to: refreshExpiresDate).second
        else {
            return nil
        }
        return TokenModel(accessToken: accToken, expiresIn: expiresIn, refreshExpiresIn: refreshExpiresIn, refreshToken: refrToken, tokenType: tokenType, scope: "")
    }
}

private extension Date {
    func second(to date: Date) -> Int {
        let diffComponents = Calendar(identifier: .gregorian).dateComponents([.second], from: self, to: date)
        let second = diffComponents.second
        return (second ?? 0) + 1
    }
}

extension AuthenticationHandler {
    public enum TokenSource {
        case loginSheet
        case keychain
        case refresh
        case automatedLogin
    }
}
