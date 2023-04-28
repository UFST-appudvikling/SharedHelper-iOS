//
//  ImagePicker.swift
//  CameraGalleryApp
//
//  Created by Emad Ghorbaninia on 03/04/2023.
//
import PhotosUI
import SwiftUI
// This is the view that will be presented when the user taps the "Add Image" button.
// It will present either the camera or the photo library, depending on the user's
// device.
// The user can then select an image, which will be saved to Core Data and displayed
// in the main view.
// The user can also cancel the operation, which will dismiss the view.
// The view is presented using a sheet, which is why it conforms to View.
// It also conforms to UIViewControllerRepresentable, which allows it to present
// the UIImagePickerController.

public struct ImagePickerHandler: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding public var image: UIImage?
    public var sourceType: UIImagePickerController.SourceType? = nil
    public init(image: Binding<UIImage?>, sourceType: UIImagePickerController.SourceType?) {
        self._image = image
        self.sourceType = sourceType
    }
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerHandler>) -> UIViewController {
        if let type = sourceType, type == .camera {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = type
            picker.cameraCaptureMode = .photo
            return picker
        } else {
            var config = PHPickerConfiguration()
            config.filter = .images
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }


    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ImagePickerHandler>) { }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        public let parent: ImagePickerHandler

        public init(_ parent: ImagePickerHandler) {
            self.parent = parent
        }

        // UIImagePickerControllerDelegate methods
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.image = info[.originalImage] as? UIImage
                self?.parent.dismiss()

            }
        }
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
            self.parent.dismiss()
        }
        // PHPickerViewControllerDelegate methods
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            if !results.isEmpty,
               let itemProvider = results.first?.itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                itemProvider.loadObject(ofClass: UIImage.self) {  [weak self] (image, error) in
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.image = image as? UIImage
                        self?.parent.dismiss()
                    }
                }
            } else {
                self.parent.dismiss()
                return
            }
            
        }
    }
}
