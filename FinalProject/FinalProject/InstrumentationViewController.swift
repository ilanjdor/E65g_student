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
            var newData = dataKeys
            newData.remove(at: indexPath.row)
            dataKeys = newData as [String]
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            //let fruitValue = data[indexPath.section][indexPath.row]
            //let textViewValue = jsonContents
            //let intPairs = dataValues[indexPath.row]
            let gridNameValue = dataKeys[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                //vc.fruitValue = fruitValue
                //vc.intPairs = intPairs
                //vc.textViewValue = jsonContents
                /*vc.saveClosure = { newValue in
                    data[indexPath.section][indexPath.row] = newValue*/
                /*vc.saveClosure = { newValue in
                    dataKeys[indexPath.row] = newValue
                    self.tableView.reloadData()
                }*/
                //vc.gridSize = dataSizes[indexPath.row]
                
                vc.gridNameValue = gridNameValue
                vc.grid = dataGrids[indexPath.row]
                vc.saveClosure = { newValue in
                    if newValue == gridNameValue {
                        dataKeys[indexPath.row] = newValue
                        dataGrids[indexPath.row] = vc.grid!
                    } else {
                        dataKeys.append(newValue)
                        dataGrids.append(vc.grid!)
                        
                        /*public let lazyPositions = { (size: GridSize) in
                            return (0 ..< size.rows)
                                .lazy
                                .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
                                .flatMap { $0 }
                                .map { GridPosition($0) }
                        }*/
                        
                        /*let positions = { (vc.grid.count: Int, vc.grid.living: [GridPosition]) in
                            return (0 ..< vc.grid.count)
                                .map { (row: ($1).row, col: ($1).col) }
                            }*/
                        
                        //dataValues.append(vc.grid!.living as! [[Int]])
                        /*var dataValues: [[[Int]]] = []
                         var dataSizes: [Int] = []
                         var dataGrids: [GridProtocol] = []*/
                    }
                    self.tableView.reloadData()
                }
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
            print(json)
            //let resultString = (json as AnyObject).description
            let jsonArray = json as! NSArray //[NSDictionary]
            //let array = [1, 2, 3]
            //let arrayIterator = jsonArray.makeIterator()
            for item in jsonArray {
                var nextSize: Int
                let nextItem = item as! NSDictionary
                let jsonTitle = nextItem["title"] as! String
                dataKeys.append(jsonTitle)
                let jsonContents = nextItem["contents"] as! [[Int]]
                //dataValues.append(jsonContents)
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
            
                /*let jsonDictionary = jsonArray[0] //as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
            
            print (jsonTitle, jsonContents)*/
            
            //create Grids here!
            //Grid.makeCellInitializer(intPairs: <#T##[[Int]]#>)
            
            OperationQueue.main.addOperation {
                //self.textView.text = resultString
                
                self.tableView.reloadData()
            }
            
            /*let dataKeys = jsonArray.map {_ in
                let jsonDictionary = jsonArray[0]
                jsonDictionary["title"] as! String
                /*var dataDictionary: NSDictionary
                dataDictionary
                jsonArray[$0]*/
            }*/
            print(dataKeys)
            //print(dataValues)
        }
    }
    
    @IBAction func addRow(_ sender: UIBarButtonItem) {
        dataKeys.append("it's a new row!")
        OperationQueue.main.addOperation {
            //self.textView.text = resultString
            
            self.tableView.reloadData()
        }
    }
    
// Ilan's code below
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    //var editor: StandardEditor!
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        //0th
        fetch()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)

        //editor = StandardEditor.getEditor()
        engine = StandardEngine.getEngine()
        sizeTextField.text = "\(engine.rows)"
        sizeStepper.value = Double(engine.rows)
        refreshRateSlider.value = refreshRateSlider.minimumValue
        refreshRateSlider.isEnabled = true
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = true
        engine.prevRefreshRate = Double(refreshRateSlider.value)
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
        StatisticsViewController.clearStatistics()
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
    
    /*@IBAction func refreshRateEditingDidBegin(_ sender: Any) {
        engine.prevRefreshRate = TimeInterval(refreshRateSlider.value)
    }*/

    @IBAction func refreshRateEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Double(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.refreshRate)"
            }
            return
        }
        if Float(val) < refreshRateSlider.minimumValue || Float(val) > refreshRateSlider.maximumValue {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.refreshRate)"
            }
            return
        }
        refreshRateSlider.value = Float(val)
        engine.prevRefreshRate = val
        engine.refreshRate = val
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: UITextField) {
    }

    @IBAction func refreshRateSlideMove(_ sender: UISlider) {
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        engine.prevRefreshRate = Double(refreshRateSlider.value)
        engine.refreshRate = Double(refreshRateSlider.value)
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
