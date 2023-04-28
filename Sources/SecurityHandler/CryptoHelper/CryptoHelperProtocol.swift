//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation
/// Documentaion
/// The CryptoHelperProtocol is a Protocol for CryptoHelper.
/// It's been design to be used in CryptoHelper.swift and not being exposed to the public.
protocol CryptoHelperProtocol {
    static func encryptData(_ data: Data, symmetricKeyIdentifier: String) throws -> Data
    static func decryptData(_ encryptedData: Data, symmetricKeyIdentifier: String) throws -> Data
}
