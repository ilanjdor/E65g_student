//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Ilan on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    @IBOutlet weak var gridView: GridView!
    
    var engine: StandardEngine!
    var gridDataSource: GridViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let size = gridView.size
        //engine = StandardEngine(rows: size, cols: size)
        engine = StandardEngine.getEngine()
        engine.delegate = self
        gridView.gridViewDataSource = self
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    @IBAction func next(_ sender: Any) {
        if self.gridView.gridViewDataSource != nil {
            engine.grid = self.engine.step()
        }
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
}
