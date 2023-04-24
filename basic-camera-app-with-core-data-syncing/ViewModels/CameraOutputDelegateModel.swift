//
//  CameraOutputDelegateModel.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI
import AVKit

class CameraOutputDelegateModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
      @Published var photoError: Bool = false
      @Published var photoErrorMessage: String = ""
      @Published var latestImageData: Data?
      
      func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error {
                  photoErrorMessage = error.localizedDescription
                  photoError.toggle()
                  
                  return
            }
            
            if let processedData = photo.fileDataRepresentation() {
                  latestImageData = processedData
            }
      }
      
      func clear() {
            latestImageData = nil
      }
}
