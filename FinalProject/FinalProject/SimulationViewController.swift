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
    static var isEngineGrid: Bool = true
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!
    
    @IBAction func refreshOnOff(_ sender: UISwitch) {
        /* The following code overcomes item 2 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         2) Actions taking place in SimulationVC before StatisticsVC has been clicked for the time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {
                self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        
        if sender.isOn {
            engine.refreshRate = engine.prevRefreshRate
        } else {
            engine.refreshRate = 0.0
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
        engine = StandardEngine.getEngine()
        gridView.gridViewDataSource = self
        refreshOnOffSwitch.isOn = false
        SimulationViewController.tabWasClicked = true
        self.gridView.setNeedsDisplay()
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                //self.engine = StandardEngine.getEngine()
                //self.gridView.gridViewDataSource = self
                self.gridView.setNeedsDisplay()
        }
    }
    
    @IBAction func next(_ sender: Any) {
        /* The following code overcomes item 2 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         2) Actions taking place in SimulationVC before StatisticsVC has been clicked for the time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {}
            return
        }
        if self.gridView.gridViewDataSource != nil {
            _ = self.engine.step()
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        engine.setGrid(rows: engine.rows, cols: engine.cols)
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
