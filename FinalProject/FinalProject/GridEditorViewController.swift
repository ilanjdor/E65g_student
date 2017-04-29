//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Ilan on 4/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

//
//  GridEditorViewController.swift
//  Lecture11
//
//  Created by Van Simmons on 4/17/17.
//  Copyright © 2017 Harvard University. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource { //, EditorDelegate {
    
    @IBOutlet weak var gridView: GridView!
    
    var grid: GridProtocol?
    var fruitValue: String?
    var textViewValue: String?
    var intPairs: [[Int]]?
    var saveClosure: ((String) -> Void)?
    //var saveClosure: (([[Int]]) -> Void)?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fruitValueTextField: UITextField!
    
    var editor: StandardEditor!
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return grid![row,col] }
        set { grid![row,col] = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //editor = StandardEditor.getEditor()
        //editor.delegate = self
        gridView.gridViewDataSource = self
        gridView.rows = (grid?.size.rows)!
        gridView.cols = (grid?.size.cols)!
        
        navigationController?.isNavigationBarHidden = false
        /*if let fruitValue = fruitValue {
            fruitValueTextField.text = fruitValue
        }
        if let textViewValue = textViewValue {
            textView.text = textViewValue
        }*/
        self.gridView.setNeedsDisplay()
        
        /*let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EditorUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        /*if let newValue = fruitValueTextField.text,
        //if let newValue = textView.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            _ = self.navigationController?.popViewController(animated: true)
        }*/
        if let newValue = textView.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func editorDidUpdate(withGrid: GridProtocol) {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EditorUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["editor" : self])
        nc.post(n)
    }
}
