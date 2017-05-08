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
    // This function manufactures a cellInitializer function for a dictionary of integer pairs/arrays
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
    init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]])
    var grid: GridProtocol { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    var refreshTimer: Timer? { get set }
    var refreshRate: Double { get set }
    func step() -> GridProtocol?
}

class StandardEngine: EngineProtocol {
    static var defaultGridSize: Int = 10
    // engine is static to denote the fact this application uses only a single instance of it
    static var engine: StandardEngine = StandardEngine(rows: defaultGridSize, cols: defaultGridSize)
    private static var iterator: Grid.GridIterator?
    private let nc = NotificationCenter.default
    private var isNewlyLoadedGrid: Bool = true
    private var receivedManualTouch: Bool = false
    private var cellInitializer: (GridPosition) -> CellState
    private var statistics: [String:Int]
    
    required init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.isNewlyLoadedGrid = true
        self.cellInitializer = Grid.makeCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        StandardEngine.iterator = self.grid.makeIterator()
        self.statistics = Grid.getZeroedOutStateCounts()
        replacedGridNotify()
        statisticsNotify()

        nc.addObserver(
            forName: Notification.Name(rawValue: "EngineGridReceivedManualTouch"),
            object: nil,
            queue: nil) { (n) in
                self.receivedManualTouch = true
        }
    }
    
    var grid: GridProtocol {
        didSet {
            self.rows = grid.size.rows
            self.cols = grid.size.cols
            changedGridNotify()
        }
    }

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
    
    var refreshTimer: Timer?
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
    
    func step() -> GridProtocol? {
        // We use a GridIterator iterator to retain the history
        // of stepped grids for the purpose of detecting a cycle.
        //
        // Here are the rules I implemented for my GoL statistics:
        //
        // 1) The initial grid states will be included in the statistics
        // if and only if the initial grid is able to step.
        // 2) An empty grid cannot step and thus will never be
        // included in statistics.
        // 3) A running GoL (that is, an intial grid that's been stepped
        // at least once) ends when any one of the following things occurs:
        //     i) No living cells remain
        //    ii) The state is a revisited one
        //   iii) A manual touch
        //
        // For i) and ii) only, the speed switch will automatically shut off.
        // For ii) only, the simulator will display a cycle alert.
        // For iii) only, if the speed switch is on, the statistics and the cycle-detectable state
        // history will both be reset, however, the stepping will continue without interruption.
        // The manually-touched grid will become the initial state of a new GoL, from a statistics
        // and cycle-detection history perspective; from the user's perspecitve, the grid
        // will keep stepping without interruption.
        //
        // 4) The state that ends the GoL will not be included in the statistics.
        //
        if self.receivedManualTouch {
            // Statistics are reset upon manual touch
            // since resulting grid is not part of the
            // existing GoL, if one is running at the time
            StandardEngine.iterator = self.grid.makeIterator()
            self.isNewlyLoadedGrid = true
            self.statistics = Grid.getZeroedOutStateCounts()
            replacedGridNotify()
            self.receivedManualTouch = false
        }
        
        if let newGrid = StandardEngine.iterator?.next() {
            if self.grid.living.count > 0 {
                if self.isNewlyLoadedGrid {
                    accumulateIntoStatistics(grid: self.grid)
                }
                accumulateIntoStatistics(grid: newGrid)
            }
            self.isNewlyLoadedGrid = false
            self.grid = newGrid
            statisticsNotify()
            return grid
        } else {
            // Pre-stepped grid state formed a cycle.
            // The GoL, at least as I've implemented it,
            // ends upon a revisited state.
            // However, that phenomenon can only be detected
            // by the iterator once it attempts to next()
            // the revisited state. Once the cycle is detected,
            // we need to remove the statistics already accumulated
            // for the revisited state.
            if self.grid.living.count > 0 {
                removeFromStatistics(grid: self.grid)
                GoLCycledNotify()
            } /* else {
               // The special case is the empty intial grid.
               // The GoL, again, as I've implemented it, should
               // not run on an empty state. Programatically, here,
               // it does, although the cycle is detected after two steps
               // and it can be easily seen from the above that an initially
               // empty grid never accumulates statistics.
               // As should be the case, none of this manifests for the user
               // who, when attempting to step, simply observes 
               // a motionless, empty grid and zeroed-out statistics.
             } */
            statisticsNotify()
            GoLEndedNotify()
            return nil
        }
    }
    
    // When we have an actual GridProtocol object available,
    // we don't need to resort to the more costly approach
    // of creating and then utilizing a cellInitializer
    func setGrid(grid: GridProtocol) {
        self.isNewlyLoadedGrid = true
        self.grid = grid
        self.rows = grid.size.rows
        self.cols = grid.size.cols
        StandardEngine.iterator = self.grid.makeIterator()
        self.statistics = Grid.getZeroedOutStateCounts()
        replacedGridNotify()
        GoLEndedNotify()
        statisticsNotify()
    }
    
    // A nice feature of this version of setGrid is that when the optional
    // intPairsDict argument is excluded, as is the case everywhere
    // except for when the user defaults are restored, the relatively costly
    // cellInitializer procedure will immediately return the default empty initializer.
    // I suppose that I could have instead used an optional cellInitializer since
    // Grid's initializer treats it as optional, but the way I did it seemed
    // neat, explicit and straightforward to me.
    func setGrid(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.isNewlyLoadedGrid = true
        self.cellInitializer = Grid.makeCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        StandardEngine.iterator = self.grid.makeIterator()
        self.statistics = Grid.getZeroedOutStateCounts()
        replacedGridNotify()
        GoLEndedNotify()
        statisticsNotify()
    }
    
    private func accumulateIntoStatistics(grid: GridProtocol) {
        var grid = grid
        grid.setStateCounts()
        self.statistics = Grid.combineStateCounts(existing: self.statistics, new: grid.stateCounts)
    }
    
    private func removeFromStatistics(grid: GridProtocol) {
        var grid = grid
        grid.setStateCounts()
        self.statistics = Grid.removeStateCounts(existing: self.statistics, new: grid.stateCounts)
    }
    
    private func changedGridNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "EngineGridChanged"),
                    object: nil,
                    //userInfo: ["engine" : self]) /* now, engine is static */
                    userInfo: ["none" : "none"]))
    }
    
    private func replacedGridNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "EngineGridInitializedOrLoadedOrStepped"),
                    object: nil,
                    userInfo: ["none" : "none"]))
    }
    
    private func statisticsNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "StatisticsUpdate"),
                    object: nil,
                    userInfo: ["statistics" : self.statistics]))
    }
    
    private func GoLEndedNotify() {
        nc.post(Notification(
            name: Notification.Name(rawValue: "GoLEnded"),
            object: nil,
            userInfo: ["none" : "none"]))
    }
    
    private func GoLCycledNotify() {
        nc.post(Notification(
                    name: Notification.Name(rawValue: "GoLCycled"),
                    object: nil,
                    userInfo: ["none" : "none"]))
    }
}
