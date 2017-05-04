//
//  StatisticsViewController.swift
//

import UIKit

class StatisticsViewController: UIViewController, GridViewDataSource {
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
        
    var aliveCount: Int = 0
    var emptyCount: Int = 0
    var bornCount: Int = 0
    var diedCount: Int = 0
    
    var engine: StandardEngine!
    var gridViewDataSource: GridViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.getEngine()
        gridViewDataSource = self
        aliveCountTextField.isEnabled = false
        emptyCountTextField.isEnabled = false
        bornCountTextField.isEnabled = false
        diedCountTextField.isEnabled = false
        clearStatistics()
        calculateStatistics()
        displayStatistics()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                //self.clearStatistics()
                if !GridView.wasManualTouch {
                    self.calculateStatistics()
                    self.displayStatistics()
                }
                GridView.wasManualTouch = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    func clearStatistics() {
        aliveCount = 0
        emptyCount = 0
        bornCount = 0
        diedCount = 0
    }
    
    private func calculateStatistics() {
        (0 ..< engine.cols).forEach { i in
            (0 ..< engine.rows).forEach { j in
                if let grid = gridViewDataSource {
                    switch grid[(i, j)] {
                        case .alive:
                            aliveCount += 1
                        case .empty:
                            emptyCount += 1
                        case .born:
                            bornCount += 1
                        case .died:
                            diedCount += 1
                    }
                }
            }
        }
    }
    
    private func displayStatistics() {
        aliveCountTextField.text = "\(aliveCount)"
        emptyCountTextField.text = "\(emptyCount)"
        bornCountTextField.text = "\(bornCount)"
        diedCountTextField.text = "\(diedCount)"
    }
}
