//
//  AppDelegate.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var engine: StandardEngine!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let defaults = UserDefaults.standard
        let recoveredConfiguration = defaults.object(forKey: "configuration") ?? [:]
        let recoveredSize = defaults.object(forKey: "size") ?? StandardEngine.defaultGridSize
        engine = StandardEngine.getEngine()
        engine.setGrid(rows: recoveredSize as! Int, cols: recoveredSize as! Int, intPairsDict: recoveredConfiguration as! [String : [[Int]]])
        // The following code ensures that the subsequent launch loads the standard defaults
        // unless the user saves a configuration during the current session
        defaults.set([:], forKey: "configuration")
        defaults.set(StandardEngine.defaultGridSize, forKey: "size")
        
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        /*if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mySimulationVC = storyboard.instantiateViewController(withIdentifier: "mySimulationViewController")
        mySimulationVC.loadView()
        mySimulationVC.viewDidLoad()
        
        let myStatisticsVC = storyboard.instantiateViewController(withIdentifier: "myStatisticsViewController")
        myStatisticsVC.loadView()
        myStatisticsVC.viewDidLoad()*/    
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
