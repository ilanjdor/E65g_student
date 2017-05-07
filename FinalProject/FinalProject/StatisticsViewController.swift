//
//  StatisticsViewController.swift
//

import UIKit

class StatisticsViewController: UIViewController {
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!

    var statistics: [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aliveCountTextField.isEnabled = false
        bornCountTextField.isEnabled = false
        diedCountTextField.isEnabled = false
        emptyCountTextField.isEnabled = false
        
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
