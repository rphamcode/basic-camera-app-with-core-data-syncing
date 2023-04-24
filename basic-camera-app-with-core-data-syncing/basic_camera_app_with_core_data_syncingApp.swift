//
//  basic_camera_app_with_core_data_syncingApp.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

@main
struct basic_camera_app_with_core_data_syncingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
