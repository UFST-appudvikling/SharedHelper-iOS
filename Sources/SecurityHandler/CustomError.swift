//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 14/04/2023.
//

import Foundation
public extension SecurityHelper.CryptoHelper {
    /// Mapped as much as possible all the errors in the project to these
    enum CustomError: Error, LocalizedError, Equatable {
        case encryptionError(errorDescription: String)
        case keychainError(errorDescription: String)
        case resourceError(errorDescription: String)
        case encondingError(errorDescription: String)
        case algorithmError(errorDescription: String)
        case invalidData
        case unknownError(errorDescription: String)
    }
}
