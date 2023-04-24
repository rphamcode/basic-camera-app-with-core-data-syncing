//
//  ViewExtension.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

extension View {
      var deviceScale: CGFloat {
            return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.screen.scale ?? 1
      }
      
      func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
      }
      
      @ViewBuilder
      func disableWithOpacity(_ status: Bool) -> some View {
            self
                  .disabled(status)
                  .opacity(status ? 0.6 : 1)
      }
}
