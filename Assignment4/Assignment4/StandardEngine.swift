//
//  StandardEngine.swift
//  Assignment4
//
//  Created by Ilan on 4/13/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

class StandardEngine : EngineProtocol {
    static var engine: StandardEngine = StandardEngine(rows: 10, cols: 10)
    
    var grid: GridProtocol
    var delegate: EngineDelegate?
    var rows: Int = 0
    var cols: Int = 0
    
    //var updateClosure: ((Grid) -> Void)?
    var refreshTimer: Timer?
    var refreshRate: TimeInterval = 0.0 {
        didSet {
            if refreshRate > 0.0 {
                refreshTimer? = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    
    required init(rows: Int, cols: Int) {
        self.grid = Grid(rows, cols, cellInitializer: { _,_ in .empty })
        self.notifyDelegateAndPublishGrid()
    }
    
    func step() -> GridProtocol {
        let newGrid = grid.next()
        grid = newGrid
        self.notifyDelegateAndPublishGrid()
        return grid
    }
    
    func notifyDelegateAndPublishGrid() {
        delegate?.engineDidUpdate(withGrid: self as! GridProtocol)
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
}
