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
    var saveClosure: ((String) -> Void)?
    private var tableViewIndex: Int?
    private var configuration: [String:[[Int]]]?
    private var engine: StandardEngine!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return self.grid![row,col] }
        set { self.grid![row,col] = newValue }
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        isNewTableViewRow = false
        if (self.isMovingFromParentViewController){
            GridView.useEngineGrid = true
        }
        // The following LOC is to ensure that any potential grid saves
        // from the Simulation view are freshly retrieved from
        // the Instrumentation table view.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Grid Editor";
        self.gridView.gridViewDataSource = self
        self.gridView.rows = (self.grid?.size.rows)!
        self.gridView.cols = (self.grid?.size.cols)!
        self.navigationController?.isNavigationBarHidden = false
        if let gridNameValue = self.gridNameValue {
            self.gridNameTextField.text = gridNameValue
        }
        GridView.useEngineGrid = false
        self.gridView.setNeedsDisplay()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can save.") {}
            return
        }
        
        self.grid!.setConfiguration()
        let defaults = UserDefaults.standard
        defaults.set(self.grid!.configuration, forKey: "configuration")
        defaults.set(self.grid!.size.rows, forKey: "size")
        if let newValue = self.gridNameTextField.text,
            let saveClosure = self.saveClosure {
            saveClosure(newValue)
            self.engine = StandardEngine.engine
            self.engine.setGrid(grid: self.grid!)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: AlertController Handling
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
