//
//  DraggableTextView.swift
//  photoEditorApp
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

struct DraggableTextView: View {
    let text: String
    @Binding var position: CGPoint
    var color: Color
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        Text(text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
            .position(x: position.x + dragOffset.width,
                      y: position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        position.x += value.translation.width
                        position.y += value.translation.height
                    }
            )
    }
}
