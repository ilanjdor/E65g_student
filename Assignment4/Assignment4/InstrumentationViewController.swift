//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    
    @IBOutlet weak var refreshRateTextField: UITextField!
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!

    var engine: StandardEngine!
    //var refreshRatePreviousValue: Float = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        engine = StandardEngine.getEngine()
        sizeTextField.text = "\(engine.size)"
        sizeStepper.value = Double(engine.size)
        refreshRateSlider.value = 9.0
        refreshRateSlider.isEnabled = false
        refreshRateTextField.text = "\(refreshRateSlider.value)"
        refreshRateTextField.isEnabled = false
        refreshOnOffSwitch.isOn = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gridSizeEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                //sender.text = "\(StandardEngine.getEngine().rows)"
                sender.text = "\(StandardEngine.getEngine().size)"
            }
            return
        }
        sizeStepper.value = Double(val)
        updateGridSize(size: val)
    }
    
    @IBAction func gridSizeEditingDidEndOnExit(_ sender: Any) {
    }
    
    @IBAction func sizeStep(_ sender: Any) {
        updateGridSize(size: Int(sizeStepper.value))
    }
    
    private func updateGridSize(size: Int) {
        engine = StandardEngine.getEngine()
        if engine.size != size {
            engine.refreshRate = 0.0
            engine.setGridSize(size: size)
            sizeTextField.text = "\(size)"
        }
    }
    
    @IBAction func refreshRateEditingDidEnd(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Double(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(StandardEngine.getEngine().refreshRate)"
            }
            return
        }
        refreshRateSlider.value = Float(val)
        updateRefreshRate(rate: val)
    }
    
    @IBAction func refreshRateEditingDidEndOnExit(_ sender: Any) {
    }
    
    @IBAction func refreshRate(_ sender: UISlider) {
        updateRefreshRate(rate: Double(refreshRateSlider.value))
    }

    @IBAction func refreshOnOff(_ sender: UISwitch) {
        if sender.isOn {
            refreshRateTextField.isEnabled = true
            //refreshRateTextField.text = "\(refreshRatePreviousValue)"
            refreshRateSlider.isEnabled = true
            //refreshRateSlider.value = refreshRatePreviousValue
            updateRefreshRate(rate: Double(refreshRateSlider.value))
        } else {
            //refreshRatePreviousValue = refreshRateSlider.value
            //refreshRateSlider.value = 0.0
            refreshRateSlider.isEnabled = false
            //refreshRateTextField.text = "\(refreshRateSlider.value)"
            refreshRateTextField.isEnabled = false
            updateRefreshRate(rate: 0.0)
        }
        //updateRefreshRate(rate: Double(refreshRateSlider.value))
        //setNeedsDisplay
    }
    
    private func updateRefreshRate(rate: Double) {
        StandardEngine.getEngine().refreshRate = TimeInterval(rate)
        //if refreshRateSlider.isEnabled {
            //refreshRateTextField.text = "\(rate)"
        //}
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
