import Foundation
import CoreData
import UIKit
   
public struct CoreDataHelper {

    public let container: NSPersistentContainer

    public init(name: String) {
        
        guard let modelURL = Bundle.module.url(forResource:name, withExtension: "momd") else { fatalError() }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError() }
        container = NSPersistentContainer(name:name,managedObjectModel:model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.deleteExpiredData(viewContext: container.viewContext)
    }
 
    private func deleteExpiredData(viewContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<StoredDataModel> = StoredDataModel.fetchRequest()
        
        do {
            let fetchedData = try viewContext.fetch(fetchRequest)
            for data in fetchedData {
                if data.isExpired {
                    viewContext.delete(data)
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
    
    public static func deleteStoredDataModel(_ image: StoredDataModel, viewContext: NSManagedObjectContext) {
        do {
            viewContext.delete(image)
            try viewContext.save()
        } catch {
            print("Error fetching images: \(error)")
        }
    }
    public static func saveDataToCoreData(data: Data,
                                          viewContext: NSManagedObjectContext,
                                          symmetricKeyIdentifier: String,
                                          expiryDuration: TimeInterval) -> StoredDataModel? {
        let capturedImage = StoredDataModel(context: viewContext)
        
        do {
            let encryptedData = try SecurityHelper.CryptoHelper.encryptData(data, symmetricKeyIdentifier: symmetricKeyIdentifier)
            capturedImage.data = encryptedData
            capturedImage.date = Date()
            capturedImage.expirationDuration = expiryDuration
            try viewContext.save()
            return capturedImage
        } catch {
            print("Error saving image to Core Data: \(error)")
            return nil
        }
    }
}


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
