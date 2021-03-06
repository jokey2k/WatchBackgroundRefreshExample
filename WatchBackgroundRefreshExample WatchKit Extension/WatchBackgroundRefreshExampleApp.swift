//
//  WatchBackgroundRefreshExampleApp.swift
//  WatchBackgroundRefreshExample WatchKit Extension
//
//  Created by Markus Ullmann on 28.03.22.
//

import SwiftUI

@main
struct WatchBackgroundRefreshExampleApp: App {
    @WKExtensionDelegateAdaptor private var extensionDelegate: ExtensionDelegate
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
