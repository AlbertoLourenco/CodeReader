//
//  AppDelegate.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 22/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {}

	func applicationDidEnterBackground(_ application: UIApplication) {}

	func applicationWillEnterForeground(_ application: UIApplication) {}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		NotificationCenter.default.post(name: NSNotification.Name("ApplicationDidBecomeActive"), object: nil)
	}

	func applicationWillTerminate(_ application: UIApplication) {}
}

