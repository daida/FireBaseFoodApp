//
//  AppDelegate.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 18/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: UINavigationController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.rootViewController = UINavigationController(rootViewController: FoodListViewController())
        self.rootViewController.isNavigationBarHidden = false
                
        self.window?.rootViewController = self.rootViewController
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        return true
    }

}

