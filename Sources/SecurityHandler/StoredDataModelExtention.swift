//
//  CapturedImageExtention.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 04/04/2023.
//

import Foundation
import UIKit

extension StoredDataModel {
    // One week in seconds
    private static let expiryDuration: TimeInterval = 60 * 60 * 24 * 7

    public var decryptData: Data? {
        get {
            do {
                if let data = data {
                    return try SecurityHelper.CryptoHelper.decryptData(data, symmetricKeyIdentifier: "dk.ufst.CameraGalleryApp.symmetricKey")
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
    public var decryptImage: UIImage? {
        get {
            if let data = self.decryptData {
                return UIImage(data: data)
            } else {
                return nil
            }
        }
    }
    public var dayOfImage: String {
        get {
            if let creationDate = date {
                return getFormattedDate(from: creationDate)
            } else {
                return "Untitle"
            }
        }
    }
    
    public var expirationDay: String {
        get {
            if let creationDate = date {
                return getFormattedDate(from: creationDate.addingTimeInterval(StoredDataModel.expiryDuration))
            } else {
                return "Never Expires"
            }
        }
    }
    
    public var isExpired: Bool {
        get {
            if let creationDate = date, Date().timeIntervalSince(creationDate) > StoredDataModel.expiryDuration {
                return true
            } else {
                return false
            }
                
        }
    }
    
    private func getFormattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    
}
