//
//  Grid.swift
//
//  Ilan Dor
//  CSCI E-65g, Spring 2017, FinalProject
//
//  All modules created and/or modified by Van Simmons and/or Ilan Dor
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

public typealias GridPosition = (row: Int, col: Int)
public typealias GridSize = (rows: Int, cols: Int)

fileprivate func norm(_ val: Int, to size: Int) -> Int { return ((val % size) + size) % size }

public enum CellState {
    case alive, empty, born, died
    
    public var isAlive: Bool {
        switch self {
        case .alive, .born: return true
        default: return false
        }
    }
}

public protocol GridViewDataSource {
    subscript (row: Int, col: Int) -> CellState { get set }
}

public protocol GridProtocol {
    init(_ rows: Int, _ cols: Int, cellInitializer: @escaping (GridPosition) -> CellState)
    var description: String { get }
    var size: GridSize { get }
    var living: [GridPosition] { get }
    var configuration: [String:[[Int]]] { get }
    var stateCounts: [String:Int] { get }
    subscript (row: Int, col: Int) -> CellState { get set }
    //func next() -> Self /* We need to use next() from GridIterator in order to detect grid cycles */
    func makeIterator() -> Grid.GridIterator
    mutating func setConfiguration()
    mutating func setStateCounts()
}

public let lazyPositions = { (size: GridSize) in
    return (0 ..< size.rows)
        .lazy
        .map { zip( [Int](repeating: $0, count: size.cols) , 0 ..< size.cols ) }
        .flatMap { $0 }
        .map { GridPosition($0) }
}


let offsets: [GridPosition] = [
    (row: -1, col:  -1), (row: -1, col:  0), (row: -1, col:  1),
    (row:  0, col:  -1),                     (row:  0, col:  1),
    (row:  1, col:  -1), (row:  1, col:  0), (row:  1, col:  1)
]

extension GridProtocol {
    public var description: String {
        return lazyPositions(self.size)
            .map { (self[$0.row, $0.col].isAlive ? "*" : " ") + ($0.col == self.size.cols - 1 ? "\n" : "") }
            .joined()
    }
    
    private func neighborStates(of pos: GridPosition) -> [CellState] {
        return offsets.map { self[pos.row + $0.row, pos.col + $0.col] }
    }
    
    private func nextState(of pos: GridPosition) -> CellState {
        let iAmAlive = self[pos.row, pos.col].isAlive
        let numLivingNeighbors = neighborStates(of: pos).filter({ $0.isAlive }).count
        switch numLivingNeighbors {
        case 2 where iAmAlive,
             3: return iAmAlive ? .alive : .born
        default: return iAmAlive ? .died  : .empty
        }
    }
    
    public func next() -> Self {
        var nextGrid = Self(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        return nextGrid
    }
}

public struct Grid: GridProtocol {
    private var _cells: [[CellState]]
    public let size: GridSize
    public var configuration: [String:[[Int]]] = [:]
    public var stateCounts: [String:Int] = [:]
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: @escaping (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: cols)), count: rows))
        size = GridSize(rows, cols)
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
}

extension Grid: Sequence {
    public var living: [GridPosition] {
        return lazyPositions(self.size).filter { return  self[$0.row, $0.col].isAlive   }
    }
    
    public struct GridIterator: IteratorProtocol {
        private class GridHistory: Equatable {
            let positions: [GridPosition]
            let previous:  GridHistory?
            
            static func == (lhs: GridHistory, rhs: GridHistory) -> Bool {
                return lhs.positions.elementsEqual(rhs.positions, by: ==)
            }
            
            init(_ positions: [GridPosition], _ previous: GridHistory? = nil) {
                self.positions = positions
                self.previous = previous
            }
            
            var hasCycle: Bool {
                var prev = previous
                while prev != nil {
                    if self == prev { return true }
                    prev = prev!.previous
                }
                return false
            }
        }
        
        private var grid: GridProtocol
        private var history: GridHistory!
        
        init(grid: Grid) {
            self.grid = grid
            self.history = GridHistory(grid.living)
        }
        
        public mutating func next() -> GridProtocol? {
            if history.hasCycle { return nil }
            let newGrid: Grid = self.grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            self.grid = newGrid
            return self.grid
        }
        
        // The function below is used in order
        // to make the cycle halt on the first repeated state
        // as opposed to the state after that, as does
        // the original next() function above.
        //
        // The fact that we count the initial state in the statistics
        // would seem to support using the function below.
        // In this way, we will only count the cycled state
        // once and an empty grid will not step in the first place.
        //
        // If manual touches are added to the cycled state, the
        // user may resume stepping, and the statistics will incorporate
        // the manually-touched state once as part of the next run,
        // accumulating further the statistics for the run
        // that just cycled.
        /*public mutating func next() -> GridProtocol? {
            history = GridHistory(self.grid.living, history)
            if history.hasCycle { return nil }
            let newGrid: Grid = self.grid.next() as! Grid
            self.grid = newGrid
            return self.grid
        }*/

        // As explained further in the comments in StandardEngine,
        // we need to replace the grid before a step that succeeds
        // manual touches.
        /*public mutating func replaceGrid(grid: GridProtocol) {
            self.grid = grid
        }*/
    }
    
    public func makeIterator() -> GridIterator { return GridIterator(grid: self) }
}

public extension Grid {
    public static func gliderInitializer(pos: GridPosition) -> CellState {
        switch pos {
        case (0, 1), (1, 2), (2, 0), (2, 1), (2, 2): return .alive
        default: return .empty
        }
    }
}

public extension Grid {
    // This function manufactures a cellInitializer function bespoke for a dictionary of integer pairs/arrays
    public static func makeCellInitializer(intPairsDict: [String:[[Int]]]) -> (GridPosition) -> CellState {
        if intPairsDict.count == 0 {
            return {_,_ in .empty}
        }
        
        let aliveIntPairs = intPairsDict["alive"] ?? []
        let bornIntPairs = intPairsDict["born"] ?? []
        let diedIntPairs = intPairsDict["died"] ?? []
        
        func cellInitializer(pos: GridPosition) -> CellState {
            let intPair = [pos.row, pos.col]
            if aliveIntPairs.contains(where: {$0 == intPair}) { return .alive }
            if bornIntPairs.contains(where: {$0 == intPair}) { return .born }
            if diedIntPairs.contains(where: {$0 == intPair}) { return .died }
            return .empty
        }
        return cellInitializer
    }
    
    mutating public func setConfiguration() {
        configuration = [:]
        lazyPositions(self.size).forEach {
            switch self[$0.row, $0.col] {
            case .born:
                configuration["born"] = (configuration["born"] ?? []) + [[$0.row, $0.col]]
            case .died:
                configuration["died"] = (configuration["died"] ?? []) + [[$0.row, $0.col]]
            case .alive:
                configuration["alive"] = (configuration["alive"] ?? []) + [[$0.row, $0.col]]
            case .empty:
                ()
            }
        }
    }
    
    mutating public func setStateCounts() {
        stateCounts["alive"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .alive }).count
        stateCounts["born"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .born }).count
        stateCounts["died"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .died }).count
        stateCounts["empty"] = self.size.rows * self.size.cols - stateCounts["alive"]! - stateCounts["born"]! - stateCounts["died"]!
    }
    
    public static func getZeroedOutStateCounts() -> [String:Int] {
        var stateCounts: [String:Int] = [:]
        stateCounts["alive"] = 0
        stateCounts["born"] = 0
        stateCounts["died"] = 0
        stateCounts["empty"] = 0
        return stateCounts
    }
    
    public static func combineStateCounts(existing: [String:Int], new: [String:Int]) -> [String:Int] {
        var combined: [String:Int] = [:]
        combined["alive"] = existing["alive"]! + new["alive"]!
        combined["born"] = existing["born"]! + new["born"]!
        combined["died"] = existing["died"]! + new["died"]!
        combined["empty"] = existing["empty"]! + new["empty"]!
        return combined
    }
    
    public static func removeStateCounts(existing: [String:Int], new: [String:Int]) -> [String:Int] {
        var combined: [String:Int] = [:]
        combined["alive"] = existing["alive"]! - new["alive"]!
        combined["born"] = existing["born"]! - new["born"]!
        combined["died"] = existing["died"]! - new["died"]!
        combined["empty"] = existing["empty"]! - new["empty"]!
        return combined
    }
}

public protocol EngineProtocol {
    // Note: It is not a requirement to use a delegate in the Final Project
    // according to Prof. Simmons during the Zoom session he held
    // at 8:00AM (EST) on 5/6/17
    var grid: GridProtocol { get set }
    var prevRefreshRate: Double { get set }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]])
    func step() -> GridProtocol?
}

class StandardEngine: EngineProtocol {
    static var defaultGridSize: Int = 10
    var grid: GridProtocol {
        didSet {
            self.rows = grid.size.rows
            self.cols = grid.size.cols
            self.notify()
        }
    }
    var isNewlyLoadedGrid: Bool = true
    var receivedManualTouch: Bool = false
    var cellInitializer: (GridPosition) -> CellState
    var statistics: [String:Int]
    
    // Using didSet as below causes circular issues with grid's didSet
    // but I'm leaving it in as a comment to let you know that I am aware
    // that I must manually take on the responsibility of keeping
    // the grid's rows and cols in sync with the engine's rows and cols
    var rows: Int /*{
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        }
    }*/
    var cols: Int /*{
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        }
    }*/
    
    // engine is static to denote the fact this application uses only a single instance of it
    static var engine: StandardEngine = StandardEngine(rows: defaultGridSize, cols: defaultGridSize)
    private static var iterator: Grid.GridIterator?
    
    required init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.isNewlyLoadedGrid = true
        self.cellInitializer = Grid.makeCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        StandardEngine.iterator = self.grid.makeIterator()
        self.statistics = Grid.getZeroedOutStateCounts()
        self.setGridNotify()
        self.statisticsNotify()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineGridReceivedManualTouch")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.receivedManualTouch = true
        }
    }
    
    var refreshTimer: Timer?
    var prevRefreshRate: TimeInterval = 0.0
    var refreshRate: TimeInterval = 0.0 {
        didSet {
            refreshTimer?.invalidate()
            refreshTimer = nil
            if refreshRate > 0.0 {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
        }
    }
    
    func accumulateIntoStatistics(grid: GridProtocol) {
        var grid = grid
        grid.setStateCounts()
        self.statistics = Grid.combineStateCounts(existing: self.statistics, new: grid.stateCounts)
    }
    
    func removeFromStatistics(grid: GridProtocol) {
        var grid = grid
        grid.setStateCounts()
        self.statistics = Grid.removeStateCounts(existing: self.statistics, new: grid.stateCounts)
    }
    
    func step() -> GridProtocol? {
        // We use a Grid.GridIterator iterator to retain the history
        // of stepped grids for the purpose of detecting a cycle.
        //
        // The iterator needs to recapture a manually touched grid
        // because its next() method only knows about GoL steps
        // Why not simply ALWAYS recapture the grid before stepping?
        // Because then the iterator would never retain a history
        // and thus would never be able to detect a cycle - a situation
        // that would defeat the entire purpose of using this
        // particular iterator object type in the first place!
        // 
        // Making a new iterator would avoid the need to replace the grid
        // within the existing iterator, the latter being a mutation
        // that is admittedly an unideal one to perform onto an iterator.
        // However, making a new iterator would discard the history
        // and thus fail to detect a cycle against any state prior
        // to that of the manually updated grid.
        if self.receivedManualTouch {
            //StandardEngine.iterator?.replaceGrid(grid: self.grid)
            StandardEngine.iterator = self.grid.makeIterator()
            self.isNewlyLoadedGrid = true
            self.statistics = Grid.getZeroedOutStateCounts()
            self.setGridNotify()
            self.receivedManualTouch = false
        }

        if let newGrid = StandardEngine.iterator?.next() {
            if self.isNewlyLoadedGrid {
                if self.grid.living.count > 0 {
                    self.accumulateIntoStatistics(grid: self.grid)
                }
                self.isNewlyLoadedGrid = false
            }
            if self.grid.living.count > 0 {
                self.accumulateIntoStatistics(grid: newGrid)
            }
            self.grid = newGrid
            self.statisticsNotify()
            return grid
        } else {
            // Pre-stepped grid state formed a cycle
            if self.grid.living.count > 0 {
                self.removeFromStatistics(grid: self.grid)
                self.cycleNotify()
            } else {
                self.statistics = Grid.getZeroedOutStateCounts()
            }
            self.statisticsNotify()
            return nil
        }
    }
    
    // Funnel this into setGrid further below
    // so that we can equip it with a cellInitializer
    // for the sake of posterity and consistency
    func setGrid(grid: GridProtocol) {
        var grid = grid
        grid.setConfiguration()
        let intPairsDict = grid.configuration
        let rows = grid.size.rows
        let cols = grid.size.cols
        self.setGrid(rows: rows, cols: cols, intPairsDict: intPairsDict)
    }
    
    func setGrid(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.isNewlyLoadedGrid = true
        self.cellInitializer = Grid.makeCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        StandardEngine.iterator = self.grid.makeIterator()
        self.statistics = Grid.getZeroedOutStateCounts()
        self.setGridNotify()
        self.statisticsNotify()
    }
    
    func notify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             //userInfo: ["engine" : self]) /* now, engine is static */
                             userInfo: ["none" : "none"])
        nc.post(n)
    }
    
    func setGridNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineSetGrid")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["none" : "none"])
        nc.post(n)
    }
    
    func statisticsNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "StatisticsUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["statistics" : self.statistics])
        nc.post(n)
    }
    
    func cycleNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "CycleOccurred")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["none" : "none"])
        nc.post(n)
    }
}
