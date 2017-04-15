//
//  InstrumentationViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {

    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var refreshOnOffSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sizeStep(_ sender: Any) {
    }
    
    @IBAction func refreshRate(_ sender: Any) {
    }

    @IBAction func refreshOnOff(_ sender: Any) {
    }
}
