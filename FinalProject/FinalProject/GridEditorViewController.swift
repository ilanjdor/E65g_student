//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Ilan on 4/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {//, EditorDelegate {
    //static var rows: Int = 0
    //static var cols: Int = 0
    //static var intPairs: [[Int]] = []

    @IBOutlet weak var gridNameTextField: UITextField!
    @IBOutlet weak var gridView: GridView!
    
    var grid: GridProtocol?
    var gridNameValue: String?
    //var intPairs: [[Int]]?
    var configuration: [String:[[Int]]]?
    //var configurationAndSize: [String: [String: Int], [String:[[Int]]]]?
    var saveClosure: ((String, Bool) -> Void)?//((String, Bool) -> Void)?
    //var segueBack: Bool = true
    var isNewTableViewRow: Bool = false
    
    var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return grid![row,col] }
        set { grid![row,col] = newValue }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            GridView.useEngineGrid = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Grid Editor";
        gridView.gridViewDataSource = self
        gridView.rows = (grid?.size.rows)!
        gridView.cols = (grid?.size.cols)!
        navigationController?.isNavigationBarHidden = false
        if let gridNameValue = gridNameValue {
            gridNameTextField.text = gridNameValue
        }
        GridView.useEngineGrid = false
        self.gridView.setNeedsDisplay()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        
        let name2 = Notification.Name(rawValue: "SimulationStateSaved")
        nc.addObserver(
            forName: name2,
            object: nil,
            queue: nil) { (n) in
                //self.configuration = n.userInfo?["configuration"] as! [String : [[Int]]]?
                let engine = n.userInfo?["engine"] as! StandardEngine
                self.grid = engine.grid //.userInfo?["engine"].grid as! GridProtocol?
                //self.engine = StandardEngine.getEngine()
                //self.engine.setFancierGrid(rows: recoveredSize as! Int, cols: recoveredSize as! Int, intPairsDict: recoveredConfiguration as! [String : [[Int]]])
                GridView.useEngineGrid = false
                self.gridView.setNeedsDisplay()
                //self.segueBack = false
                if let newValue = self.gridNameTextField.text,
                    let saveClosure = self.saveClosure {
                    saveClosure(newValue, self.isNewTableViewRow)//, self.segueBack)
                    //self.engine = StandardEngine.getEngine()
                    //self.engine.grid = self.grid!
                    //notify()
                    //StatisticsViewController.clearStatistics()
                    //_ = self.navigationController?.popViewController(animated: true)
                }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        grid!.setConfiguration()
        configuration = grid!.getConfiguration()
        let size = grid!.size.rows
        let defaults = UserDefaults.standard
        defaults.set(configuration, forKey: "configuration")
        defaults.set(size, forKey: "size")
        //self.segueBack = true
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
                saveClosure(newValue, isNewTableViewRow)//, self.segueBack)
                engine = StandardEngine.getEngine()
                engine.grid = grid!
                //notify()
                //StatisticsViewController.clearStatistics()
                _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    /*func notify() {
        //self.configuration?["size"] = self.grid!.size.rows
        //self.configuration?.set(10, forKey:"size")
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridEditorSaved")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["configuration" : configuration!])
        nc.post(n)
    }*/
}
