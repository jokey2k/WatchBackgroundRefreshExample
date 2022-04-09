//
//  ContentView.swift
//  WatchBackgroundRefreshExample WatchKit Extension
//
//  Created by Markus Ullmann on 28.03.22.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @EnvironmentObject private var extensionDelegate: ExtensionDelegate

    @State private var statusText = ""
    var body: some View {
        VStack {
            Button("Click me to update") {
                let fireDate = Date(timeIntervalSinceNow: 20.0)
                let userInfo = ["reason" : "background update"] as NSDictionary
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: fireDate, userInfo: userInfo) { (error) in
                    if (error == nil) {
                        os_log("successfully scheduled background task, use the crown to send the app to the background and wait for handle:BackgroundTasks to fire.", log: .ui)
                    }
                }
            }
            Text("\(statusText)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
