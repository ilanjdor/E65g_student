//
//  GridView.swift
//  Assignment3
//
//  Created by Ilan on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    //@IBInspectable var fillColor = UIColor.darkGray
    //@IBInspectable var gridSize: Int = 3
    
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
    
    //var grid = Grid(0, 0)
    var grid: GridProtocol?
    
    //var xColor = UIColor.black
    //var xProportion = CGFloat(1.0)
    //var widthProportion = CGFloat(0.05)
    
    /*override func draw(_ rect: CGRect) {
        drawOvals(rect)
        drawLines(rect)
    }
    
    func drawOvals(_ rect: CGRect) {
        let size = CGSize(
            width: rect.size.width / CGFloat(gridSize),
            height: rect.size.height / CGFloat(gridSize)
        )
        let base = rect.origin
        (0 ..< gridSize).forEach { i in
            (0 ..< gridSize).forEach { j in
                // Inset the oval 2 points from the left and top edges
                let ovalOrigin = CGPoint(
                    x: base.x + (CGFloat(j) * size.width) + 2.0,
                    y: base.y + (CGFloat(i) * size.height + 2.0)
                )
                // Make the oval draw 2 points short of the right and bottom edges
                let ovalSize = CGSize(
                    width: size.width - 4.0,
                    height: size.height - 4.0
                )
                let ovalRect = CGRect( origin: ovalOrigin, size: ovalSize )
                if let grid = grid, grid[i,j].isAlive {
                    drawOval(ovalRect)
                }
            }
        }
    }
    
    func drawOval(_ ovalRect: CGRect) {
        let path = UIBezierPath(ovalIn: ovalRect)
        fillColor.setFill()
        path.fill()
    }
    
    func drawLines(_ rect: CGRect) {
        //create the path
        (0 ..< (gridSize + 1)).forEach {
            drawLine(
                start: CGPoint(x: CGFloat($0)/CGFloat(gridSize) * rect.size.width, y: 0.0),
                end:   CGPoint(x: CGFloat($0)/CGFloat(gridSize) * rect.size.width, y: rect.size.height)
            )
            
            drawLine(
                start: CGPoint(x: 0.0, y: CGFloat($0)/CGFloat(gridSize) * rect.size.height ),
                end: CGPoint(x: rect.size.width, y: CGFloat($0)/CGFloat(gridSize) * rect.size.height)
            )
        }
    }*/
    
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
                if let grid = grid {
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
        grid = grid?.next()
        self.setNeedsDisplay()
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
    
    /*typealias Position = (row: Int, col: Int)
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
    }*/
    
    // Updated since class
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        guard touches.count == 1 else { return nil }
        //added by me on 2017/04/10
        guard let pos = convert(touch: touches.first!) else { return nil }
        
        //************* IMPORTANT ****************
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        //****************************************
        
        if grid != nil {
            grid![pos.row, pos.col] = grid![pos.row, pos.col].isAlive ? .empty : .alive
            setNeedsDisplay()
        }
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition? {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(self.size) //(gridSize)
        
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(self.size) //(gridSize)
        
        //added by me on 2017/04/10
        guard touchY > 0 && touchY < gridHeight
            && touchX > 0 && touchX < gridWidth
            else { return nil }
        
        return GridPosition(row: Int(row), col: Int(col))
    }
}
