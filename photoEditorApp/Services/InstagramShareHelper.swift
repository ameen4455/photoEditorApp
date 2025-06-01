//
//  InstagramShareHelper.swift
//  photoEditor
//
//  Created by Ameen Azeez on 01/06/25.
//

import UIKit

class InstagramShareHelper {
    private static let appID = ""
    
    static func shareToInstagramStories(backgroundImage: UIImage) {
        let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)")!
        
        guard UIApplication.shared.canOpenURL(urlScheme) else {
            print("Instagram Stories not available")
            return
        }
        
        guard let backgroundData = backgroundImage.pngData() else {
            print("Failed to convert background image to PNG data")
            return
        }
        
        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.backgroundImage": backgroundData
            ]
        ]
        
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(300)
        ]
        
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        
        UIApplication.shared.open(urlScheme, options: [:]) { success in
            if success {
                print("Instagram opened successfully")
            } else {
                print("Failed to open Instagram")
            }
        }
    }
}
