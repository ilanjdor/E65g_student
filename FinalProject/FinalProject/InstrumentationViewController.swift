//
//  InstrumentationViewController.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//
//  Tab icons from: https://icons8.com
//  App icon from http://www.directindustry.com/prod/teledyne-dalsa/product-25439-1174957.html
//

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

var isNewTableViewRow: Bool = false
class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var dataKeys: [String] = []
    var dataGrids: [GridProtocol] = []
    var gridEditorVC: GridEditorViewController?
    var tableViewHeader: String = "Configurations"
    var newRowName: String = "New GridEditor Grid"
    var jsonContents: String?
    var index: Int?
    var grid: GridProtocol?
    var gridNameValue: String = ""
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = dataKeys[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewHeader
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataKeys.remove(at: indexPath.row)
            dataGrids.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
     What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
     
     1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been 
     clicked for the first time (so that its viewDidLoad method can execute)
     
     If I knew of a more elegant or idiomatic solution to this issue, I would have used it
     */
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "gridEditor" {
            if !SimulationViewController.tabWasClicked {
                // segue will not occur
                if let index = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: index, animated: true)
                }
                self.showErrorAlert(withMessage: "You must click Simulation tab once before you can load a configuration."){}
                return false
            }
        }
        // segue will occur
        return true
    }
    // end of tab click validation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if isNewTableViewRow {
            let nextSize = engine.rows
            index = nil
            gridNameValue = newRowName
            grid = Grid(nextSize, nextSize) as GridProtocol
        } else {
            let indexPath = tableView.indexPathForSelectedRow
            index = (indexPath?.row)!
            gridNameValue = dataKeys[index!]
            grid = dataGrids[index!]
        }
        if let vc = segue.destination as? GridEditorViewController {
            vc.gridNameValue = gridNameValue
            vc.grid = grid
            vc.saveClosure = { newValue in
                if isNewTableViewRow {
                    self.dataKeys.append(newValue)
                    self.dataGrids.append(vc.grid!)
                    self.index = self.dataKeys.count - 1
                } else {
                    self.dataKeys[self.index!] = newValue
                    self.dataGrids[self.index!] = vc.grid!
                }
                self.tableView.reloadData()
                isNewTableViewRow = false
            }
        }
    }
    
    func fetch() {
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }
            //print(json)
            let jsonArray = json as! NSArray
            for item in jsonArray {
                var nextIntPairsDict: [String:[[Int]]] = [:]
                var nextSize: Int
                let nextItem = item as! NSDictionary
                let jsonTitle = nextItem["title"] as! String
                self.dataKeys.append(jsonTitle)
                let jsonContents = nextItem["contents"] as! [[Int]]
                nextSize = 1
                for intPair in jsonContents {
                    if intPair[0] > nextSize { nextSize = intPair[0] }
                    if intPair[1] > nextSize { nextSize = intPair[1] }
                }
                nextSize = (nextSize + 1) * 2
                nextIntPairsDict["alive"] = jsonContents
                let nextCellInitializer = Grid.makeCellInitializer(intPairsDict: nextIntPairsDict)
                let nextGrid = Grid(nextSize, nextSize, cellInitializer: nextCellInitializer) as GridProtocol
                self.dataGrids.append(nextGrid)
            }
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can load a new grid.") {}
            return
        }
        isNewTableViewRow = true
        self.performSegue(withIdentifier: "gridEditor", sender: nil)
        // end of tab click validation
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        fetch()
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)
        
        self.engine = StandardEngine.engine
        sizeTextField.text = "\(engine.rows)"
        sizeStepper.value = Double(engine.rows)
        refreshRateSlider.value = refreshRateSlider.minimumValue
        refreshRateSlider.isEnabled = true
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = true
        
        let nc = NotificationCenter.default
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "EngineGridChanged"),
            object: nil,
            queue: nil) { (n) in
                self.sizeTextField.text = "\(self.engine.rows)"
                self.sizeStepper.value = Double(self.engine.rows)
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "SimulationStateSaved"),
            object: nil,
            queue: nil) { (n) in
                if self.index == nil {
                    self.showErrorAlert(withMessage: "You must select a row in the table view " +
                    "before you can save a simulation grid to the grid editor."){}
                    return
                }
                // engine is static, so we don't need userInfo to discern
                // its grid but I'm including the commented-out code
                // as evidence that I know how to do so:
                //
                // let engine = n.userInfo?["engine"] as! StandardEngine
                // self.grid = engine.grid
                self.grid = self.engine.grid
                if isNewTableViewRow {
                    self.dataKeys.append(self.gridNameValue)
                    self.dataGrids.append(self.grid!)
                } else {
                    self.dataKeys[self.index!] = self.gridNameValue
                    self.dataGrids[self.index!] = self.grid!
                }
                isNewTableViewRow = false
                // User must select the desired table view row to retrieve the updated grid
                _ = self.navigationController?.popViewController(animated: true)
        }
        
        nc.addObserver(
            forName: Notification.Name(rawValue: "SpeedSwitchTurnedOn"),
            object: nil,
            queue: nil) { (n) in
                self.engine.refreshRate = Double(1 / self.refreshRateSlider.value)
        }
    }
    
    @IBAction func sizeTouchDown(_ sender: UITextField) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change size.") {}
            return
        }
        // end of tab click validation
    }
    @IBAction func sizeEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        if Float(val) < 1 || Float(val) > Float(sizeStepper.maximumValue) {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        sizeStepper.value = Double(val)
        updateGridSize(size: val)
    }
    
    @IBAction func sizeEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func sizeStepperTouchDown(_ sender: UIStepper) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change size.") {}
            return
        }
        // end of tab click validation
    }
    
    @IBAction func sizeStep(_ sender: UIStepper) {
        let val = Int(sizeStepper.value)
        updateGridSize(size: val)
    }
    
    private func updateGridSize(size: Int) {
        if engine.rows != size {
            //engine.refreshRate = 0.0
            engine.setGrid(rows: size, cols: size)
            sizeTextField.text = "\(size)"
        }
    }
    
    @IBAction func refreshRateSliderTouchDown(_ sender: UISlider) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {
                //self.engine.refreshRate = 0.0
                self.refreshRateSlider.value = self.refreshRateSlider.minimumValue
                self.refreshRateTextField.text = "\(self.refreshRateSlider.value)"
            }
            return
        }
        // end of tab click validation
    }
    
    @IBAction func refreshRateTouchDown(_ sender: UITextField) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         If I knew of a more elegant or idiomatic solution to this issue, I would have used it
         */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {
                //self.engine.refreshRate = 0.0
                self.refreshRateSlider.value = self.refreshRateSlider.minimumValue
                self.refreshRateTextField.text = "\(self.refreshRateSlider.value)"
            }
            return
        }
        // end of tab click validation
    }
    
    @IBAction func refreshRateEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Double(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(1 / self.engine.refreshRate)"
            }
            return
        }
        if Float(val) < refreshRateSlider.minimumValue || Float(val) > refreshRateSlider.maximumValue {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(1 / self.engine.refreshRate)"
            }
            return
        }
        refreshRateSlider.value = Float(val)
        speedAdjustNotify()
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func refreshRateSlideMove(_ sender: UISlider) {
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        speedAdjustNotify()
    }
    
    func speedAdjustNotify() {
        let nc = NotificationCenter.default
        nc.post(Notification(
                    name: Notification.Name(rawValue: "SpeedWasAdjusted"),
                    object: nil,
                    userInfo: ["none" : "none"]))
    }
    
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
