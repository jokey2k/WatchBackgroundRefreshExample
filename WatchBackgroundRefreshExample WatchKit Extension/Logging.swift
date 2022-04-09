//
//  Logging.swift
//  WatchBackgroundRefreshExample WatchKit Extension
//
//  Created by Markus Ullmann on 28.03.22.
//

import Foundation
import os.log

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let lifecycle = OSLog(subsystem: subsystem, category: "Lifecycle")
    static let backgroundTask = OSLog(subsystem: subsystem, category: "Background task")
    static let ui = OSLog(subsystem: subsystem, category: "UI")
}
