//
//  ContentView.swift
//  Photofilter
//
//  Created by Fernando Callejas on 29/08/24.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(\.requestReview) private var reviewRequest
    
    @State var filterCount: Int = UserDefaults.standard.integer(forKey: "filterCount") {
        didSet {
            print(filterCount)
            Foundation.UserDefaults.standard.setValue(filterCount, forKey: "filterCount")
        }
    }
    
    @State private var inputUIImage: UIImage?
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @State private var showingFilters = false
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView {
                        Label("No Image", systemImage: "photo.circle")
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)
                
                HStack(spacing: 40) {
                    Button("Change Filter", action: changeFilter)
                        .buttonStyle(.borderedProminent)
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Photofilter Image", image: processedImage))
                    }
                    
                }
                .padding(.vertical)
                
                PhotosPicker(selection: $photoPickerItem) {
                    Label("Select image", systemImage: "camera.macro.circle")
                }
            }
            .padding([.horizontal, .bottom])
            .onChange(of: photoPickerItem, loadImage)
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
            .navigationTitle("Photofilter")
        }
    }
    
    func loadImage() {
        Task {
            guard let selectedImageData = try await photoPickerItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: selectedImageData) else { return }
            inputUIImage = inputImage
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        guard let inputUIImage = inputUIImage else { return }
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage, scale: inputUIImage.scale, orientation: inputUIImage.imageOrientation)
        processedImage = Image(uiImage: uiImage)
    }
    
    func changeFilter() {
        showingFilters.toggle()
    }
    
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        
        if filterCount % 15 == 0 {
            reviewRequest()
        }
    }
}

#Preview {
    ContentView()
}
