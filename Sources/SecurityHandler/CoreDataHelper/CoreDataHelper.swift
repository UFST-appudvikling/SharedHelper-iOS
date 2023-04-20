import Foundation
import CoreData
import UIKit


public struct CoreDataHelper {
//TODO: Error handling
//TODO: Tests
    public let container: NSPersistentContainer

    public init() {
        
        guard let modelURL = Bundle.module.url(forResource:"StoredDataModel", withExtension: "momd") else { fatalError() }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError() }
        container = NSPersistentContainer(name:"StoredDataModel" ,managedObjectModel:model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.deleteExpiredData(viewContext: container.viewContext)
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
    
    public static func deleteStoredDataModel(_ model: StoredDataModel, viewContext: NSManagedObjectContext) {
        do {
            viewContext.delete(model)
            try viewContext.save()
        } catch {
            print("Error fetching models: \(error)")
        }
    }
    public static func saveDataToCoreData(data: Data,
                                          viewContext: NSManagedObjectContext,
                                          symmetricKeyIdentifier: String,
                                          expiryDuration: TimeInterval) -> StoredDataModel? {
        CoreDataHelper.saveDataToCoreDataInternal(data: data,
                                                    viewContext: viewContext,
                                                    symmetricKeyIdentifier: symmetricKeyIdentifier,
                                                    expiryDuration: expiryDuration,
                                                    cryptoHelper: SecurityHandler.CryptoHelper.self)
    }
}

extension CoreDataHelper {
    static func saveDataToCoreDataInternal(data: Data,
                                             viewContext: NSManagedObjectContext,
                                             symmetricKeyIdentifier: String,
                                             expiryDuration: TimeInterval,
                                             cryptoHelper: StaticCryptoHelperProtocol.Type) -> StoredDataModel? {
        let capturedImage = StoredDataModel(context: viewContext)
        
        do {
            let encryptedData = try cryptoHelper.encryptData(data, symmetricKeyIdentifier: symmetricKeyIdentifier)
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
    
    static func saveDataToCoreDataForTesting(data: Data,
                                             viewContext: NSManagedObjectContext,
                                             symmetricKeyIdentifier: String,
                                             expiryDuration: TimeInterval,
                                             cryptoHelper: StaticCryptoHelperProtocol.Type) -> StoredDataModel? {
        return saveDataToCoreDataInternal(data: data,
                                          viewContext: viewContext,
                                          symmetricKeyIdentifier: symmetricKeyIdentifier,
                                          expiryDuration: expiryDuration,
                                          cryptoHelper: cryptoHelper)
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
}

