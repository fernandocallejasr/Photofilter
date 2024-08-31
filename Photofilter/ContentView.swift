//
//  ContentView.swift
//  Photofilter
//
//  Created by Fernando Callejas on 29/08/24.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var currentFilter = CIFilter.sepiaTone()
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $photoPickerItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView {
                            Label("No Image", systemImage: "photo.circle")
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    
                    Spacer()
                    
                    // share the picture
                }
                .padding(.vertical)
                
                PhotosPicker(selection: $photoPickerItem) {
                    Label("Please select an image", systemImage: "camera.macro.circle")
                        .font(.title3)
                }
                .tint(.primary)
            }
            .padding([.horizontal, .bottom])
            .onChange(of: photoPickerItem, loadImage)
            .navigationTitle("Photofilter")
        }
    }
    
    func loadImage() {
        Task {
            guard let selectedImage = try await photoPickerItem?.loadTransferable(type: Image.self) else { return }
            processedImage = selectedImage
            
            guard let selectedImageData = try await photoPickerItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: selectedImageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        currentFilter.intensity = Float(filterIntensity)
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    func changeFilter() {
        
    }
}

#Preview {
    ContentView()
}
