import UIKit
import BackgroundTasks
import Flutter
import MobileCoreServices
import flutter_background_service_ios
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
            _ application: UIApplication,
          open url: URL,
          options: [UIApplication.OpenURLOptionsKey: Any] = [:]
      ) -> Bool {
          if url.isFileURL {
              if let fileContents = try? String(contentsOf: url) {
                  print("File Contents: \(fileContents)")
              }
              return true
          }
          return false
      }
}
