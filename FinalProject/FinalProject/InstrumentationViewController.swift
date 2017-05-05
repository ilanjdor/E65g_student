//
//  InstrumentationViewController.swift
//

//Tab icons from: https://icons8.com
//App icon from http://www.directindustry.com/prod/teledyne-dalsa/product-25439-1174957.html

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

var dataKeys: [String] = []
//var dataValues: [[[Int]]] = []
//var dataSizes: [Int] = []
var dataGrids: [GridProtocol] = []
var gridEditorVC: GridEditorViewController?
var isNewTableViewRow: Bool = false
var rowsAddedCount: Int = 0

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    var jsonContents: String?

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
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataKeys.remove(at: indexPath.row)
            dataGrids.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var index: Int = 0
        var gridNameValue: String = ""
        
        if isNewTableViewRow {
            index = dataKeys.count - 1
        } else {
            let indexPath = tableView.indexPathForSelectedRow
            index = (indexPath?.row)!
        }
        gridNameValue = dataKeys[index]
        
        if let vc = segue.destination as? GridEditorViewController {
            vc.gridNameValue = gridNameValue
            vc.grid = dataGrids[index]
            vc.saveClosure = { newValue in
                if isNewTableViewRow {
                    dataKeys.remove(at: index)
                    dataGrids.remove(at: index)
                    dataKeys.append(newValue)
                    dataGrids.append(vc.grid!)
                } else {
                    if newValue == gridNameValue {
                        dataKeys[index] = newValue
                        dataGrids[index] = vc.grid!
                    } else {
                        dataKeys.append(newValue)
                        dataGrids.append(vc.grid!)
                    }
                }
                self.tableView.reloadData()
            }
        }
        isNewTableViewRow = false
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
            print(json)
            let jsonArray = json as! NSArray
            for item in jsonArray {
                var nextSize: Int
                let nextItem = item as! NSDictionary
                let jsonTitle = nextItem["title"] as! String
                dataKeys.append(jsonTitle)
                let jsonContents = nextItem["contents"] as! [[Int]]
                nextSize = 1
                for intPair in jsonContents {
                    if intPair[0] > nextSize {
                        nextSize = intPair[0]
                    }
                    if intPair[1] > nextSize {
                        nextSize = intPair[1]
                    }
                }
                /*if nextSize % 2 == 1 {
                    nextSize = nextSize + 1
                }
                nextSize = nextSize * 3 / 2*/
                nextSize = nextSize * 2
                //dataSizes.append(nextSize)
                let nextCellInitializer = Grid.makeCellInitializer(intPairs: jsonContents)
                let nextGrid = Grid(nextSize, nextSize, cellInitializer: nextCellInitializer) as GridProtocol
                dataGrids.append(nextGrid)
            }
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
            //print(dataKeys)
            //print(dataValues)
        }
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        isNewTableViewRow = true
        //rowsAddedCount += 1
        //dataKeys.append("New GridEditor Grid " + "\(rowsAddedCount)")
        dataKeys.append("New GridEditor Grid")
        let nextSize = engine.rows
        let nextGrid = Grid(nextSize, nextSize) as GridProtocol
        dataGrids.append(nextGrid)
        //self.tableView.reloadData()
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
        // Do any additional setup after loading the view, typically from a nib.
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)

        engine = StandardEngine.getEngine()
        sizeTextField.text = "\(engine.rows)"
        sizeStepper.value = Double(engine.rows)
        refreshRateSlider.value = refreshRateSlider.minimumValue
        refreshRateSlider.isEnabled = true
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = true
        engine.prevRefreshRate = Double(refreshRateSlider.value)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func sizeStep(_ sender: UIStepper) {
        let val = Int(sizeStepper.value)
        updateGridSize(size: val)
    }
    
    private func updateGridSize(size: Int) {
        //StatisticsViewController.clearStatistics()
        if engine.rows != size {
            if engine.refreshRate > 0.0 {
                engine.prevRefreshRate = engine.refreshRate
            }
            engine.refreshRate = 0.0
            // send notification to turn off switch in SimulationViewController
            engine.setGrid(rows: size, cols: size)
            sizeTextField.text = "\(size)"
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
    /*@IBAction func refreshOnOff(_ sender: UISwitch) {
        if sender.isOn {
            refreshRateTextField.isEnabled = true
            refreshRateSlider.isEnabled = true
            engine.refreshRate = Double(refreshRateSlider.value)
        } else {
            refreshRateSlider.isEnabled = false
            refreshRateTextField.isEnabled = false
            engine.refreshRate = 0.0
        }
    }*/
    
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
