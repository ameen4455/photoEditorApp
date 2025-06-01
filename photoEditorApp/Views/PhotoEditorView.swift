//
//  PhotoEditorView.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

struct CanvasSticker: Identifiable {
    let id = UUID()
    var image: UIImage
    var position: CGPoint
}

struct DrawingPath {
    var points: [CGPoint]
}

struct PhotoEditorView: View {
    let originalImage: UIImage
    let onCancel: () -> Void

    @State private var caption: String = ""
    @State private var canvasStickers: [CanvasSticker] = []
    @State private var drawingPaths: [DrawingPath] = []
    @State private var currentDrawing: DrawingPath = DrawingPath(points: [])

    @State private var showStickerPicker = false

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        DrawingOverlayView(paths: drawingPaths, currentPath: currentDrawing)
                    )
                    .overlay(
                        ForEach($canvasStickers) { sticker in
                            DraggableSticker(sticker: sticker)
                        }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                currentDrawing.points.append(value.location)
                            }
                            .onEnded { _ in
                                drawingPaths.append(currentDrawing)
                                currentDrawing = DrawingPath(points: [])
                            }
                    )

                if showStickerPicker {
                    Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                    StickerPickerGridView { image in
                        let screenWidth = UIScreen.main.bounds.width
                        let aspectRatio = originalImage.size.height / originalImage.size.width
                        let canvasSize = CGSize(width: screenWidth, height: screenWidth * aspectRatio)
                        let centerPoint = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

                        let newSticker = CanvasSticker(image: image, position: centerPoint)

                        canvasStickers.append(newSticker)
                        showStickerPicker = false
                    }
                    .frame(height: 300)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding()
                }
            }
            .frame(maxHeight: .infinity)

            TextField("Add a caption...", text: $caption)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding([.horizontal, .top])

            HStack {
                Button("Stickers") {
                    showStickerPicker = true
                }

                Spacer()

                Button("Clear") {
                    drawingPaths.removeAll()
                    canvasStickers.removeAll()
                    caption = ""
                }

                Spacer()

                Button("Share to IG") {
                    shareToInstagram()
                }
            }
            .padding(.horizontal)

            Button("Cancel") {
                onCancel()
            }
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func shareToInstagram() {
        let finalImage = renderFinalImage()
        InstagramShareHelper.shareToInstagramStories(backgroundImage: finalImage)
    }

    private func renderFinalImage() -> UIImage {
        let imageSize = originalImage.size

        let screenWidth = UIScreen.main.bounds.width
        let aspectRatio = imageSize.height / imageSize.width
        let canvasSize = CGSize(width: screenWidth, height: screenWidth * aspectRatio)

        let xScale = imageSize.width / canvasSize.width
        let yScale = imageSize.height / canvasSize.height

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = originalImage.scale
        let renderer = UIGraphicsImageRenderer(size: imageSize, format: format)

        return renderer.image { ctx in
            // Draw the original photo
            originalImage.draw(in: CGRect(origin: .zero, size: imageSize))

            // Draw scaled stickers
            for sticker in canvasStickers {
                let scaledOrigin = CGPoint(
                    x: sticker.position.x * xScale - (50 * xScale),
                    y: sticker.position.y * yScale - (50 * yScale)
                )
                let scaledSize = CGSize(width: 100 * xScale, height: 100 * yScale)
                let frame = CGRect(origin: scaledOrigin, size: scaledSize)
                sticker.image.draw(in: frame)
            }

            // Draw scaled drawing paths
            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
            ctx.cgContext.setLineWidth(4 * ((xScale + yScale) / 2))

            for path in drawingPaths {
                guard let first = path.points.first else { continue }

                ctx.cgContext.beginPath()
                ctx.cgContext.move(to: CGPoint(x: first.x * xScale, y: first.y * yScale))
                for point in path.points.dropFirst() {
                    ctx.cgContext.addLine(to: CGPoint(x: point.x * xScale, y: point.y * yScale))
                }
                ctx.cgContext.strokePath()
            }
        }
    }

}
