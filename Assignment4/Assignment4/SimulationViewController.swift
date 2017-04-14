//
//  SimulationViewController.swift
//  Assignment4
//
//  Created by Ilan on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    @IBOutlet weak var gridView: GridView!
    
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = gridView.size
        engine = StandardEngine(rows: size, cols: size)
        engine.delegate = self
        gridView.grid = self
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.setNeedsDisplay()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    @IBAction func next(_ sender: Any) {
        if self.gridView.grid != nil {
            let newGrid = self.engine.step()
            self.gridView.grid = newGrid as? GridViewDataSource
            self.engineDidUpdate(withGrid: newGrid)
        }
        //engineDidUpdate(withGrid: grid)
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        //_ = withGrid.next() //or put _ = in front of function call
        //withGrid.setNeedsDisplay()
        //self.gridView.setNeedsDisplay()
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
}

/*import UIKit

@IBDesignable class SimulationViewController: UIViewController, EngineProtocol, EngineDelegate {
    
    @IBInspectable var size: Int = 20 {
        didSet {
            self.grid = Grid(self.size, self.size)
        }
    }
    
    @IBInspectable var livingColor = UIColor.blue
    @IBInspectable var emptyColor = UIColor.red
    @IBInspectable var bornColor = UIColor.green
    @IBInspectable var diedColor = UIColor.brown
    @IBInspectable var gridColor = UIColor.black
    
    @IBInspectable var gridWidth = CGFloat(2)
    
    var grid = Grid(0, 0)
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let size = CGSize(
            width: rect.size.width / CGFloat(self.size),
            height: rect.size.height / CGFloat(self.size)
        )
        let base = rect.origin
        (0 ..< self.size).forEach { i in
            (0 ..< self.size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y + (CGFloat(j) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                let path = UIBezierPath(ovalIn: subRect)
                switch grid[(i, j)] {
                case .alive:
                    livingColor.setFill()
                case .empty:
                    emptyColor.setFill()
                case .born:
                    bornColor.setFill()
                case .died:
                    diedColor.setFill()
                }
                path.fill()
            }
        }
        
        (0 ... self.size).forEach {
            drawLine(
                start: CGPoint(
                    x: rect.origin.x + (CGFloat($0) * size.width),
                    y: rect.origin.y
                ),
                end: CGPoint(
                    x: rect.origin.x + (CGFloat($0) * size.width),
                    y: rect.origin.y + rect.size.height
                )
            )
            drawLine(
                start: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + (CGFloat($0) * size.height)
                ),
                end: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + (CGFloat($0) * size.height)
                )
            )
        }
    }
    
    func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        path.lineWidth = 2.0
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        path.move(to: start)
        
        //add a point to the path at the end of the stroke
        path.addLine(to: end)
        
        //draw the stroke
        gridColor.setStroke()
        path.stroke()
    }
    
    func next() {
        grid = grid.next()
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        lastTouchedPosition = pos
        
        if let lastTouchedPosition = lastTouchedPosition {
            let gridPosition = grid[lastTouchedPosition]
            grid[lastTouchedPosition] = gridPosition.toggle(value: gridPosition)
        }
        
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let row = touchX / gridWidth * CGFloat(self.size)
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let col = touchY / gridHeight * CGFloat(self.size)
        let position = (row: Int(row), col: Int(col))
        return position
    }
}*/
