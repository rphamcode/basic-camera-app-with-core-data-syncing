//
//  AVVideoCaptureOrientationExtension.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI
import AVKit

extension AVCaptureVideoOrientation {
      static func videoOrientation() -> AVCaptureVideoOrientation {
            var videoOrientation: AVCaptureVideoOrientation!
            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            
            switch orientation {
                  case .faceUp, .faceDown, .unknown:
                        if let interfaceOrientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
                              $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                              
                              switch interfaceOrientation {
                                    case .portrait, .unknown:
                                          videoOrientation = .portrait
                                    case .portraitUpsideDown:
                                          videoOrientation = .portraitUpsideDown
                                    case .landscapeLeft:
                                          videoOrientation = .landscapeRight
                                    case .landscapeRight:
                                          videoOrientation = .landscapeLeft
                                    @unknown default:
                                          videoOrientation = .portrait
                              }
                        }
                  case .portrait:
                        videoOrientation = .portrait
                  case .portraitUpsideDown:
                        videoOrientation = .portraitUpsideDown
                  case .landscapeLeft:
                        videoOrientation = .landscapeRight
                  case .landscapeRight:
                        videoOrientation = .landscapeLeft
                  @unknown default:
                        videoOrientation = .portrait
            }
            
            return videoOrientation
      }
}
