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
    var saveClosure: ((String) -> Void)?//((String, Bool, Int) -> Void)?
    //var segueBack: Bool = true
    var tableViewIndex: Int?
    //var isNewTableViewRow: Bool = false
    //var changesSaved: Bool = false
    //var observer: NSObjectProtocol?
    //var observer2: NSObjectProtocol?
    
    var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return grid![row,col] }
        set { grid![row,col] = newValue }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        isNewTableViewRow = false
        /*let nc = NotificationCenter.default
         //nc.removeObserver(observer!)
         nc.removeObserver(observer2!)*/
        //isNewTableViewRow = false
        if (self.isMovingFromParentViewController){
            GridView.useEngineGrid = true
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*    @available(iOS 4.0, *)
     open func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Swift.Void) -> NSObjectProtocol*/
    
    override func viewWillAppear(_ animated: Bool) {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        self.grid!.setConfiguration()
        //configuration = grid!.getConfiguration()
        //let size = grid!.size.rows
        let defaults = UserDefaults.standard
        defaults.set(self.grid!.configuration, forKey: "configuration")
        defaults.set(self.grid!.size.rows, forKey: "size")
        //self.segueBack = true
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            //changesSaved = true
            saveClosure(newValue)//, changesSaved) //, tableViewIndex)//, self.segueBack)
            engine = StandardEngine.getEngine()
            //engine.grid = grid!
            engine.setGrid(grid: self.grid!)//.rows, self.grid!.cols, self.
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
