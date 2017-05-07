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
        if sender.isOn {
            engine.refreshRate = engine.prevRefreshRate
        } else {
            engine.refreshRate = 0.0
        }
    }
    
    var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.getEngine()
        gridView.gridViewDataSource = self
        refreshOnOffSwitch.isOn = false
        
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
}
