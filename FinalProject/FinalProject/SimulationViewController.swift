//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Ilan on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource {//, EngineDelegate {
    static var isEngineGrid: Bool = true
    
    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!
    
    @IBAction func refreshOnOff(_ sender: UISwitch) {
        if sender.isOn {
            //            refreshRateTextField.isEnabled = true
            //            refreshRateSlider.isEnabled = true
            engine.refreshRate = engine.prevRefreshRate
        } else {
            //            refreshRateSlider.isEnabled = false
            //            refreshRateTextField.isEnabled = false
            engine.refreshRate = 0.0
        }
    }
    
    //var gridSize: Int = 15
    //var grid: GridProtocol?
    //var intPairs: [[Int]]?
    
    var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    /*override func viewWillAppear(_ animated: Bool) {
     // this runs when user clicks on Simulation tab!
     }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.getEngine()
        //engine.delegate = self
        /*engine.updateClosure = { (grid) in
         self.gridView.setNeedsDisplay()
         }*/
        gridView.gridViewDataSource = self
        refreshOnOffSwitch.isOn = false
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.engine = StandardEngine.getEngine()
                self.gridView.gridViewDataSource = self
                self.gridView.setNeedsDisplay()
                /*if GridEditorViewController.isGridEditorGrid {
                 GridEditorViewController.isGridEditorGrid = false
                 self.gridView.setNeedsDisplay()
                 } else {
                 self.gridView.setNeedsDisplay()
                 }*/
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
     if(item.tag == 1) {
     //your code for tab item 1
     }
     else if(item.tag == 2) {
     //your code for tab item 2
     self.gridView.setNeedsDisplay()
     }
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: Any) {
        if self.gridView.gridViewDataSource != nil {
            //engine.grid = self.engine.step()
            _ = self.engine.step()
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        engine.setGrid(rows: engine.rows, cols: engine.cols)
        //StatisticsViewController.clearStatistics()
    }
    
    @IBAction func save(_ sender: Any) {
        engine.grid.setConfiguration()
        let configuration = engine.grid.configuration
        let size = engine.grid.size.rows
        let defaults = UserDefaults.standard
        defaults.set(configuration, forKey: "configuration")
        defaults.set(size, forKey: "size")
        notify()//
        //let recoveredConfiguration = defaults.object(forKey: "configuration")
        //let recoveredSize = defaults.object(forKey: "size")
        //print(recoveredConfiguration ?? [])
        //print(recoveredSize ?? 0)
    }
    
    /*func engineDidUpdate(withGrid: GridProtocol) {
     //self.gridView.gridViewDataSource = withGrid as? GridViewDataSource
     /*let nc = NotificationCenter.default
     let name = Notification.Name(rawValue: "EngineUpdate")
     let n = Notification(name: name,
     object: nil,
     userInfo: ["engine" : engine])
     nc.post(n)*/
     }*/
    
    func notify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SimulationStateSaved")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : engine])
        nc.post(n)
    }
}
