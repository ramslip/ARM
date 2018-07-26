//
//  AppManager.swift
//  arm
//
//  Created by Victor Kalevko on 11.03.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class AppManager {

    func startApp(window: UIWindow?) {
        
        self.configureAppearance()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let defaults = UserDefaults.standard
        
        var viewController: UIViewController!
        
        if let _ = defaults.string(forKey: "login"), let _ = defaults.string(forKey: "password") {
            let startViewController = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
            viewController = startViewController
            BaseContext.sharedContext.initWithBase()
        }
        else {
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            viewController = loginViewController
        }
        window?.rootViewController = NavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
    }
    
    func configureAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.barTintColor = ColorsHelper.blue()
        navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
