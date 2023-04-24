//
//  UIImageExtension.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

extension UIImage {
      func scaleToFit(_ newSize: CGSize) -> UIImage? {
            let aspectWidth = newSize.width / size.width
            let aspectHeight = newSize.height / size.height
            let aspectRatio = min(aspectWidth, aspectHeight)
            
            let scaledSize = CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)
            var scaledRect = CGRect(origin: .zero, size: scaledSize)
            
            scaledRect.origin.x = (newSize.width - scaledRect.size.width) / 2.0
            scaledRect.origin.y = (newSize.height - scaledRect.size.height) / 2.0
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            draw(in: scaledRect, blendMode: .normal, alpha: 1)
            
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage
      }
      
      func scaleToFill(_ size: CGSize) -> UIImage? {
            let scale = max(size.width / self.size.width, size.height / self.size.height)
            let scaledWidth = self.size.width * scale
            let scaledHeight = self.size.height * scale
            let scaledImageRect = CGRect(x: (size.width - scaledWidth) / 2.0, y: (size.height - scaledHeight) / 2.0, width: scaledWidth, height: scaledHeight)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            draw(in: scaledImageRect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
      }
      
      func setImageQuality(to pointSize: CGSize, quality: CGFloat = 1, scale: CGFloat = 1) -> UIImage? {
            guard let imageData = self.pngData() else { return nil }
            
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            
            let options = [
                  kCGImageSourceCreateThumbnailWithTransform: true,
                  kCGImageSourceCreateThumbnailFromImageAlways: true,
                  kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
            
            return UIImage(cgImage: imageReference, scale: self.scale, orientation: self.imageOrientation)
      }
}
