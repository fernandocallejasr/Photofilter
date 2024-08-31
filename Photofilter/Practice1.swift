//
//  Practice1.swift
//  Photofilter
//
//  Created by Fernando Callejas on 31/08/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct Practice1: View {
    @State private var processedImage: Image?
    @State private var photoPickerItem: PhotosPickerItem?
    
    @State private var filterIntensity = 0.5
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var beginImage: UIImage?
    let context = CIContext()
    
    @State private var showingConfirmationDialog = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if let processedImage {
                processedImage
                    .resizable()
                    .scaledToFit()
            } else {
                ContentUnavailableView("Currently no selected photo", systemImage: "photo.badge.plus.fill")
            }
            
            Spacer()
            
            Slider(value: $filterIntensity, in: 0...20)
            
            Button("Change filter", action: changeFilter)
                .buttonStyle(.borderedProminent)
            
            PhotosPicker(selection: $photoPickerItem) {
                HStack {
                    Text("Select Image")
                    Image(systemName: "camera.macro.circle")
                }
            }
        }
        .padding([.horizontal, .bottom])
        .onChange(of: photoPickerItem, loadImage)
        .onChange(of: filterIntensity, applyFilter)
        .onChange(of: currentFilter, applyFilter)
        .confirmationDialog("Select Filter", isPresented: $showingConfirmationDialog) {
            Button("Pointillize") { setFilter(CIFilter.pointillize()) }
            Button("Crystallize") { setFilter(CIFilter.crystallize()) }
            Button("Edges") { setFilter(CIFilter.edges()) }
            Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
            Button("Pixellate") { setFilter(CIFilter.pixellate()) }
            Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
            Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
            Button("Vignette") { setFilter(CIFilter.vignette()) }
        }
    }
    
    func changeFilter() {
        showingConfirmationDialog.toggle()
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
    }
    
    func loadImage() {
        Task {
//            guard let image = try await photoPickerItem?.loadTransferable(type: Image.self) else { return }
//            processedImage = image
            
            guard let imageData = try await photoPickerItem?.loadTransferable(type: Data.self) else { return }
            beginImage = UIImage(data: imageData)
            
            applyFilter()
        }
    }
    
    func applyFilter() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputRadiusKey) }
        
        guard let startImage = beginImage else { return }
        guard let inputImage = CIImage(image: startImage) else { return }
        currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        let image = Image(uiImage: uiImage)
        
        processedImage = image
    }
}

#Preview {
    Practice1()
}
