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

class GridEditorViewController: UIViewController, GridViewDataSource {//, EditorDelegate {
    static var rows: Int = 0
    static var cols: Int = 0
    static var intPairs: [[Int]] = []
    
    @IBOutlet weak var gridView: GridView!
    
    static var isGridEditorGrid: Bool = false
    //var gridSize: Int = 15
    var grid: GridProtocol?
    var fruitValue: String?
    var textViewValue: String?
    var intPairs: [[Int]]?
    var saveClosure: ((String) -> Void)?
    //var saveClosure: (([[Int]]) -> Void)?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fruitValueTextField: UITextField!
    
    var engine: StandardEngine! //= StandardEngine(rows: 2, cols: 2, intPairs: [])
    var editor: StandardEngine! //= StandardEngine(rows: 2, cols: 2, intPairs: [])
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return grid![row,col] }
        set { grid![row,col] = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor = StandardEngine.getEditor()
        //editor.delegate = self
        //engine = StandardEngine.getEngine()
        self.navigationItem.title = "Grid Editor";
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
        GridEditorViewController.isGridEditorGrid = true
        self.gridView.setNeedsDisplay()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
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
        //if let newValue = textView.text,
        //    let saveClosure = saveClosure {
            //editor = StandardEngine.getEditor()
            //editor.grid = grid!
        engine = StandardEngine.getEngine()
        engine.grid = grid!
        GridEditorViewController.isGridEditorGrid = false
        //    saveClosure(newValue)
           _ = self.navigationController?.popViewController(animated: true)
        //}
    }
    
    /*func editorDidUpdate(withGrid: GridProtocol) {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EditorUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["editor" : self])
        nc.post(n)
    }*/
    
    /*func gridEditorDidUpdate(withGrid: GridProtocol) {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }*/
}
