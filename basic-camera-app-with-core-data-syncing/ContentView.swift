//
//  ContentView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct ContentView: View {
      @State private var showTakenPhotos: Bool = false
      
      var body: some View {
            CameraView(showTakenPhotos: $showTakenPhotos)
                  .fullScreenCover(isPresented: $showTakenPhotos) {
                        ListPhotoView()
                  }
                  .preferredColorScheme(.dark)
      }
}

struct ContentView_Previews: PreviewProvider {
      static var previews: some View {
            ContentView()
      }
}
