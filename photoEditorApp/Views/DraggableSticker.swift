//
//  DraggableSticker.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

struct DraggableSticker: View {
    @Binding var sticker: CanvasSticker

    var body: some View {
        Image(uiImage: sticker.image)
            .resizable()
            .frame(width: 100, height: 100)
            .position(sticker.position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sticker.position = value.location
                    }
            )
    }
}
