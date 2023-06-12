import Foundation
import CoreData
import UIKit


extension SecurityHandler {
    /// Documentaion
    /// The CoreDataHelper is a wrapper for CoreData.
    /// You should use this class to save, fetch and delete data from CoreData.
    /// It has some public and some private methods. The public methods are the ones that you will use in your code.
    /// The private methods are there to help the public methods.
    /// The public methods are:
    /// 1. saveDataToCoreData(data: Data, viewContext: NSManagedObjectContext, symmetricKeyIdentifier: String, expiryDate: Date) throws -> StoredDataModel
    /// Parameters:
    /// data: The data to be saved in CoreData.
    /// viewContext: The viewContext to be used to save the data in CoreData.
    /// symmetricKeyIdentifier: The identifier to be used to uniquely identify the data in CoreData.
    /// expiryDate: The expiryDate to be used to uniquely identify the data in CoreData.
    /// Returns: A StoredDataModel object that contains the data that was saved in CoreData.
    /// Throws: An error of type CoreDataError if the data could not be saved in CoreData.
    ///
    /// 2. fetch(viewContext: NSManagedObjectContext) -> [StoredDataModel]
    /// Parameters:
    /// viewContext: The viewContext to be used to fetch the data from CoreData.
    /// Returns: An array of StoredDataModel objects that contains the data that was fetched from CoreData.
    /// 
    /// 3. deleteStoredDataModel(_ model: StoredDataModel, viewContext: NSManagedObjectContext) throws
    /// Parameters:
    /// model: The StoredDataModel model to be used to delete the data from CoreData.
    /// viewContext: The viewContext to be used to delete the data from CoreData.
    /// Throws: An error of type CoreDataError if the data could not be deleted from CoreData.
    public struct CoreDataHelper {
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
        
        public static func deleteStoredDataModel(_ model: StoredDataModel, viewContext: NSManagedObjectContext) throws {
            viewContext.delete(model)
            try viewContext.save()
        }
        public static func saveDataToCoreData(data: Data,
                                          viewContext: NSManagedObjectContext,
                                          symmetricKeyIdentifier: String,
                                          expiryDuration: TimeInterval) throws -> StoredDataModel {
        try SecurityHandler.CoreDataHelper.saveDataToCoreDataPrivate(data: data,
                                                      viewContext: viewContext,
                                                      symmetricKeyIdentifier: symmetricKeyIdentifier,
                                                      expiryDuration: expiryDuration,
                                                      cryptoHelper: SecurityHandler.CryptoHelper.self)
        }
    }
}

extension SecurityHandler.CoreDataHelper {
    
    static func saveDataToCoreDataForTesting(data: Data,
                                             viewContext: NSManagedObjectContext,
                                             symmetricKeyIdentifier: String,
                                             expiryDuration: TimeInterval,
                                             cryptoHelper: CryptoHelperProtocol.Type) throws -> StoredDataModel {
        return try saveDataToCoreDataPrivate(data: data,
                                              viewContext: viewContext,
                                              symmetricKeyIdentifier: symmetricKeyIdentifier,
                                              expiryDuration: expiryDuration,
                                              cryptoHelper: cryptoHelper)
    }
    private static func saveDataToCoreDataPrivate(data: Data,
                                                   viewContext: NSManagedObjectContext,
                                                   symmetricKeyIdentifier: String,
                                                   expiryDuration: TimeInterval,
                                                   cryptoHelper: CryptoHelperProtocol.Type) throws -> StoredDataModel {
        let capturedImage = StoredDataModel(context: viewContext)
        
        let encryptedData = try cryptoHelper.encryptData(data, symmetricKeyIdentifier: symmetricKeyIdentifier)
        capturedImage.data = encryptedData
        capturedImage.date = Date()
        capturedImage.expirationDuration = expiryDuration
        try viewContext.save()
        return capturedImage
    }
    
    private func deleteExpiredData(viewContext: NSManagedObjectContext)  {
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

