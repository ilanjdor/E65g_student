//
//  StatisticsViewController.swift
//

import UIKit

class StatisticsViewController: UIViewController, GridViewDataSource {
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
    
    static var wasManualTouch: Bool = false
    
    static var aliveCount: Int = 0
    static var emptyCount: Int = 0
    static var bornCount: Int = 0
    static var diedCount: Int = 0
    
    static var engine: StandardEngine!
    static var gridViewDataSource: GridViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        StatisticsViewController.engine = StandardEngine.getEngine()
        StatisticsViewController.gridViewDataSource = self
        aliveCountTextField.isEnabled = false
        emptyCountTextField.isEnabled = false
        bornCountTextField.isEnabled = false
        diedCountTextField.isEnabled = false
        StatisticsViewController.clearStatistics()
        StatisticsViewController.calculateStatistics()
        displayStatistics()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                //self.clearStatistics()
                if !StatisticsViewController.wasManualTouch {
                    StatisticsViewController.calculateStatistics()
                    self.displayStatistics()
                }
                StatisticsViewController.wasManualTouch = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return StatisticsViewController.engine.grid[row,col] }
        set { StatisticsViewController.engine.grid[row,col] = newValue }
    }
    
    static func clearStatistics() {
        StatisticsViewController.aliveCount = 0
        StatisticsViewController.emptyCount = 0
        StatisticsViewController.bornCount = 0
        StatisticsViewController.diedCount = 0
    }
    
    static private func calculateStatistics() {
        (0 ..< StatisticsViewController.engine.cols).forEach { i in
            (0 ..< StatisticsViewController.engine.rows).forEach { j in
                if let grid = StatisticsViewController.gridViewDataSource {
                    switch grid[(i, j)] {
                        case .alive:
                            StatisticsViewController.aliveCount += 1
                        case .empty:
                            StatisticsViewController.emptyCount += 1
                        case .born:
                            StatisticsViewController.bornCount += 1
                        case .died:
                            StatisticsViewController.diedCount += 1
                    }
                }
            }
        }
    }
    
    private func displayStatistics() {
        aliveCountTextField.text = "\(StatisticsViewController.aliveCount)"
        emptyCountTextField.text = "\(StatisticsViewController.emptyCount)"
        bornCountTextField.text = "\(StatisticsViewController.bornCount)"
        diedCountTextField.text = "\(StatisticsViewController.diedCount)"
    }
}
