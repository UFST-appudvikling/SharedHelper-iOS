//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation
/// Documentaion
/// This is an extension for StoredDataModel.
/// It has some computed properties for formatting the date and checking the expiration date.
extension StoredDataModel {

    public var formattedDateOfData: String {
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
                return getFormattedDate(from: creationDate.addingTimeInterval(expirationDuration))
            } else {
                return "Never Expires"
            }
        }
    }
    
    public var isExpired: Bool {
        get {
            if let creationDate = date, Date().timeIntervalSince(creationDate) > expirationDuration {
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
