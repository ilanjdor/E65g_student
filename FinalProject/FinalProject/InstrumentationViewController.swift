//
//  InstrumentationViewController.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//
/*  Tab icons from: http://www.flaticon.com/packs/ios7-set-lined-1

  <div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

  App icon from http://www.directindustry.com/prod/teledyne-dalsa/product-25439-1174957.html
 */

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
// Might have been able to replace "isNewTableViewRow" with a notification
// but I'm out of time. It's due in 22 minutes.
var isNewTableViewRow: Bool = false
class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    var dataKeys: [String] = []
    var dataGrids: [GridProtocol] = []
    var tableViewHeader: String = "Configurations"
    var newRowName: String = "New GridEditor Grid"
    var jsonContents: String?
    var index: Int?
    var grid: GridProtocol?
    var gridNameValue: String = ""
    var engine: StandardEngine!
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
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
            self.dataKeys.remove(at: indexPath.row)
            self.dataGrids.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "gridEditor" {
            if !SimulationViewController.tabWasClicked {
                // segue will not occur
                if let index = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: index, animated: true)
                }
                showErrorAlert(withMessage: "You must click Simulation tab once before you can load a configuration."){}
                return false
            }
        }
        // segue will occur
        return true
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can load a new grid.") {}
            return
        }
        isNewTableViewRow = true
        performSegue(withIdentifier: "gridEditor", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if isNewTableViewRow {
            let nextSize = self.engine.rows
            self.index = nil
            self.gridNameValue = self.newRowName
            self.grid = Grid(nextSize, nextSize) as GridProtocol
        } else {
            let indexPath = self.tableView.indexPathForSelectedRow
            self.index = (indexPath?.row)!
            self.gridNameValue = self.dataKeys[index!]
            self.grid = self.dataGrids[index!]
        }
        if let vc = segue.destination as? GridEditorViewController {
            vc.gridNameValue = self.gridNameValue
            vc.grid = self.grid
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
    
    private func fetch() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        fetch()
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)
        
        self.engine = StandardEngine.engine
        self.sizeTextField.text = "\(self.engine.rows)"
        self.sizeStepper.value = Double(self.engine.rows)
        // Note: All refreshRate IBOutlet variables and IBAction functions in this module
        // should really be called 'speed' rather than 'refreshRate' because
        // I invert their values prior to sending them to StandardEngine.
        // Unfortunately, it is 6:58PM EST on 5/8/17 as I write this,
        // and Prof. Simmons said that the deadline is 9:00PM EST
        // so I'm not going to have the time to rewire all of the storyboard items
        // to turn these variables into 'speed' ones.
        // The refreshRate in StandardEngine is still an actual refresh rate
        // and not a speed. Sorry for any confusion. I really wanted to rewire these.
        self.refreshRateSlider.value = self.refreshRateSlider.minimumValue
        self.refreshRateSlider.isEnabled = true
        self.refreshRateTextField.text = "\(self.refreshRateSlider.value)"
        self.refreshRateTextField.isEnabled = true
        
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
            engine.setGrid(rows: size, cols: size)
            sizeTextField.text = "\(size)"
        }
    }
    
    @IBAction func refreshRateTouchDown(_ sender: UITextField) {
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {
                self.refreshRateSlider.value = self.refreshRateSlider.minimumValue
                self.refreshRateTextField.text = "\(self.refreshRateSlider.value)"
            }
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
        speedAdjustNotify()
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func refreshRateSliderTouchDown(_ sender: UISlider) {
        if !SimulationViewController.tabWasClicked {
            showErrorAlert(withMessage: "You must click Simulation tab once before you can change speed.") {
                self.refreshRateSlider.value = self.refreshRateSlider.minimumValue
                self.refreshRateTextField.text = "\(self.refreshRateSlider.value)"
            }
            return
        }
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
