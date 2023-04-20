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
import Networking
import LocalAuthentication

class FetchedObjectsViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    private let networking: Networking
    @Published var fetchedObjects: [StoredDataModel] = []
    @Published var lastImage: StoredDataModel?
    @Published var isAuthenticated = false

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchedObjects = CoreDataHelper.fetch(viewContext: context)
        networking = Networking()
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
                return try SecurityHandler.CryptoHelper.decryptData(data, symmetricKeyIdentifier: "dk.ufst.CameraGalleryApp.symmetricKey")
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
    
    func sendData(model: StoredDataModel) async throws {
        if let encryptedData = model.data {
            guard let url = URL(string: "http://10.200.29.142:8080/submit"),
                  let documentModelString = createJsonString(model: model)
            else { return }
            var multipartForm = Networking.MultipartFormData()
            multipartForm.addJson(named: "document", value: documentModelString)
            multipartForm.addField(named: "key",
                                   filename: "\(String(UInt(bitPattern: model.id))).key",
                                   data: try SecurityHandler.CryptoHelper.getEncryptedKeyByUsingRSAPublicKey(symmetricKeyIdentifier: "dk.ufst.CameraGalleryApp.symmetricKey"))
            multipartForm.addField(named: "data",
                                   filename: "\(String(UInt(bitPattern: model.id))).dat",
                                   data: encryptedData)
            
            if let response: String = try await networking.uploadMultipartFile(multipartForm: multipartForm, url: url) {
                print(response)
            }
        }
    }
    struct Document: Codable {
        public var id: String
        public var created: String
        public var attempts: Int?
    }
    
    func createJsonString(model: StoredDataModel) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let created = formatter.string(from: model.date ?? Date())
        let document = Document(id: String(UInt(bitPattern: model.id)) , created: created, attempts: 1)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(document)
            
            // Convert JSON data to string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Error converting JSON data to string")
                return nil
            }
        } catch {
            print("Error encoding JSON: \(error)")
            return nil
        }
    }
    
        
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the content"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        // Handle the authentication error
                        print("Authentication failed")
                    }
                }
            }
        } else {
            // Device does not support biometrics authentication
            print("Device does not support biometrics authentication")
        }
    }
 }
