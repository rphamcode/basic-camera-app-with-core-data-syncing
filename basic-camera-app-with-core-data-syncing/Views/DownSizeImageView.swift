//
//  DownSizeImageView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct DownSizeImageView: View {
      var image: UIImage
      var size: CGSize
      var mode: ContentMode = .fit
      var background: Color = .clear
      
      @State private var downSizeImage: UIImage?
      
      var body: some View {
            ZStack {
                  if let downSizeImage = downSizeImage {
                        Image(uiImage: downSizeImage)
                              .resizable()
                              .aspectRatio(contentMode: mode)
                              .frame(width: size.width, height: size.height)
                  } else {
                        Rectangle()
                              .fill(background)
                  }
            }
            .onAppear {
                  if downSizeImage == nil {
                        createDownSizeImage()
                  }
            }
      }
      
      func createDownSizeImage() {
            let scale = deviceScale
            
            DispatchQueue.global(qos: .userInteractive).async {
                  let downImage = image.setImageQuality(to: size, quality: 0.7, scale: scale)
                  
                  DispatchQueue.main.async {
                        downSizeImage = downImage
                  }
            }
      }
}
