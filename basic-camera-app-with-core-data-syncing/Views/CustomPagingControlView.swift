//
//  CustomPagingControlView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct CustomPagingControlView: UIViewRepresentable {
      var numberOfPages: Int
      var currentPage: Int
      var isEnabled: Bool = true
      
      func makeUIView(context: Context) -> UIPageControl {
            let control = UIPageControl()
            
            control.numberOfPages = numberOfPages
            control.currentPage = currentPage
            control.backgroundStyle = .prominent
            control.isUserInteractionEnabled = isEnabled
            
            return control
      }
      
      func updateUIView(_ uiView: UIPageControl, context: Context) {
            uiView.currentPage = currentPage
            uiView.numberOfPages = numberOfPages
      }
}
