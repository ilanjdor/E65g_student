//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var rowsTextField: UITextField!
    @IBOutlet weak var colsTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!

    var engine: StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blue], for:.selected)

        engine = StandardEngine.getEngine()
        rowsTextField.text = "\(engine.rows)"
        colsTextField.text = "\(engine.cols)"
        sizeStepper.value = Double(engine.rows)
        refreshRateSlider.value = refreshRateSlider.maximumValue
        refreshRateSlider.isEnabled = false
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = false
        refreshOnOffSwitch.isOn = false
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
        if Float(val) < Float(sizeStepper.minimumValue) || Float(val) > Float(sizeStepper.maximumValue) {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.rows)"
            }
            return
        }
        sizeStepper.value = Double(val)
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
        if Float(val) < Float(sizeStepper.minimumValue) || Float(val) > Float(sizeStepper.maximumValue) {
            showErrorAlert(withMessage: "Invalid value: \(val), please try again.") {
                sender.text = "\(self.engine.cols)"
            }
            return
        }
        sizeStepper.value = Double(val)
        updateGridSize(rows: val, cols: val)
    }
    
    @IBAction func colsEditingDidEndOnExit(_ sender: UITextField) {
    }
    
    @IBAction func sizeStep(_ sender: Any) {
        let val = Int(sizeStepper.value)
        updateGridSize(rows: val, cols: val)
    }
    
    private func updateGridSize(rows: Int, cols: Int) {
        if engine.rows != rows {
            engine.refreshRate = 0.0
            engine.setGridSize(rows: rows, cols: cols)
            rowsTextField.text = "\(rows)"
            colsTextField.text = "\(cols)"
        }
    }
    
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
        engine.refreshRate = val
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: Any) {
    }
    
    @IBAction func refreshRate(_ sender: UISlider) {
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        engine.refreshRate = Double(refreshRateSlider.value)
    }

    @IBAction func refreshOnOff(_ sender: UISwitch) {
        if sender.isOn {
            refreshRateTextField.isEnabled = true
            refreshRateSlider.isEnabled = true
            engine.refreshRate = Double(refreshRateSlider.value)
        } else {
            refreshRateSlider.isEnabled = false
            refreshRateTextField.isEnabled = false
            engine.refreshRate = 0.0
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
