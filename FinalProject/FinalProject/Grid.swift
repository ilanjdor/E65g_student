//
//  Grid.swift
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
<<<<<<< HEAD
    var configuration: [String:[[Int]]] { get }
    var stateCounts: [String:Int] { get }
=======
    var stateCounts: [String:Int] { get }
    var configuration: [String:[[Int]]] { get }
>>>>>>> refs/remotes/origin/master
    subscript (row: Int, col: Int) -> CellState { get set }
    mutating func next() -> Self // made mutating so that grid can store cumulative statistics
    mutating func setConfiguration()
<<<<<<< HEAD
    /*func getConfiguration() -> [String:[[Int]]]
    mutating func resetStatistics() -> Void*/
    mutating func setStateCounts()
    //mutating func resetStateCounts()
=======
    //mutating func resetStateCounts() -> Void
    mutating func tallyStateCounts() -> Void
>>>>>>> refs/remotes/origin/master
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
    
    public mutating func next() -> Self {
        var nextGrid = Self(size.rows, size.cols) { _, _ in .empty }
        lazyPositions(self.size).forEach { nextGrid[$0.row, $0.col] = self.nextState(of: $0) }
        self.tallyStateCounts() // IJD added
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
        self.tallyStateCounts()
        //self.resetStateCounts() // IJD added
        //self.tallyStateCounts() // IJD added
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
            let newGrid:Grid = grid.next() as! Grid
            history = GridHistory(newGrid.living, history)
            grid = newGrid
            return grid
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
    
/*public extension Grid {
    public static func makeCellInitializer(intPairs: [[Int]]) -> (GridPosition) -> CellState {
        if intPairs.count == 0 {
            return {_,_ in .empty}
        }
        var alivePositions = intPairs.map { GridPosition($0[0], $0[1]) }
        func cellInitializer(pos: GridPosition) -> CellState {
            for position in alivePositions {
                if pos.row == position.row && pos.col == position.col {
                    return .alive
                }
            }
            return .empty
        }
        return cellInitializer
    }
}*/

public extension Grid {
    public static func makeFancierCellInitializer(intPairsDict: [String:[[Int]]]) -> (GridPosition) -> CellState {
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
    
<<<<<<< HEAD
    /*public func getConfiguration() -> [String:[[Int]]] {
        return configuration
    }
    
    public mutating func accumulateStatistics() -> Void {
        let alive = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .alive }).count
        let born = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .born }).count
        let died = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .died }).count
        let empty = self.size.rows - alive - born - died
        statistics["alive"]! += alive
        statistics["born"]! += born
        statistics["died"]! += died
        statistics["empty"]! += empty
    }
    
    public mutating func resetStatistics() -> Void {
        statistics["alive"] = 0
        statistics["born"] = 0
        statistics["died"] = 0
        statistics["empty"] = 0
    }*/
    
    mutating public func setStateCounts() {
        //var stateCounts: [String:Int] = [:]
        stateCounts["alive"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .alive }).count
        stateCounts["born"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .born }).count
        stateCounts["died"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .died }).count
        stateCounts["empty"] = self.size.rows * self.size.cols - stateCounts["alive"]! - stateCounts["born"]! - stateCounts["died"]!
        //return stateCounts
    }
    
    public static func getZeroedOutStateCounts() -> [String:Int] {
        var stateCounts: [String:Int] = [:]
        stateCounts["alive"] = 0
        stateCounts["born"] = 0
        stateCounts["died"] = 0
        stateCounts["empty"] = 0
        return stateCounts
    }
 
 /*public mutating func resetStateCounts() -> Void {
 stateCounts["alive"] = 0
 stateCounts["born"] = 0
 stateCounts["died"] = 0
 stateCounts["empty"] = 0
 }*/
 
=======
    public mutating func tallyStateCounts() -> Void {
        self.stateCounts["alive"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .alive }).count
        self.stateCounts["born"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .born }).count
        self.stateCounts["died"] = (lazyPositions(self.size).filter { self[$0.row, $0.col] == .died }).count
        self.stateCounts["empty"] = self.size.rows * self.size.cols - stateCounts["alive"]! - stateCounts["born"]! - stateCounts["died"]!
    }
    
    /*public mutating func resetStateCounts() -> Void {
        stateCounts["alive"] = 0
        stateCounts["born"] = 0
        stateCounts["died"] = 0
        stateCounts["empty"] = 0
    }*/
    
>>>>>>> refs/remotes/origin/master
    public static func combineStateCounts(existing: [String:Int], new: [String:Int]) -> [String:Int] {
        var combined: [String:Int] = [:]
        combined["alive"] = existing["alive"]! + new["alive"]!
        combined["born"] = existing["born"]! + new["born"]!
        combined["died"] = existing["died"]! + new["died"]!
        combined["empty"] = existing["empty"]! + new["empty"]!
        return combined
    }
}

public protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

public protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get set }
    var prevRefreshRate: Double { get set }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    var cellInitializer: (GridPosition) -> CellState { get set }
    var statistics: [String:Int] { get }
    init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]])
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    static var defaultGridSize: Int = 10
    var delegate: EngineDelegate?
    var grid: GridProtocol {
        didSet {
<<<<<<< HEAD
            let cumulativeStateCounts = self.statistics
            self.grid.setStateCounts()
            let gridStateCounts = self.grid.stateCounts
            self.statistics = Grid.combineStateCounts(existing: cumulativeStateCounts, new: gridStateCounts)
=======
            self.statistics = self.grid.stateCounts
>>>>>>> refs/remotes/origin/master
            self.rows = grid.size.rows
            self.cols = grid.size.cols
            notify()
            statisticsNotify()
        }
    }
    var cellInitializer: (GridPosition) -> CellState
<<<<<<< HEAD
    var statistics: [String:Int]
=======
    var statistics: [String : Int] = [:]
>>>>>>> refs/remotes/origin/master
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
    
    private static var engine: StandardEngine = StandardEngine(rows: defaultGridSize, cols: defaultGridSize)
    
    required init(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.cellInitializer = Grid.makeFancierCellInitializer(intPairsDict: intPairsDict)
        self.statistics = Grid.getZeroedOutStateCounts()
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        //self.statistics = self.grid.stateCounts
        self.rows = rows
        self.cols = cols
        //notify()
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
    
    func step() -> GridProtocol {
<<<<<<< HEAD
        //self.grid.setStateCounts()
        //let prevStateCounts = self.grid.stateCounts
        let newGrid = self.grid.next()
        //newGrid.setStateCounts()
        //let newStateCounts = newGrid.stateCounts
=======
        let newGrid = self.grid.next()
>>>>>>> refs/remotes/origin/master
        self.grid = newGrid
        //self.grid.tallyStateCounts()
        let prevStateCounts = self.statistics
        self.statistics = Grid.combineStateCounts(existing: prevStateCounts, new: self.grid.stateCounts)
        return self.grid
    }
    
    /*func setCellInitializer(intPairs: [[Int]]) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
    }*/
    
    /*func setGrid2(rows: Int, cols: Int, grid: GridProtocol) {
        self.grid = grid
        self.grid.setConfiguration()
        let intPairsDict = self.grid.getConfiguration()
        self.cellInitializer = Grid.makeFancierCellInitializer(intPairsDict: intPairsDict)
        self.rows = rows
        self.cols = cols
        //notify()
    }*/
    
    /*func setGrid(rows: Int, cols: Int) {//, intPairs: [[Int]] = []) {
        //self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        //notify()
    }*/
    
    func setFancierGrid(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.cellInitializer = Grid.makeFancierCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        //notify()
    }
    
    func notify() {
        //delegate?.engineDidUpdate(withGrid: self.grid)
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
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
    
    /*func stepNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridStep")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["statistics" : self.grid.getStatistics()])
        nc.post(n)
    }
    
    func loadNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridLoad")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["statistics" : self.grid.getStatistics()])
        nc.post(n)
    }
    
    func resetNotify() {
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "GridReset")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["statistics" : self.grid.getStatistics()])
        nc.post(n)
    }*/
    
    static func getEngine() -> StandardEngine {
        return StandardEngine.engine
    }
}
