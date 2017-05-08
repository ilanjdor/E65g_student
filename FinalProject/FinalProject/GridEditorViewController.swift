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
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can save.") {}
            return
        }
        // end of tab click validation
        
        self.grid!.setConfiguration()
        let defaults = UserDefaults.standard
        defaults.set(self.grid!.configuration, forKey: "configuration")
        defaults.set(self.grid!.size.rows, forKey: "size")
        if let newValue = gridNameTextField.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            engine = StandardEngine.engine
            engine.setGrid(grid: self.grid!)
            SimulationViewController.cycleOccurred = false
            _ = self.navigationController?.popViewController(animated: true)
        }
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
