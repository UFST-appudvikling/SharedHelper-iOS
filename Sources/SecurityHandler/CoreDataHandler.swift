//
//  CoreDataHandler.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 04/04/2023.
//

import Foundation
import CoreData
import UIKit

public struct CoreDataHandler {

    public let container: NSPersistentContainer

    public init(name: String) {
        container = NSPersistentContainer(name: name)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    public static func deleteExpiredData(viewContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<StoredDataModel> = StoredDataModel.fetchRequest()
        
        do {
            let fetchedImages = try viewContext.fetch(fetchRequest)
            for image in fetchedImages {
                if image.isExpired {
                    viewContext.delete(image)
                }
            }
            try viewContext.save()
        } catch {
            print("Error fetching images: \(error)")
        }
    }
    
    public static func fetch(viewContext: NSManagedObjectContext) -> [StoredDataModel] {
        let fetchRequest: NSFetchRequest<StoredDataModel> = StoredDataModel.fetchRequest()
        
        do {
            let fetchedImages = try viewContext.fetch(fetchRequest)
            return fetchedImages
        } catch {
            print("Error fetching images: \(error)")
            return []
        }
    }
    
    public static func deleteImage(_ image: StoredDataModel, viewContext: NSManagedObjectContext) {
        do {
            viewContext.delete(image)
            try viewContext.save()
        } catch {
            print("Error fetching images: \(error)")
        }
    }
    public static func saveDataToCoreData(data: Data, viewContext: NSManagedObjectContext) -> StoredDataModel? {
        let capturedImage = StoredDataModel(context: viewContext)
        
        do {
            let encryptedData = try SecurityHelper.CryptoHelper.encryptData(data, symmetricKeyIdentifier: "dk.ufst.CameraGalleryApp.symmetricKey")
            capturedImage.data = encryptedData
            capturedImage.date = Date()
            try viewContext.save()
            return capturedImage
        } catch {
            print("Error saving image to Core Data: \(error)")
            return nil
        }
    }
}
