//
//  RootView.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

struct RootView: View {
    @State private var capturedImage: UIImage?
    @State private var showEditor = false
    @State private var showCamera = true

    var body: some View {
        NavigationStack {
            if let image = capturedImage, showEditor {
                PhotoEditorView(originalImage: image) {
                    // Handle cancel
                    capturedImage = nil
                    showEditor = false
                    showCamera = true
                }
            } else if showCamera {
                CameraView(image: $capturedImage, sourceType: .camera)
                    .ignoresSafeArea()
                    .onChange(of: capturedImage) { newImage in
                        if newImage != nil {
                            showCamera = false
                            showEditor = true
                        }
                    }
            }
        }
    }
}
