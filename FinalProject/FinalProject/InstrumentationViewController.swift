//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

var sectionHeaders = [
    "One", "Two", "Three", "Four", "Five", "Six"
]

var data = [
    [
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date"
    ],
    [
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana"
    ],
    [
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry"
    ],
    [
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Blueberry"
    ]
]

var dataDictionaries: [NSDictionary]? = []
var dataKeys: [String]? = ["key1", "key2"]
var dataValues: [[[Int]]]? = [[[1,1],[2,2],[3,3]],[[4,4],[5,5],[6,7],[9,8]]]

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var jsonContents: String?

    override func viewWillAppear(_ animated: Bool) {
        //1st
        navigationController?.isNavigationBarHidden = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //2nd
        //5th
        //8th
        //return data.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //4th
        //7th
        //10th
        //return data[section].count
        guard let dataKeys = dataKeys else { return 0 }
        return dataKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        //label.text = data[indexPath.section][indexPath.item]
        label.text = dataKeys?[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //3rd
        //6th
        //9th
        //11th
        //return sectionHeaders[section]
        return nil //"Grid Configurations" //sectionHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newData = dataKeys!
            newData.remove(at: indexPath.row)
            dataKeys = newData as [String]?
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            /*var newData = data[indexPath.section]
            newData.remove(at: indexPath.row)
            data[indexPath.section] = newData
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()*/
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let fruitValue = data[indexPath.section][indexPath.row]
            //let textViewValue = jsonContents
            if let vc = segue.destination as? GridEditorViewController {
                vc.fruitValue = fruitValue
                vc.textViewValue = jsonContents
                vc.saveClosure = { newValue in
                    data[indexPath.section][indexPath.row] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /*func getImageFromServerById(imageId: String, completion: ((image: UIImage?) -> Void)) {
        let url:String = "https://dummyUrl.com/\(imageId).jpg"
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) {(data, response, error) in
            completion(image: UIImage(data: data))
        }
        
        task.resume()
    }
    
    getImageFromServerById("some string") { image in
    dispatch_async(dispatch_get_main_queue()) {
    // go to something on the main thread with the image like setting to UIImageView
    }
    }*/
    
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
                let nextItem = item as! NSDictionary
                let jsonTitle = nextItem["title"] as! String
                dataKeys?.append(jsonTitle)
                let jsonContents = nextItem["contents"] as! [[Int]]
                dataValues?.append(jsonContents)
            }
            
            
            
                /*let jsonDictionary = jsonArray[0] //as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
            
            print (jsonTitle, jsonContents)
            OperationQueue.main.addOperation {
                //self.textView.text = resultString
            }*/
            
            /*let dataKeys = jsonArray.map {_ in
                let jsonDictionary = jsonArray[0]
                jsonDictionary["title"] as! String
                /*var dataDictionary: NSDictionary
                dataDictionary
                jsonArray[$0]*/
            }*/
            print(dataKeys!)
            print(dataValues!)
        }
    }
    
// Ilan's code below
    
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var colsTextField: UITextField!
    @IBOutlet weak var rowSlider: UISlider!
    @IBOutlet weak var colSlider: UISlider!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        //0th
        //fetch()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)

        engine = StandardEngine.getEngine()
        rowsTextField.text = "\(engine.rows)"
        colsTextField.text = "\(engine.cols)"
        rowSlider.value = Float(engine.rows)
        colSlider.value = Float(engine.cols)
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

    @IBAction func rowsEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        if Float(val) < 1 || Float(val) > Float(rowSlider.maximumValue) {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        rowSlider.value = Float(val)
        colSlider.value = Float(val)
        updateGridSize(rows: val, cols: val)
    }

    @IBAction func rowsEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func colsEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(self.engine.cols)"
            }
            return
        }
        if Float(val) < 1 || Float(val) > Float(colSlider.maximumValue) {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.cols)"
            }
            return
        }
        rowSlider.value = Float(val)
        colSlider.value = Float(val)
        updateGridSize(rows: val, cols: val)
    }
    
    @IBAction func colsEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func rowSlideMove(_ sender: UISlider) {
        let val = Int(rowSlider.value)
        colSlider.value = Float(val)
        updateGridSize(rows: val, cols: val)
    }
    
    @IBAction func colSlideMove(_ sender: Any) {
        let val = Int(colSlider.value)
        rowSlider.value = Float(val)
        updateGridSize(rows: val, cols: val)
    }
    
    private func updateGridSize(rows: Int, cols: Int) {
        if engine.rows != rows {
            if engine.refreshRate > 0.0 {
                engine.prevRefreshRate = engine.refreshRate
            }
            engine.refreshRate = 0.0
            // send notification to turn off switch in SimulationViewController
            engine.setGridSize(rows: rows, cols: cols)
            rowsTextField.text = "\(rows)"
            colsTextField.text = "\(cols)"
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
