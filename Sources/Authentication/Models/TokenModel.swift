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
        var refreshExpiresIn: Int?
        var refreshToken: String
        
        public var tokenType: String
        var idToken: String?
        public var sessionState: String?
        public var scope: String
        static let keychainValueSeparator: String = "\t"
        static let tokenSeparator: String = "&"
        
        func expiresAt(now: Date) -> Date {
            return now.addingTimeInterval(TimeInterval(expiresIn))
        }
        func refreshExpiresAt(now: Date) -> Date {
            return now.addingTimeInterval(TimeInterval(refreshExpiresIn ?? 0))
        }
        func wrap(now: Date) -> String {
            let seperator = TokenModel.keychainValueSeparator
            return "\(accessToken)\(seperator)\(refreshToken)\(seperator)\(tokenType)\(seperator)\(expiresAt(now: now).timeIntervalSince1970)\(seperator)\(refreshExpiresAt(now: now).timeIntervalSince1970)"
        }
        func accessTokenIsValid(now: Date) -> Bool {
            now.second(to: expiresAt(now: now)) > 1
        }
        func refreshTokenIsValid(now: Date) -> Bool {
            now.second(to: refreshExpiresAt(now: now)) > 1
        }
    }
}
internal extension AuthenticationHandler {
    // MARK: - Functions
    func unwrap(wrappedToken: String, now: Date) -> TokenModel? {
        let tokenComponents = wrappedToken.components(separatedBy: TokenModel.keychainValueSeparator)
        var accessToken: String?
        var refreshToken: String?
        var expirationDate: Date?
        var refreshExpirationDate: Date?
        var type: String?
        
        accessToken = tokenComponents[0]
        refreshToken = tokenComponents[1]
        type = tokenComponents[2]
        expirationDate = Date(timeIntervalSince1970: TimeInterval(Double(tokenComponents[3]) ?? 0.0))
        refreshExpirationDate = Date(timeIntervalSince1970: TimeInterval(Double(tokenComponents[4]) ?? 0.0))
        
        guard
            let accToken = accessToken,
            let refrToken = refreshToken,
            let expiresDate = expirationDate,
            let refreshExpiresDate = refreshExpirationDate,
            let tokenType = type,
            let expiresIn = Calendar.current.dateComponents(
                [.second],
                from: now,
                to: expiresDate).second,
            let refreshExpiresIn = Calendar.current.dateComponents(
                [.second],
                from: now,
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

extension AuthenticationHandler.TokenModel: Equatable {
    
    public static func == (lhs: AuthenticationHandler.TokenModel, rhs: AuthenticationHandler.TokenModel) -> Bool {
        if lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.tokenType == rhs.tokenType
            && lhs.expiresIn == rhs.expiresIn
            && lhs.refreshExpiresIn == rhs.refreshExpiresIn
        {
            return true
        }
        return false
    }
}
