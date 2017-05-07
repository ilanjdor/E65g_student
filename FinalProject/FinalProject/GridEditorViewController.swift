//
//  GridEditorViewController.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource {
    @IBOutlet weak var gridNameTextField: UITextField!
    @IBOutlet weak var gridView: GridView!
    
    var grid: GridProtocol?
    var gridNameValue: String?
    var configuration: [String:[[Int]]]?
    var saveClosure: ((String) -> Void)?
    var tableViewIndex: Int?
    var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return grid![row,col] }
        set { grid![row,col] = newValue }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        isNewTableViewRow = false
        if (self.isMovingFromParentViewController){
            GridView.useEngineGrid = true
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        self.grid!.setConfiguration()
        let defaults = UserDefaults.standard
        defaults.set(self.grid!.configuration, forKey: "configuration")
        defaults.set(self.grid!.size.rows, forKey: "size")
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            engine = StandardEngine.getEngine()
            engine.setGrid(grid: self.grid!)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
