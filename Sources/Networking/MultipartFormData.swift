//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 14/04/2023.
//

import Foundation
public extension Networking {
    struct MultipartFormData {
        
        let boundary: String = UUID().uuidString
        private(set) var httpBody = Data()
        
        public init() {}
        public mutating func addJson(named name: String, value: String) {
            httpBody.addField("--\(boundary)")
            httpBody.addField("Content-Disposition: form-data; name=\"\(name)\"")
            httpBody.addField("Content-Type: application/json")
            httpBody.addField("Content-Transfer-Encoding: binary")
            httpBody.addField("")
            httpBody.addField(value)
        }
        
        public mutating func addField(named name: String, filename: String, data: Data) {
            httpBody.addField("--\(boundary)")
            httpBody.addField("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"")
            httpBody.addField("Content-Type: application/octet-stream")
            httpBody.addField("Content-Transfer-Encoding: binary")
            httpBody.addField("")
            httpBody.addField(data)
        }
    }
}
extension URLRequest {
    init(url: URL, timeoutInterval: TimeInterval = 60, multipartFormData: Networking.MultipartFormData) {
        self.init(url: url, timeoutInterval: timeoutInterval)
        let boundary = multipartFormData.boundary
        httpMethod = "POST"
        allHTTPHeaderFields = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        var body = multipartFormData.httpBody
        body.append("--\(boundary)--")
        httpBody = body
    }
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        append(data)
    }

    mutating func addField(_ string: String) {
        append(string)
        append(.httpFieldDelimiter)
    }

    mutating func addField(_ data: Data) {
        append(data)
        append(.httpFieldDelimiter)
    }
}

fileprivate extension String {
    static let httpFieldDelimiter = "\r\n"
}
