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
    @IBInspectable var emptyColor = UIColor.clear
    @IBInspectable var bornColor = UIColor.green
    @IBInspectable var diedColor = UIColor.brown
    @IBInspectable var gridColor = UIColor.cyan
    
    @IBInspectable var gridWidth = CGFloat(2)
    
    var grid : (Grid) {
        get {
            return Grid(size, size)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
