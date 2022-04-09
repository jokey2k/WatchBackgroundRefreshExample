//
//  ExtensionDelegate.swift
//  WatchBackgroundRefreshExample WatchKit Extension
//
//  Created by Markus Ullmann on 28.03.22.
//

import WatchKit
import os.log

struct NewsItem: Decodable, Identifiable {
    let id: Int
    let title: String
    let strap: String
}

class ExtensionDelegate: NSObject, WKExtensionDelegate, ObservableObject, URLSessionDelegate, URLSessionDownloadDelegate {
    var savedTask: WKRefreshBackgroundTask?
    
    static func shared() -> ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        os_log("Fetch completed, starting processing", log: .backgroundTask)

        let news : [NewsItem]
        do {
            let data = try Data(contentsOf: location)
            news = try JSONDecoder().decode([NewsItem].self, from: data)
        } catch {
            os_log("Failed reading file contents", log: .backgroundTask)
            news = [NewsItem]()
        }
        print("Got \(news.count) NewsItems")
        os_log("Processing finished, marking task as completed", log: .backgroundTask)
        self.savedTask?.setTaskCompletedWithSnapshot(false)
    }
    
    func scheduleURLSession()
    {
        os_log("Scheduling URL Session", log: .backgroundTask)

        let sessionIdentifier = NSUUID().uuidString
        let backgroundSessionConfig:URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        backgroundSessionConfig.isDiscretionary = false
        backgroundSessionConfig.sessionSendsLaunchEvents = false

        let backgroundSession = URLSession(configuration: backgroundSessionConfig, delegate: self, delegateQueue: nil)

        let downloadTask = backgroundSession.downloadTask(with: URL(string: "https://www.hackingwithswift.com/samples/news-1.json")!)
        downloadTask.resume()
        os_log("Request for download scheduled", log: .backgroundTask)
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {

            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                os_log("Received WKApplicationRefreshBackgroundTask", log: .backgroundTask)
                // self.updateComplicationDataArrivalTimes(backgroundTask)
                self.scheduleURLSession()
                backgroundTask.setTaskCompletedWithSnapshot(false)

            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                os_log("Received WKSnapshotRefreshBackgroundTask", log: .backgroundTask)
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)

            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                os_log("Received WKWatchConnectivityRefreshBackgroundTask", log: .backgroundTask)
                connectivityTask.setTaskCompletedWithSnapshot(false)

            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                os_log("Received WKURLSessionRefreshBackgroundTask", log: .backgroundTask)
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
                let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)

                self.savedTask = urlSessionTask
                //call this only after all data is done processing!
                //In the demo case, this will be done in the triggered task
                //urlSessionTask.setTaskCompletedWithSnapshot(false)

            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
