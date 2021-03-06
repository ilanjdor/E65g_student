//
//  GridView.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView, GridViewDataSource {
    // Might have been able to replace "useEngineGrid" with a notification
    // but I'm out of time. It's due in 22 minutes.
    static var useEngineGrid: Bool = true
    
    @IBInspectable var rows: Int = StandardEngine.defaultGridSize
    @IBInspectable var cols: Int = StandardEngine.defaultGridSize
    @IBInspectable var livingColor: UIColor = UIColor(
        red: (0/255.0),
        green: (255/255.0),
        blue: (128/255.0),
        alpha: 1.0)
    @IBInspectable var emptyColor: UIColor = UIColor(
        red: (76/255.0),
        green: (76/255.0),
        blue: (76/255.0),
        alpha: 1.0)
    @IBInspectable var bornColor: UIColor = UIColor(
        red: (0/255.0),
        green: (255/255.0),
        blue: (128/255.0),
        alpha: 0.6)
    @IBInspectable var diedColor: UIColor = UIColor(
        red: (76/255.0),
        green: (76/255.0),
        blue: (76/255.0),
        alpha: 0.6)
    @IBInspectable var gridColor: UIColor = UIColor(
        red: (0/255.0),
        green: (0/255.0),
        blue: (0/255.0),
        alpha: 1.0)
    @IBInspectable var gridWidth:CGFloat = CGFloat(0.5)

    var engine: StandardEngine!
    var gridViewDataSource: GridViewDataSource?
    var lastTouchedPosition: GridPosition?
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return self.gridViewDataSource![row,col] }
        set { self.gridViewDataSource?[row,col] = newValue }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if GridView.useEngineGrid {
            self.engine = StandardEngine.engine
            self.rows = self.engine.rows
            self.cols = self.engine.cols
        }
    // Drawing code
        let size = CGSize(
            width: rect.size.width / CGFloat(self.cols),
            height: rect.size.height / CGFloat(self.rows)
        )
        let base = rect.origin
        (0 ..< self.cols).forEach { i in
            (0 ..< self.rows).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(i) * size.width),
                    y: base.y + (CGFloat(j) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                let path = UIBezierPath(ovalIn: subRect)
                if let grid = self.gridViewDataSource {
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
         }

        (0 ... self.cols).forEach {
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
        }
        (0 ... self.rows).forEach {
            self.drawLine(
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
    
    private func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        
        // Set the path's line width to the height of the stroke
        path.lineWidth = gridWidth
        
        // Move the initial point of the path
        // to the start of the horizontal stroke
        path.move(to: start)
        
        // Add a point to the path at the end of the stroke
        path.addLine(to: end)
        
        // Draw the stroke
        self.gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.lastTouchedPosition = nil
    }
    
    private func process(touches: Set<UITouch>) -> GridPosition? {
        //GridView.wasManualTouch = true
        guard touches.count == 1 else { return nil }
        guard let pos = convert(touch: touches.first!) else { return nil }
        
        //************* IMPORTANT ****************
        guard self.lastTouchedPosition?.row != pos.row
            || self.lastTouchedPosition?.col != pos.col
            else { return pos }
        //****************************************
        
        if self.gridViewDataSource != nil {
            self.gridViewDataSource![pos.row, pos.col] =
                self.gridViewDataSource![pos.row, pos.col].isAlive ? .empty : .alive
            setNeedsDisplay()
            // We don't need to notify the engine about manual touches
            // in the grid editor because its grid cannot be stepped
            if GridView.useEngineGrid {
                touchNotify()
            }
        }
        return pos
    }
    
    private func convert(touch: UITouch) -> GridPosition? {
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let row = touchX / gridWidth * CGFloat(self.rows)
        
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let col = touchY / gridHeight * CGFloat(self.cols)
        
        guard touchY > 0 && touchY < gridHeight
            && touchX > 0 && touchX < gridWidth
            else { return nil }
        
        return GridPosition(row: Int(row), col: Int(col))
    }
    
    private func touchNotify() {
        let nc = NotificationCenter.default
        nc.post(Notification(
                    name: Notification.Name(rawValue: "EngineGridReceivedManualTouch"),
                    object: nil,
                    userInfo: ["none" : "none"]))
    }
 }
