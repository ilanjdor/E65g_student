//
//  GridView.swift
//  Assignment3
//
//  Created by Ilan on 3/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {

    @IBInspectable var size = 20
    @IBInspectable var livingColor = UIColor.blue
    @IBInspectable var emptyColor = UIColor.red
    @IBInspectable var bornColor = UIColor.green
    @IBInspectable var diedColor = UIColor.brown
    @IBInspectable var gridColor = UIColor.black
    
    @IBInspectable var gridWidth = CGFloat(2)
    
    var grid : (Grid) {
        get {
            return Grid(size, size)
        }
    }
    
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
         let lineWidth: CGFloat = 2.0
         
        //create the path
        (1 ..< self.size).forEach { i in
            let horizontalPath = UIBezierPath()
            var start = CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + (CGFloat(i) * size.height)
            )
            var end = CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + (CGFloat(i) * size.height)
            )
            
            //set the path's line width
            horizontalPath.lineWidth = lineWidth
            
            //move the initial point of the path
            //to the start of the horizontal stroke
            horizontalPath.move(to: start)
            
            //add a point to the path at the end of the stroke
            horizontalPath.addLine(to: end)
            
            //draw the stroke
            gridColor.setStroke()
            horizontalPath.stroke()
        
            //create the path
            let verticalPath = UIBezierPath()
            start = CGPoint(
                x: rect.origin.x + (CGFloat(i) * size.width),
                y: rect.origin.y
            )
            end = CGPoint(
                x: rect.origin.x + (CGFloat(i) * size.width),
                y: rect.origin.y + rect.size.height
            )
            
            //set the path's line width
            verticalPath.lineWidth = lineWidth
            
            //move the initial point of the path
            //to the start of the vertical stroke
            verticalPath.move(to: start)
            
            //add a point to the path at the end of the stroke
            verticalPath.addLine(to: end)
            
            //draw the stroke
            gridColor.setStroke()
            verticalPath.stroke()
        }
    }
}
