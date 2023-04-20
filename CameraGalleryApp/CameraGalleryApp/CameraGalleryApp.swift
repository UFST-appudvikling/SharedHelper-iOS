//
//  CameraGalleryAppApp.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 03/04/2023.
//

import SwiftUI
import Foundation
import SecurityHandler

@main
struct CameraGalleryApp: App {
    let persistenceController = CoreDataHelper(name: "StoredDataModel")

    var body: some Scene {
        WindowGroup {
            GalleryView(viewModel: FetchedObjectsViewModel(context: persistenceController.container.viewContext))
        }
    }
    
}



