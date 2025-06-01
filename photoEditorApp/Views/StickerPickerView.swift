//
//  StickerPickerView.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import SwiftUI

import SwiftUI

struct StickerPickerGridView: View {
    let columns = [GridItem(.adaptive(minimum: 80))]
    let onSelect: (UIImage) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(1...40, id: \.self) { index in
                    if let image = UIImage(named: "Sticker \(index)") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .onTapGesture {
                                onSelect(image)
                            }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    StickerPickerGridView { _ in
        
    }
}
