//
//  DrawingOverlayView.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

struct DrawingOverlayView: View {
    let paths: [DrawingPath]
    let currentPath: DrawingPath
    var strokeColor: Color

    var body: some View {
        Canvas { context, _ in
            for path in paths {
                var pathObj = Path()
                if let first = path.points.first {
                    pathObj.move(to: first)
                    pathObj.addLines(path.points)
                    context.stroke(pathObj, with: .color(strokeColor), lineWidth: 4)
                }
            }

            // Live drawing
            var livePath = Path()
            if let first = currentPath.points.first {
                livePath.move(to: first)
                livePath.addLines(currentPath.points)
                context.stroke(livePath, with: .color(strokeColor), lineWidth: 4)
            }
        }
    }
}
