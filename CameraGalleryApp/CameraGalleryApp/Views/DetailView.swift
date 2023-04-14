//
//  ImageDetailView.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 04/04/2023.
//

import SwiftUI
import SecurityHandler
struct DetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FetchedObjectsViewModel

    @State private var showingDeletionAlert = false
    var selectedImage: StoredDataModel

    var body: some View {
        
        NavigationView {
            VStack {
                Text("Expires in: " + selectedImage.expirationDay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                Spacer()
                
                if let imageToShow = viewModel.decryptImage(data: selectedImage.data) {
                    Image(uiImage: imageToShow)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                    
                    Spacer()
                }
                
                Button(action: {
                    // Action to send data to the server
                    Task {
                        try await viewModel.sendData(model: selectedImage)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 20))
                        
                        Text("Send Data")
                            .font(.system(size: 20))
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2)
                    )
                }
                .padding()
            }
            .navigationBarTitle(selectedImage.formattedDateOfData)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: deletButton,
                trailing: closeButton
            )
            .alert(isPresented: $showingDeletionAlert) {
                Alert(
                    title: Text("Delete Image"),
                    message: Text("Are you sure you want to delete this image?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deletImage(image: selectedImage)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    var deletButton: some View {
        HStack{
            Button(
                action: {
                    showingDeletionAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.subheadline)
                }
            Spacer()
            if let dataToBeShared = viewModel.decryptData(data: selectedImage.data) {
                ShareLink(
                    item: dataToBeShared,
                    preview: SharePreview(
                        selectedImage.formattedDateOfData,
                        image: Image(systemName: "square.and.arrow.up")
                    )
                )
            }
            
        }
    }
    var closeButton: some View {
        Button(
            action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .font(.subheadline)
            }
    }
    
}
