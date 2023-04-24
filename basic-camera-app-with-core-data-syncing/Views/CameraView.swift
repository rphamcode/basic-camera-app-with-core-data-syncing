//
//  CameraView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI
import CoreData
import AVKit

struct CameraView: View {
      @Binding var showTakenPhotos: Bool
    
      @State private var session: AVCaptureSession = .init()
      @State private var cameraPosition: AVCaptureDevice.Position = .back
      @State private var cameraOutput: AVCapturePhotoOutput = .init()
      @State private var isSquarePhoto: Bool = false
      @State private var turnOnFlash: Bool = false
     
      @StateObject private var cameraOutputDelegate: CameraOutputDelegateModel = .init()
     
      @State private var permission: CameraPermission = .idle
      @State private var cameraError: Bool = false
      @State private var errorMessage: String = ""
      @State private var showZoomSlider: Bool = false
      @State private var cameraZoom: CGFloat = 0
      @Environment(\.openURL) private var openURL
    
      @Environment(\.managedObjectContext) private var context
      @FetchRequest var recentPicture: FetchedResults<Photo>
      @State private var recentThumbnail: UIImage?
      
      init(showTakenPhotos: Binding<Bool>) {
            self._showTakenPhotos = showTakenPhotos
            
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            request.sortDescriptors = [
                  NSSortDescriptor(keyPath: \Photo.createdAt, ascending: false)
            ]
            
            request.fetchLimit = 1
            _recentPicture = FetchRequest(fetchRequest: request)
      }
      
      var body: some View {
            VStack(spacing: 0) {
                  CameraConfigView()
                        .zIndex(1)
                        .disableWithOpacity(permission == .denied)
                  
                  GeometryReader {
                        let frameSize = $0.size
                        let min = min(frameSize.width, frameSize.height)
                        let squareFrame = CGSize(width: min, height: min)
                        
                        Rectangle()
                              .fill(.black)
                        
                        CameraLayerView(
                              session: $session,
                              videoGravity: .resizeAspectFill,
                              frameSize: isSquarePhoto ? squareFrame : frameSize
                        )
                        .offset(y: isSquarePhoto ? (frameSize.height - min) / 2 : 0)
                        .overlay {
                              CameraDeniedView()
                        }
                  }
                  .clipped()
                  .zIndex(0)
                  
                  CameraBottomToolBar()
            }
            .alert(errorMessage, isPresented: $cameraError) {  }
            .alert(cameraOutputDelegate.photoErrorMessage, isPresented: $cameraOutputDelegate.photoError) {  }
            .onAppear(perform: checkCameraPermission)
            .onDisappear {
                  session.stopRunning()
                  turnOnFlash = false
            }
            .onChange(of: recentPicture.first) { newValue in
                  if recentPicture.isEmpty {
                        recentThumbnail = nil
                  } else {
                        createLatestPictureThumnail(newValue)
                  }
            }
            .onAppear {
                  createLatestPictureThumnail(recentPicture.first)
            }
      }
      
      @ViewBuilder
      func CameraConfigView() -> some View {
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
                                    presentError("Flash is Not Available")
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
                  HStack(spacing: 12) {
                        Image(systemName: "minus.magnifyingglass")
                              .foregroundColor(.gray)
                        
                        ZStack {
                              if let device = (session.inputs.first as? AVCaptureDeviceInput)?.device {
                                    Slider(value: $cameraZoom, in: device.minAvailableVideoZoomFactor...device.maxAvailableVideoZoomFactor, step: 0.1)
                                          .onChange(of: cameraZoom) { newValue in
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
      
      @ViewBuilder
      func CameraBottomToolBar() -> some View {
            HStack(spacing: 15) {
                  ZStack {
                        if let recentThumbnail {
                              Image(uiImage: recentThumbnail)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                        } else {
                              Rectangle()
                                    .fill(.ultraThinMaterial)
                        }
                  }
                  .frame(width: 50, height: 50)
                  .clipped()
                  .contentShape(Rectangle())
                  .onTapGesture {
                        haptics(.medium)
                        showTakenPhotos.toggle()
                  }
                  .onChange(of: showTakenPhotos) { newValue in
                        turnOnFlash = false
                        DispatchQueue.global(qos: .background).async {
                              if newValue {
                                    session.stopRunning()
                              } else {
                                    session.startRunning()
                              }
                        }
                  }
                  
                  Spacer(minLength: 0)
                  
                  Button {
                        haptics(.medium)
                        isSquarePhoto.toggle()
                  } label: {
                        Image(systemName: isSquarePhoto ? "arrow.up.backward.and.arrow.down.forward" : "square")
                              .font(.title2)
                              .foregroundColor(.white)
                              .contentShape(Rectangle())
                  }
                  .disableWithOpacity(permission == .denied)
            }
            .overlay(content: {
                  Button(action: takePicture) {
                        Circle()
                              .stroke(.white, lineWidth: 1)
                              .background(content: {
                                    Circle()
                                          .fill(.white)
                                          .frame(width: 65, height: 65)
                              })
                              .frame(width: 75, height: 75)
                              .contentShape(Circle())
                  }
                  .disableWithOpacity(permission == .denied)
                  .onChange(of: cameraOutputDelegate.latestImageData) { newValue in
                        if let newValue {
                              if isSquarePhoto {
                                    if let image = UIImage(data: newValue) {
                                          let imageSize = image.size
                                          let minSize = min(imageSize.width, imageSize.height)
                                          
                                          guard let processedImageData = image.scaleToFill(.init(width: minSize, height: minSize))?
                                                .jpegData(compressionQuality: 1) else { return }
                                          saveImageToCoreData(processedImageData)
                                    } else {
                                          presentError("Error Processing Image")
                                    }
                              } else {
                                    saveImageToCoreData(newValue)
                              }
                        }
                  }
            })
            .padding(.horizontal, 15)
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .background {
                  Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(.all, edges: .bottom)
            }
      }
      
      @ViewBuilder
      func CameraDeniedView() -> some View {
            if permission == .denied {
                  VStack(spacing: 6) {
                        Text("Camera Permission Denied")
                        
                        Button("Camera Settings") {
                              if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(settingsURL)
                              }
                        }
                        .tint(.yellow)
                  }
            }
      }
      
      func checkCameraPermission() {
            Task {
                  switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .authorized:
                              permission = .granted
                              setupCamera()
                        case .notDetermined:
                              if await AVCaptureDevice.requestAccess(for: .video) {
                                    setupCamera()
                              } else {
                                    presentError("Please Permit Access to Camera")
                              }
                        case .denied, .restricted:
                              permission = .denied
                              presentError("Please Permit Access to Camera")
                        @unknown default: break
                  }
            }
      }
      
      func setupCamera() {
            do {
                  cameraZoom = 0
                  turnOnFlash = false
                  session.beginConfiguration()
                  
                  guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: cameraPosition).devices.first else {
                        presentError("Front or Back Camera is Not Available")
                        session.commitConfiguration()
                        return
                  }
                  let input = try AVCaptureDeviceInput(device: device)
                  guard session.canAddInput(input), session.canAddOutput(cameraOutput) else {
                        presentError("Adding Problem in I/O to the Camera Session")
                        session.commitConfiguration()
                        return
                  }
                  
                  try device.lockForConfiguration()
                  if device.isTorchAvailable {
                        device.torchMode = (turnOnFlash ? .on : .off)
                  }
                  device.unlockForConfiguration()
                  
                  session.addInput(input)
                  session.addOutput(cameraOutput)
                  session.commitConfiguration()
      
                  DispatchQueue.global(qos: .background).async {
                        session.startRunning()
                  }
            } catch {
                  presentError(error.localizedDescription)
            }
      }
      
      func takePicture() {
            if let connection = cameraOutput.connection(with: .video) {
                  connection.videoOrientation = .videoOrientation()
            }
            cameraOutput.capturePhoto(with: .init(), delegate: cameraOutputDelegate)
      }
      
      func saveImageToCoreData(_ imageData: Data) {
            let photo = Photo(context: context)
            photo.createdAt = .init()
            photo.image = imageData
            do {
                  try context.save()
                        /// Saved Was Saved To Core Data Successfully
                  print("Saved")
                  cameraOutputDelegate.clear()
            } catch {
                  presentError(error.localizedDescription)
                  cameraOutputDelegate.clear()
            }
      }
      
      func createLatestPictureThumnail(_ photo: Photo?) {
            if let imageData = photo?.image, let thumbnail = UIImage(data: imageData)?.setImageQuality(to: CGSize(width: 100, height: 100)) {
                  recentThumbnail = thumbnail
            }
      }
      
      func presentError(_ message: String = "Error in Setting Camera Up") {
            errorMessage = message
            cameraError.toggle()
      }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
          CameraView(showTakenPhotos: .constant(false))
    }
}
