//
//  TabBarController.swift
//  FinalProject
//
//  Created by Ilan on 5/5/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit
import Foundation

var items: [UITabBarItem]?
class TabBarController: UITabBarController {
    /*override func viewDidLoad() {
        /*if let items = tabBar.items as [UITabBarItem]! {
            if items.count > 0 {
                items[1].isEnabled = false
            }
        }*/
        items = tabBar.items as [UITabBarItem]!
        items?[1].isEnabled = false
    }*/
    
    static func canSelectSimulationTab(isEnabled: Bool) {
        items?[1].isEnabled = isEnabled
    }
    
    /*static func enableSimulationTab() {
        items?[1].isEnabled = true
    }
    
    static func disableSimulationTab() {
        items?[1].isEnabled = false
    }*/
}
