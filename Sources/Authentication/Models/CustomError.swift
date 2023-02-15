//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation
public extension AuthenticationHandler {
    /// Mapped as much as possible all the errors in the project to these
     enum CustomError: Error, LocalizedError, Equatable {
        case decodingError
        case noResponse
        case invalidURL
        case invalidConfiguration
        case invalidData
        case dissmissLogin(error: String)
        case unexpectedStatusCode(_ code: Int)
        case internalError(_ msg: String)
        public var message: String {
            switch self {
            case .decodingError:
                return "Decoding Error"
            case .invalidURL:
                return "Invalid URL"
            case .invalidData:
                return "Invalid Data"
            case .noResponse:
                return "No Response"
            case .unexpectedStatusCode(let code):
                return "Unexpected Error with code: \(code)"
            case .internalError(let msg):
                return "Unexpected Error with code: \(msg)"
            case .dissmissLogin(let error):
                return "Dissmiss Login \(error)"
            case .invalidConfiguration:
                return "Invalid Configuration"
            }
        }
    }
}
