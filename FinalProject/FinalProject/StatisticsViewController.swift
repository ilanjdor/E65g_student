//
//  StatisticsViewController.swift
//

import UIKit

class StatisticsViewController: UIViewController {//, GridViewDataSource {
    @IBOutlet weak var aliveCountTextField: UITextField!
    @IBOutlet weak var bornCountTextField: UITextField!
    @IBOutlet weak var diedCountTextField: UITextField!
    @IBOutlet weak var emptyCountTextField: UITextField!
        
    /*var aliveCount: Int = 0
    var emptyCount: Int = 0
    var bornCount: Int = 0
    var diedCount: Int = 0*/
    
    //var engine: StandardEngine!
    //var gridViewDataSource: GridViewDataSource?
    var statistics: [String:Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //engine = StandardEngine.getEngine()
        //gridViewDataSource = self
        aliveCountTextField.isEnabled = false
        bornCountTextField.isEnabled = false
        diedCountTextField.isEnabled = false
        emptyCountTextField.isEnabled = false
        //clearStatistics()
        //calculateStatistics()
        //displayStatistics()
        
        /*let nc = NotificationCenter.default
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
        }*/
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "StatisticsUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
<<<<<<< HEAD
                self.statistics = n.userInfo!["statistics"] as! [String:Int]
=======
                self.statistics = n.userInfo?["statistics"] as! [String:Int]
>>>>>>> refs/remotes/origin/master
                self.displayStatistics()
        }
        
        /*let name = Notification.Name(rawValue: "GridStep")
        nc.addObserver(
            forName: name2,
            object: nil,
            queue: nil) { (n) in
                self.intPairsDict = n.userInfo?["intPairsDict"] as? [String:[[Int]]]
                
                if !GridView.wasManualTouch {
                    self.calculateStatistics()
                    self.displayStatistics()
                }
                GridView.wasManualTouch = false
        }
        
        func stepNotify() {
            let nc = NotificationCenter.default
            let name = Notification.Name(rawValue: "GridStep")
            let n = Notification(name: name,
                                 object: nil,
                                 userInfo: ["statistics" : self.grid.getStatistics()])
            nc.post(n)
        }*/
        
        /*func statisticsNotify() {
            let nc = NotificationCenter.default
            let name = Notification.Name(rawValue: "StatisticsUpdate")
            let n = Notification(name: name,
                                 object: nil,
                                 userInfo: ["statistics" : self.grid.getStatistics()])
            nc.post(n)
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayStatistics() {
<<<<<<< HEAD
        print ("\(self.statistics["alive"])")
=======
>>>>>>> refs/remotes/origin/master
        aliveCountTextField.text = "\(self.statistics["alive"]!)"
        bornCountTextField.text = "\(self.statistics["born"]!)"
        diedCountTextField.text = "\(self.statistics["died"]!)"
        emptyCountTextField.text = "\(self.statistics["empty"]!)"
    }
    
    /*public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }*/
    
    /*func clearStatistics() {
        aliveCount = 0
        emptyCount = 0
        bornCount = 0
        diedCount = 0
    }*/
    
    /*private func calculateStatistics() {
        var empty = engine.rows * engine.cols
        
        if let alive = intPairsDict?["alive"]?.count {
            aliveCount += alive
            empty -= alive
        }
        if let born = intPairsDict?["born"]?.count {
            bornCount += born
            empty -= born
        }
        if let died = intPairsDict?["died"]?.count {
            diedCount += died
            empty -= died
        }
        emptyCount += empty

        /*(0 ..< engine.cols).forEach { i in
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
        }*/
    }*/
    
    /*private func displayStatistics() {
        aliveCountTextField.text = "\(aliveCount)"
        emptyCountTextField.text = "\(emptyCount)"
        bornCountTextField.text = "\(bornCount)"
        diedCountTextField.text = "\(diedCount)"
    }*/
}
