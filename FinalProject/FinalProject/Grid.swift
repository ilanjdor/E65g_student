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
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self //@discardableResult
    mutating func setConfiguration()
    func getConfiguration() -> [String:[[Int]]]
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
    public func getConfiguration() -> [String:[[Int]]] {
        return configuration
    }

    private var _cells: [[CellState]]
    public let size: GridSize
    public var configuration: [String:[[Int]]] = [:]
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: @escaping (GridPosition) -> CellState = { _, _ in .empty }) {
        //_cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: rows)), count: cols))
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
    public static func getGridConfiguration(grid: GridProtocol) -> [String:[[Int]]] {
        var configuration: [String:[[Int]]] = [:]
        lazyPositions(grid.size).forEach {
            switch grid[$0.row, $0.col] {
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
        return configuration
    }
    /*public static func setGridConfiguration([String:[[Int]]]) -> GridProtocol {
        var grid: GridProtocol = Grid(
        lazyPositions(self.size).forEach {
            
        }
    }*/
}*/
    
public extension Grid {
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
}

public extension Grid {
    public static func makeFancierCellInitializer(intPairsDict: [String:[[Int]]]) -> (GridPosition) -> CellState {
        if intPairsDict.count == 0 {
            return {_,_ in .empty}
        }
        var alivePositions: [GridPosition] = []
        var bornPositions: [GridPosition] = []
        var diedPositions: [GridPosition] = []
        if let aliveIntPairs = intPairsDict["alive"] {
            alivePositions = aliveIntPairs.map { GridPosition($0[0], $0[1]) }
        }
        if let bornIntPairs = intPairsDict["born"] {
            bornPositions = bornIntPairs.map { GridPosition($0[0], $0[1]) }
        }
        if let diedIntPairs = intPairsDict["died"] {
            diedPositions = diedIntPairs.map { GridPosition($0[0], $0[1]) }
        }
        func cellInitializer(pos: GridPosition) -> CellState {
            for position in alivePositions {
                if pos.row == position.row && pos.col == position.col {
                    return .alive
                }
            }
            for position in bornPositions {
                if pos.row == position.row && pos.col == position.col {
                    return .born
                }
            }
            for position in diedPositions {
                if pos.row == position.row && pos.col == position.col {
                    return .died
                }
            }
            return .empty
        }
        return cellInitializer
    }
}

public protocol EngineProtocol {
    var grid: GridProtocol { get set }
    var prevRefreshRate: Double { get set }
    var refreshRate: Double { get set }
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    var cellInitializer: (GridPosition) -> CellState { get set }
    init(rows: Int, cols: Int, intPairs: [[Int]])
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    static var defaultGridSize: Int = 10
    var grid: GridProtocol {
        didSet {
            self.rows = grid.size.rows
            self.cols = grid.size.cols
            notify()
        }
    }
    var cellInitializer: (GridPosition) -> CellState
    var rows: Int /*{
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
            delegate?.engineDidUpdate(withGrid: self.grid)
        }
    }*/
    var cols: Int /*{
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
            delegate?.engineDidUpdate(withGrid: self.grid)
        }
    }*/
    
    private static var engine: StandardEngine = StandardEngine(rows: defaultGridSize, cols: defaultGridSize)
    
    required init(rows: Int, cols: Int, intPairs: [[Int]] = []) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        //self.grid.configuration = [:]
        self.grid.setConfiguration()
        notify()
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
        let newGrid = grid.next()
        self.grid = newGrid
        //notify()
        return grid
    }
    
    func setCellInitializer(intPairs: [[Int]]) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
    }
    
    func setGrid(rows: Int, cols: Int, intPairs: [[Int]] = []) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        notify()
    }
    
    func setFancierGrid(rows: Int, cols: Int, intPairsDict: [String:[[Int]]] = [:]) {
        self.cellInitializer = Grid.makeFancierCellInitializer(intPairsDict: intPairsDict)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        notify()
    }
    
    func notify() {
        //self.grid.setConfiguration()
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    static func getEngine() -> StandardEngine {
        return StandardEngine.engine
    }
}
