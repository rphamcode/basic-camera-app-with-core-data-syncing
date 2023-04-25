//
//  CameraConfigView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct CameraConfigView: View {
    var body: some View {
          HStack(spacing: 0) {
              Button {
                  haptics(.medium)
                  cameraPosition = (cameraPosition == .back ? .front : .back)
                  turnOnFlash = false
                  cameraZoom = 0
                  session.stopRunning()
                  for input in session.inputs {
                      session.removeInput(input)
                  }
                  for output in session.outputs {
                      session.removeOutput(output)
                  }
                  setupCamera()
              } label: {
                  Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                      .font(.title2)
                      .foregroundColor(.white)
                      .contentShape(Rectangle())
              }
              
              Button {
                  withAnimation(.easeInOut(duration: 0.3)) {
                      haptics(.medium)
                      showZoomSlider.toggle()
                  }
              } label: {
                  Image(systemName: "plus.magnifyingglass")
                      .font(.title2)
                      .foregroundColor(showZoomSlider ? .yellow : .white)
                      .contentShape(Rectangle())
              }
              .frame(maxWidth: .infinity)

              ZStack {
                  Button {
                      if let activeDevice = (session.inputs.first as? AVCaptureDeviceInput)?.device, activeDevice.isTorchAvailable {
                          haptics(.medium)
                          turnOnFlash.toggle()
                          try? activeDevice.lockForConfiguration()
                          activeDevice.torchMode = turnOnFlash ? .on : .off
                          activeDevice.unlockForConfiguration()
                      } else {
                          presentError("Torch is Not Available")
                      }
                  } label: {
                      Image(systemName: turnOnFlash ? "flashlight.off.fill" : "flashlight.on.fill")
                          .font(.title2)
                          .foregroundColor(turnOnFlash ? .yellow : .white)
                          .contentShape(Rectangle())
                  }
                  .disabled(cameraPosition == .front)
                  .opacity(cameraPosition == .front ? 0.6 : 1)
              }
          }
          .padding(.horizontal, 15)
          .frame(height: 50)
          .frame(maxWidth: .infinity)
          .background {
              Rectangle()
                  .fill(.ultraThinMaterial)
                  .ignoresSafeArea(.all, edges: .top)
          }
          .background(alignment: .bottom, content: {
              /// Camera Zoom Slider
              HStack(spacing: 12) {
                  Image(systemName: "minus.magnifyingglass")
                      .foregroundColor(.gray)
                  
                  ZStack {
                      if let device = (session.inputs.first as? AVCaptureDeviceInput)?.device {
                          Slider(value: $cameraZoom, in: device.minAvailableVideoZoomFactor...device.maxAvailableVideoZoomFactor, step: 0.1)
                              .onChange(of: cameraZoom) { newValue in
                                  /// Zooming in/out Camera
                                  if let _ = try? device.lockForConfiguration() {
                                      defer { device.unlockForConfiguration() }
                                      device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, min(newValue, device.maxAvailableVideoZoomFactor))
                                  }
                              }
                              .tint(.white)
                      }
                  }
                  .frame(maxWidth: .infinity)
                  
                  Image(systemName: "plus.magnifyingglass")
                      .foregroundColor(.gray)
              }
              .padding(.horizontal, 15)
              .frame(height: 40)
              .background {
                  ZStack {
                      Color.black
                      
                      Rectangle()
                          .fill(.ultraThinMaterial)
                  }
              }
              .opacity(showZoomSlider ? 1 : 0)
              .offset(y: showZoomSlider ? 40 : 0)
          })
    }
}

struct CameraConfigView_Previews: PreviewProvider {
    static var previews: some View {
        CameraConfigView()
    }
}
