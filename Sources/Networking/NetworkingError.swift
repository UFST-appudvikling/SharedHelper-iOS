//
//  NetworkingError.swift
//  
//
//  Created by Emad Ghorbania on 10/06/2022.
//

import Foundation

public enum NetworkingError: Error, LocalizedError, Equatable {
    case decodingError
    case invalidURL
    case noResponse
    case unknown
    case noInternet
    case invalidData
    case mockedError
    case mockedSuccess
    case unauthorized(_ code: Int)
    case forbidden
    case unexpectedStatusCode(_ code: Int)
    case backendError(_ code: Int)
    case requestFailed(_ description: String)
    case urlError(_ code: Int, _ description: String? = nil)
    case encodingError(_ description: String)
    case clientEntityError(data: Data, code: Int)
    
    // MARK: - The idea is that wherever possible, we will make the message and title into a phrase key so where we display the errors (on alert for example) we will do the .localized() and if they phrase key exists, we display the translated text, otherwise we just return the error itself.
    public var message: String {
        switch self {
        case .decodingError, .invalidURL, .noResponse, .unauthorized, .forbidden, .unknown, .noInternet, .invalidData:
            return "networkErrorMessage.\(self)"
        case .mockedError:
            return "This is a mocked error"
        case .mockedSuccess:
            return "This is a mocked success"
        case .urlError(let code, let description):
            return "URLError Description: \(description ?? "No Description") || Code: \(code)"
        case .unexpectedStatusCode(let code):
            return "Unexpected Error with code: \(code)"
        case .requestFailed(let description):
            return "Request Failed error -> \(description)"
        case .encodingError(let description):
            return "JSON Conversion Failure -> \(description)"
        case .backendError(let code):
            return "Backend Error with code: \(code)"
        case .clientEntityError(data: _, code: let code):
            return "known error with code: \(code)"
        }
    }
    
    public var title: String {
        switch self {
        case .decodingError, .invalidURL, .noResponse, .unauthorized, .forbidden, .unknown,
                .noInternet, .invalidData, .requestFailed, .urlError, .backendError,
                .unexpectedStatusCode, .encodingError, .clientEntityError:
            return "networkErrorTitle.\(self)"
        case .mockedError:
            return "Mock Error"
        case .mockedSuccess:
            return "Mock Success"
        }
    }
}
