//
//  GalleryViewModel.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 05/04/2023.
//

import Foundation
import CoreData
import Combine
import SecurityHandler
import UIKit
class FetchedObjectsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    @Published var fetchedObjects: [StoredDataModel] = []
    @Published var lastImage: StoredDataModel?

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchedObjects = CoreDataHelper.fetch(viewContext: context)
        super.init()
    }

    var groupedImages: [String: [StoredDataModel]] {
        Dictionary(grouping: fetchedObjects, by: { $0.formattedDateOfData })
    }
    func saveData(imageData: Data)  {
        if let savedImage = CoreDataHelper.saveDataToCoreData(data: imageData, viewContext: viewContext, symmetricKeyIdentifier: "dk.ufst.CameraGalleryApp.symmetricKey", expiryDuration: 60 * 60 * 24 * 7) {
            lastImage = savedImage
            fetchedObjects = CoreDataHelper.fetch(viewContext: viewContext)
        }

    }
    func deletImage(image: StoredDataModel) {
        CoreDataHelper.deleteStoredDataModel(image, viewContext: viewContext)
        fetchedObjects = CoreDataHelper.fetch(viewContext: viewContext)

    }

    func decryptData(data: Data?) -> Data? {
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
    func decryptImage(data: Data?) -> UIImage? {
        if let decryptedData = self.decryptData(data: data) {
            return UIImage(data: decryptedData)
        } else {
            return nil
        }
    }

 }
