//
//  AppDelegate.swift
//  FbbApp
//
//  Created by Mesrop Kareyan on 3/7/18.
//  Copyright © 2018 Mesrop Kareyan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate
            .sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled =  FBSDKApplicationDelegate
            .sharedInstance()
            .application(application,
                         open: url,
                         sourceApplication: sourceApplication,
                         annotation: annotation)
        return handled
    }

}

