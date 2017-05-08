//
//  SimulationViewController.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource {
    var cycleOccurred: Bool = false
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!
    
    @IBAction func refreshOnOff(_ sender: UISwitch) {
        /* The following code overcomes item 2 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         2) Actions taking place in SimulationVC before StatisticsVC has been clicked for the time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {
                self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        // end of tab click validation
        
        if self.cycleOccurred {
            showErrorAlert(withMessage: "A cycle has occurred. You must reset the grid, load a new grid "
                + "or manually touch the grid before you can step.") {
                self.engine.refreshRate = 0.0
                self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        if sender.isOn {
            self.speedSwitchTurnedOnNotify()
        } else {
            self.engine.refreshRate = 0.0
        }
    }
    
    var engine: StandardEngine!
    static var tabWasClicked: Bool = false
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.engine
        gridView.gridViewDataSource = self
        refreshOnOffSwitch.isOn = false
        SimulationViewController.tabWasClicked = true
        self.gridView.setNeedsDisplay()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineGridChanged")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        let name2 = Notification.Name(rawValue: "GoLCycled")
        nc.addObserver(
            forName: name2,
            object: nil,
            queue: nil) { (n) in
                self.cycleOccurred = true
                self.showErrorAlert(withMessage: "A cycle has occurred. You must reset the grid, load a new grid "
                    + "or manually touch the grid before you can step.") {}
        }
        
        let name3 = Notification.Name(rawValue: "EngineGridReceivedManualTouch")
        nc.addObserver(
            forName: name3,
            object: nil,
            queue: nil) { (n) in
                self.cycleOccurred = false
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "EngineInitializedOrLoadedOrSteppedGrid"),
            object: nil,
            queue: nil) { (n) in
                self.cycleOccurred = false
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "SpeedWasAdjusted"),
            object: nil,
            queue: nil) { (n) in
                self.engine.refreshRate = 0.0
                self.refreshOnOffSwitch.isOn = false
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "GoLEnded"),
            object: nil,
            queue: nil) { (n) in
                self.engine.refreshRate = 0.0
                self.refreshOnOffSwitch.isOn = false
        }
    }
    
    @IBAction func next(_ sender: Any) {
        /* The following code overcomes item 2 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         2) Actions taking place in SimulationVC before StatisticsVC has been clicked for the time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
        */
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {}
            return
        }
        // end of tab click validation
        
        if self.cycleOccurred {
            showErrorAlert(withMessage: "A cycle has occurred. You must reset the grid, load a new grid "
                + "or manually touch the grid before you can step.") {
                self.engine.refreshRate = 0.0
                self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        if self.gridView.gridViewDataSource != nil {
            _ = self.engine.step()
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.engine.refreshRate = 0.0
        self.refreshOnOffSwitch.isOn = false
        engine.setGrid(rows: engine.rows, cols: engine.cols)
        self.cycleOccurred = false
    }
    
    @IBAction func save(_ sender: Any) {
        engine.grid.setConfiguration()
        let configuration = engine.grid.configuration
        let size = engine.grid.size.rows
        let defaults = UserDefaults.standard
        defaults.set(configuration, forKey: "configuration")
        defaults.set(size, forKey: "size")
        self.notify()
    }

    func notify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SimulationStateSaved")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : engine])
        nc.post(n)
    }
    
    func speedSwitchTurnedOnNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SpeedSwitchTurnedOn")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["none" : "none"])
        nc.post(n)
    }
    
    //MARK: AlertController Handling
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
