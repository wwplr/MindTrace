import UIKit
import Flutter
import MobileCoreServices

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(
          _ application: UIApplication,
          open url: URL,
          options: [UIApplication.OpenURLOptionsKey: Any] = [:]
      ) -> Bool {
          if url.isFileURL {
              // Handle the file URL here, for example, read the contents.
              if let fileContents = try? String(contentsOf: url) {
                  print("File Contents: \(fileContents)")
              }
              return true
          }
          return false
      }
}