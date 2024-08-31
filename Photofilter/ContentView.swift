//
//  ContentView.swift
//  Photofilter
//
//  Created by Fernando Callejas on 29/08/24.
//
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var photoPickerItem: PhotosPickerItem?
//    @State private var photoPicker: PhotosPickerItem
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ContentUnavailableView {
                    Label("No Image", systemImage: "photo.circle")
                }
                
                processedImage?
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        // change filter
                    }
                    
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
            .onChange(of: photoPickerItem) { oldValue, newValue in
                Task {
                    let selectedImage = try await photoPickerItem?.loadTransferable(type: Image.self)
                    processedImage = selectedImage
                }
            }
            .navigationTitle("Photofilter")
        }
    }
}

#Preview {
    ContentView()
}
