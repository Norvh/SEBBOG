//
//  Camer.swift
//  Sebouq
//
//  Created by roaa on 25/07/1445 AH.
//

import SwiftUI
import AVFoundation
import CoreML
import Vision

struct Camera1: View {
    @State private var isSheetPresented = false
    @State private var capturedImage: UIImage?
    @State private var classificationResult: String?
    @State private var isImageCaptured = false
    @State private var showWinner = false
    @State private var showLoser = false
    @State private var isSittingSheetPresented = false
    var body: some View {
        NavigationView {
            ZStack {
                
                
                Image("back3")
                    .resizable()
                  //  .scaledToFit()
                    .ignoresSafeArea()
                Button(action: {
                    isSittingSheetPresented.toggle()
                }) {
                    Spacer()
                    Spacer()
                    Spacer()

                    Image("settings")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .position(x: 325)
                        .sheet(isPresented: $isSittingSheetPresented) {
                            Sitting()
                        }
                }

                Image("camel")
                    .position(x: 70, y: 150)

                if isImageCaptured {
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)

                        if let result = classificationResult {
                            if result == "Unable to recognize image with certainty." {
                                Button(action: {
                                    showLoser = true
                                }) {
                                    Loser()

                                }
                .navigationBarHidden(true)
                .background(NavigationLink("", destination: Loser(), isActive: $showLoser))
                            } else {
                                Button(action: {
                                    showWinner = true
                                }) {
                                    Winner()
                                }
                                .navigationBarHidden(true)
                                .background(NavigationLink("", destination: Winner(), isActive: $showWinner))
                            }
                        }
                    }
                } else {
                    CameraView(capturedImage: $capturedImage, classificationResult: $classificationResult, isImageCaptured: $isImageCaptured)
                        .frame(width: 300, height: 500)
                        .cornerRadius(20)
                        .position(x: 200, y: 500)
                }

                Spacer()
            }
            //.navigationBarTitle("Camera View", displayMode: .inline)
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var classificationResult: String?
    @Binding var isImageCaptured: Bool

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var capturedImage: UIImage?
        @Binding var classificationResult: String?
        @Binding var isImageCaptured: Bool

        init(capturedImage: Binding<UIImage?>, classificationResult: Binding<String?>, isImageCaptured: Binding<Bool>) {
            _capturedImage = capturedImage
            _classificationResult = classificationResult
            _isImageCaptured = isImageCaptured
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                capturedImage = image
                classifyImage(image)
                isImageCaptured = true
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }


func classifyImage(_ image: UIImage) {
            guard let ciImage = CIImage(image: image) else {
                classificationResult = "Error: Unable to create CIImage from UIImage"
                return
            }

            do {
                let model = MyImageClassifier_mo().model
                let visionModel = try VNCoreMLModel(for: model)
                let request = VNCoreMLRequest(model: visionModel) { [self] request, error in
                    if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                        if topResult.confidence >= 0.9 {
                            classificationResult = "\(topResult.identifier) (\(topResult.confidence))"
                        } else {
                            classificationResult = "Unable to recognize image with certainty."
                        }
                    } else {
                        classificationResult = "Unable to classify"
                    }
                }

                let handler = VNImageRequestHandler(ciImage: ciImage)
                try handler.perform([request])
            } catch {
                print("Error classifying image: \(error)")
                classificationResult = "Error: \(error.localizedDescription)"
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(capturedImage: $capturedImage, classificationResult: $classificationResult, isImageCaptured: $isImageCaptured)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct Camera1_Previews: PreviewProvider {
    static var previews: some View {
        Camera1()
            .background(
                Image("back3")
                    .resizable()
                  //  .ignoresSafeArea()
                  // .padding(.top, -20.0)
                  //  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
            )
         
    }
}

struct Winner1: View {
    var body: some View {
    
        Winner()
    }
}

struct loser1: View {
    var body: some View {
        Loser()
    }
}
