//
//  CameraLayerView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI
import AVKit

struct CameraLayerView: UIViewRepresentable {
      @Binding var session: AVCaptureSession
      var videoGravity: AVLayerVideoGravity
      var frameSize: CGSize
      
      func makeUIView(context: Context) -> UIView {
            let view = UIView(frame: .init(origin: .zero, size: frameSize))
            view.backgroundColor = .clear
            view.clipsToBounds = true
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
            cameraLayer.videoGravity = videoGravity
            cameraLayer.frame = .init(origin: .zero, size: frameSize)
            cameraLayer.masksToBounds = true
            view.layer.addSublayer(cameraLayer)
            
            return view
      }
      
      func updateUIView(_ uiView: UIView, context: Context) {
            if let cameraLayer = uiView.layer.sublayers?.first(where: { layer in
                  layer is AVCaptureVideoPreviewLayer
            }) as? AVCaptureVideoPreviewLayer {
                  cameraLayer.frame = .init(origin: .zero, size: frameSize)
                  cameraLayer.videoGravity = videoGravity
            }
      }
}
