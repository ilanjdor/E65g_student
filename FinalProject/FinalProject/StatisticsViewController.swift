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
    static var tabWasClicked: Bool = false
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!
    private var statistics: [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aliveCountTextField.isEnabled = false
        self.bornCountTextField.isEnabled = false
        self.diedCountTextField.isEnabled = false
        self.emptyCountTextField.isEnabled = false
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
        self.aliveCountTextField.text = "\(self.statistics["alive"]!)"
        self.bornCountTextField.text = "\(self.statistics["born"]!)"
        self.diedCountTextField.text = "\(self.statistics["died"]!)"
        self.emptyCountTextField.text = "\(self.statistics["empty"]!)"
    }
}
