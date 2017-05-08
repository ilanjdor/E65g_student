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
    static var tabWasClicked: Bool = false
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!
    private var cycleOccurred: Bool = false
    private var configuration: [String:[[Int]]]?
    private var engine: StandardEngine!
    
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
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "EngineGridReceivedManualTouch"),
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
            forName: Notification.Name(rawValue: "EngineGridChanged"),
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "EngineGridInitializedOrLoadedOrStepped"),
            object: nil,
            queue: nil) { (n) in
                self.cycleOccurred = false
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "GoLEnded"),
            object: nil,
            queue: nil) { (n) in
                self.engine.refreshRate = 0.0
                self.refreshOnOffSwitch.isOn = false
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "GoLCycled"),
            object: nil,
            queue: nil) { (n) in
                self.cycleOccurred = true
                self.showErrorAlert(withMessage: "A cycle has occurred. You must reset the grid, load a new grid "
                    + "or manually touch the grid before you can step.") {}
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.engine.refreshRate = 0.0
        self.refreshOnOffSwitch.isOn = false
        engine.setGrid(rows: engine.rows, cols: engine.cols)
        self.cycleOccurred = false
    }
    
    @IBAction func save(_ sender: Any) {
        self.engine.grid.setConfiguration()
        let configuration = engine.grid.configuration
        let size = engine.grid.size.rows
        let defaults = UserDefaults.standard
        defaults.set(configuration, forKey: "configuration")
        defaults.set(size, forKey: "size")
        simulationStateSavedNotify()
    }
    
    @IBAction func next(_ sender: Any) {
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {}
            return
        }
        
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
    
    @IBAction func refreshOnOff(_ sender: UISwitch) {
        if !StatisticsViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Statistics tab once before you can step.") {
                self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        
        if self.cycleOccurred {
            showErrorAlert(withMessage: "A cycle has occurred. You must reset the grid, load a new grid "
                + "or manually touch the grid before you can step.") {
                    self.engine.refreshRate = 0.0
                    self.refreshOnOffSwitch.isOn = false
            }
            return
        }
        if sender.isOn {
            speedSwitchTurnedOnNotify()
        } else {
            self.engine.refreshRate = 0.0
        }
    }
    
    private let nc = NotificationCenter.default

    private func simulationStateSavedNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "SimulationStateSaved"),
                    object: nil,
                    userInfo: ["engine" : engine]))
    }
    
    private func speedSwitchTurnedOnNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "SpeedSwitchTurnedOn"),
                    object: nil,
                    userInfo: ["none" : "none"]))
    }
    
    private func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
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
