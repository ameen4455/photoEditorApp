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

    @State private var selectedColor: Color = .red
    @State private var caption: String = ""
    @State private var canvasStickers: [CanvasSticker] = []
    @State private var drawingPaths: [DrawingPath] = []
    @State private var currentDrawing: DrawingPath = DrawingPath(points: [])
    @State private var captionPosition = CGPoint(x: 150, y: 100) // default starting point

    @State private var showStickerPicker = false

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        DrawingOverlayView(paths: drawingPaths, currentPath: currentDrawing, strokeColor: selectedColor)
                    )
                    .overlay(content: {
                        DraggableTextView(text: caption, position: $captionPosition, color: selectedColor)
                    })
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
            }
            .frame(maxHeight: .infinity)

            TextField("Add a caption...", text: $caption)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding([.horizontal, .top])
            
            HStack(spacing: 16) {
                ForEach([Color.red, Color.blue, Color.green, Color.yellow, Color.purple, Color.white, Color.black], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal)

            HStack {
                Button("Stickers") {
                    showStickerPicker = true
                }

                Spacer()

                Button("Share to IG") {
                    shareToInstagram()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    onCancel()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    drawingPaths.removeAll()
                    canvasStickers.removeAll()
                    caption = ""
                }
            }
        }
        .sheet(isPresented: $showStickerPicker) {
           VStack {
               HStack {
                   Text("Pick a sticker")
                       .font(.headline)
                   Spacer()
                   Button("Done") {
                       showStickerPicker = false
                   }
               }
               .padding()

               StickerPickerGridView { image in
                   let screenWidth = UIScreen.main.bounds.width
                   let aspectRatio = originalImage.size.height / originalImage.size.width
                   let canvasSize = CGSize(width: screenWidth, height: screenWidth * aspectRatio)
                   let centerPoint = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

                   let newSticker = CanvasSticker(image: image, position: centerPoint)

                   canvasStickers.append(newSticker)
                   showStickerPicker = false
               }
               .padding()
           }
           .presentationDetents([.medium, .large])
           .background(Color.white)
       }
        .ignoresSafeArea(.keyboard)
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
            
            // Draw caption text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor(selectedColor), // Apply selected color
                .paragraphStyle: paragraphStyle,
                .shadow: NSShadow()
            ]

            let scaledPoint = CGPoint(
                x: captionPosition.x * xScale,
                y: captionPosition.y * yScale
            )

            let attributedText = NSAttributedString(string: caption, attributes: attributes)
            let textSize = attributedText.size()

            let textRect = CGRect(
                origin: CGPoint(x: scaledPoint.x - textSize.width / 2, y: scaledPoint.y - textSize.height / 2),
                size: textSize
            )

            attributedText.draw(in: textRect)

            // Draw scaled drawing paths
            ctx.cgContext.setStrokeColor(UIColor(selectedColor).cgColor)
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
