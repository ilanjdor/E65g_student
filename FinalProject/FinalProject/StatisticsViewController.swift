//
//  StatisticsViewController.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!

    static var tabWasClicked: Bool = false
    var statistics: [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aliveCountTextField.isEnabled = false
        bornCountTextField.isEnabled = false
        diedCountTextField.isEnabled = false
        emptyCountTextField.isEnabled = false
        StatisticsViewController.tabWasClicked = true
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "StatisticsUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.statistics = n.userInfo!["statistics"] as! [String:Int]
                self.displayStatistics()
        }
    }
    
    private func displayStatistics() {
        aliveCountTextField.text = "\(self.statistics["alive"]!)"
        bornCountTextField.text = "\(self.statistics["born"]!)"
        diedCountTextField.text = "\(self.statistics["died"]!)"
        emptyCountTextField.text = "\(self.statistics["empty"]!)"
    }
}
