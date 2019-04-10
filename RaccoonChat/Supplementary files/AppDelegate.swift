//
//  AppDelegate.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 09/02/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    // Applying theme
    let theme = ThemeManager.currentTheme()
    ThemeManager.applyTheme(theme: theme)

    Logger.appStateIsChanging(from: "Not running", to: "Inactive")
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    Logger.appStateIsChanging(from: "Active", to: "Inactive")
  }

  func applicationDidEnterBackground(_ application: UIApplication) {

    Logger.appStateIsChanging(from: "Inactive", to: "Background")
  }

  func applicationWillEnterForeground(_ application: UIApplication) {

    Logger.appStateIsChanging(from: "Background", to: "Inactive")
  }

  func applicationDidBecomeActive(_ application: UIApplication) {

    Logger.appStateIsChanging(from: "Inactive", to: "Active")
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    Logger.appStateIsChanging(from: "Background", to: "Not running")
  }
}
