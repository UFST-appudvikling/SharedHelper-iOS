//
//  GalleryView.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 03/04/2023.
//

import SwiftUI
import SecurityHandler
import UIComponents

struct GalleryView: View {
    @State private var selectedImage: StoredDataModel? = nil
    @State private var newImage: StoredDataModel? = nil
    @StateObject var viewModel: FetchedObjectsViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isAuthenticated {
                    VStack {
                        if !viewModel.fetchedObjects.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    ForEach(viewModel.groupedImages.keys.sorted(by: >), id: \.self) { key in
                                        Section(header: Text(key)
                                            .font(.subheadline)
                                            .bold()
                                            .padding(.horizontal)) {
                                                items(key: key)
                                                    .padding()
                                            }
                                    }
                                }
                            }
                        } else {
                            Text("No images captured")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    }
                    .navigation(viewModel: viewModel)
                } else {
                    Text("Please authenticate to access the content.")
                    Button(action: {
                        viewModel.authenticate()
                    }) {
                        Text("Authenticate with Touch ID/Face ID")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedImage) { image in
            DetailView(viewModel: viewModel, selectedImage: image)
        }
        .sheet(item: $viewModel.lastImage) { image in
            DetailView(viewModel: viewModel, selectedImage: image)
        }
        
    }
    func items(key: String ) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
            ForEach(viewModel.groupedImages[key] ?? [], id: \.self) { storedDataModel in
                if let image = viewModel.decryptImage(data: storedDataModel.data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            selectedImage = storedDataModel
                        }
                }
            }
        }
    }
    
}


extension View {
    func navigation(viewModel: FetchedObjectsViewModel) -> some View {
        modifier(NavigationBar(viewModel: viewModel))
    }
}


struct NavigationBar: ViewModifier {
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var newImage: UIImage? = nil
    @ObservedObject var viewModel: FetchedObjectsViewModel

    func body(content: Content) -> some View {
        content
            .navigationBarTitle("Image Gallery")
            .navigationBarItems(leading: Button(action: {
                self.showingPhotoLibrary = true
            }) {
                Image(systemName: "photo.on.rectangle")
                    .font(.subheadline)
            }, trailing: Button(action: {
                self.showingCamera = true
            }) {
                Image(systemName: "camera.viewfinder")
                    .font(.subheadline)
            })
        
            .fullScreenCover(isPresented: $showingCamera, onDismiss: {
                if let imageData = newImage?.jpegData(compressionQuality: 0.1) {
                    viewModel.saveData(imageData: imageData)
                }
            }) {
                ImagePickerHandler(image: $newImage, sourceType: .camera)
            }
            
            .fullScreenCover(isPresented: $showingPhotoLibrary, onDismiss: {
                if let imageData = newImage?.jpegData(compressionQuality: 0.1) {
                    viewModel.saveData(imageData: imageData)
                }
            }) {
                ImagePickerHandler(image: $newImage, sourceType: nil)

            }
    }
}
