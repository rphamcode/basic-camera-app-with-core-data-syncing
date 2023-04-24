//
//  ShareSheetView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
      var image: UIImage
      
      func makeUIViewController(context: Context) -> UIActivityViewController {
            return UIActivityViewController(activityItems: [image], applicationActivities: nil)
      }
      
      func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
            
      }
}
