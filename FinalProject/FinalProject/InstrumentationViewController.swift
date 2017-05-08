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

var dataKeys: [String] = []
var dataGrids: [GridProtocol] = []
var gridEditorVC: GridEditorViewController?
var tableViewHeader: String = "Configurations"
var isNewTableViewRow: Bool = false
var newRowName: String = "New GridEditor Grid"

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
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
    /*[shouldPerformSegueWithIdentifier: "gridEditor", sender: Any?];
    func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        //super.shouldPerformSegueWithIdentifier() //gridEditor
        return true // or false, depending on what you need
    }*/
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "gridEditor" { // you define it in the storyboard (click on the segue, then Attributes' inspector > Identifier
            
            let segueShouldOccur = SimulationViewController.tabWasClicked/** do whatever you need to set this var to true or false */
            
            if !segueShouldOccur {
                if let index = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: index, animated: true)
                }
                self.showErrorAlert(withMessage: "You must click Simulation tab once before you can load a configuration."){}
                //print("*** NOPE, segue wont occur")
                return false
            }
            else {
                print("*** YEP, segue will occur")
            }
        }
        
        // by default, transition
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            self.showErrorAlert(withMessage: "You must click Simulation tab once before you can load a configuration.") {
                /*if let index = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: index, animated: true)
                }*/
                //return
            }
            return
        }
        
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
                    dataKeys.append(newValue)
                    dataGrids.append(vc.grid!)
                    self.index = dataKeys.count - 1
                } else {
                    dataKeys[self.index!] = newValue
                    dataGrids[self.index!] = vc.grid!
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
                dataKeys.append(jsonTitle)
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
                dataGrids.append(nextGrid)
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
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can load a new grid.") {}
            return
        }
        isNewTableViewRow = true
        self.performSegue(withIdentifier: "gridEditor", sender: nil)
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
        
        engine = StandardEngine.getEngine()
        sizeTextField.text = "\(engine.rows)"
        sizeStepper.value = Double(engine.rows)
        refreshRateSlider.value = refreshRateSlider.minimumValue
        refreshRateSlider.isEnabled = true
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = true
        engine.prevRefreshRate = Double(1 / refreshRateSlider.value)
        
        func test1() {
            let viewController = UIApplication.shared.windows[0].rootViewController?.childViewControllers[2] as? SimulationViewController
            viewController?.viewDidLoad()
        }
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.engine = StandardEngine.getEngine()
                self.sizeTextField.text = "\(self.engine.rows)"
                self.sizeStepper.value = Double(self.engine.rows)
        }
        
        let name2 = Notification.Name(rawValue: "SimulationStateSaved")
        nc.addObserver(
            forName: name2,
            object: nil,
            queue: nil) { (n) in
                if self.index == nil {
                    self.showErrorAlert(withMessage: "You must select a row in the table view " +
                    "before you can save a simulation grid to the grid editor."){}
                    return
                }
                let engine = n.userInfo?["engine"] as! StandardEngine
                self.grid = engine.grid
                if isNewTableViewRow {
                    dataKeys.append(self.gridNameValue)
                    dataGrids.append(self.grid!)
                } else {
                    dataKeys[self.index!] = self.gridNameValue
                    dataGrids[self.index!] = self.grid!
                }
                isNewTableViewRow = false
                // User must select the desired table view row to retrieve the updated grid
                _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sizeTouchDown(_ sender: UITextField) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change size.") {}
            return
        }
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
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change size.") {}
            return
        }
    }
    
    @IBAction func sizeStep(_ sender: UIStepper) {
        let val = Int(sizeStepper.value)
        updateGridSize(size: val)
    }
    
    private func updateGridSize(size: Int) {
        if engine.rows != size {
            if engine.refreshRate > 0.0 {
                engine.prevRefreshRate = engine.refreshRate
            }
            engine.refreshRate = 0.0
            engine.setGrid(rows: size, cols: size)
            sizeTextField.text = "\(size)"
        }
    }
    
    @IBAction func refreshRateSliderTouchDown(_ sender: UISlider) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {}
            self.refreshRateSlider.value = refreshRateSlider.minimumValue
            self.refreshRateTextField.text = "\(refreshRateSlider.value)"
            return
        }
    }
    
    @IBAction func refreshRateTouchDown(_ sender: UITextField) {
        /* The following code overcomes item 1 on my Discussion post, "Problems if Tabs Not Clicked":
         What is the preferred way of overcoming the bugs that, at least in my own app, occur as a result of:
         
         1) Actions taking place in InstrumentationVC and GridEditorVC before SimulationVC has been clicked for the first time (so that its viewDidLoad method can execute)
         
         Insofar as a more elegant or idiomatic solution to that problem exists, it is useless to me at the moment
         for the sole reason that I don't actually have it (or, if the solution was addressed in a lecture or section, I don't recall it) */
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {}
            return
        }
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
        engine.prevRefreshRate = 1 / val
        engine.refreshRate = 1 / val
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func refreshRateSlideMove(_ sender: UISlider) {
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        engine.prevRefreshRate = Double(1 / refreshRateSlider.value)
        engine.refreshRate = Double(1 / refreshRateSlider.value)
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
    
    /*var refreshAlert = UIAlertController(title: "Refresh", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
    
    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
    print("Handle Ok logic here")
    }))
    
    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
    print("Handle Cancel Logic here")
    }))
    
    present(refreshAlert, animated: true, completion: nil)*/
}
