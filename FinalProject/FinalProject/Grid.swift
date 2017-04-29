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
    subscript (row: Int, col: Int) -> CellState { get set }
    func next() -> Self //@discardableResult
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
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] }
        set { _cells[norm(row, to: size.rows)][norm(col, to: size.cols)] = newValue }
    }
    
    public init(_ rows: Int, _ cols: Int, cellInitializer: @escaping (GridPosition) -> CellState = { _, _ in .empty }) {
        _cells = [[CellState]](repeatElement( [CellState](repeatElement(.empty, count: rows)), count: cols))
        size = GridSize(rows, cols)
        lazyPositions(self.size).forEach { self[$0.row, $0.col] = cellInitializer($0) }
    }
}

extension Grid: Sequence {
    fileprivate var living: [GridPosition] {
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



// begin added for Final Project

//var intPairs: [[Int]] = [[0,1],[1,2],[2,0],[2,1],[2,2]]
//var gridConfig: [GridPosition] = Grid.IntPairsToGridConfig(intPairs: intPairs)

/*public func IntPairsToGridConfig(intPairs: [[Int]]) -> [GridPosition] {
    return intPairs.map { IntPairToGridPosition(intPair: $0) }
}

public func IntPairToGridPosition(intPair: [Int]) -> GridPosition {
    var pos: GridPosition
    pos.row = intPair[0]
    pos.col = intPair[1]
    return pos
}*/

/*public extension Grid {
    public static func IntPairsToGridConfig(intPairs: [[Int]]) -> [GridPosition] {
        return intPairs.map { GridPosition($0[0], $0[1]) }
    }
}*/

/*public extension Grid {
    public static func intPairsInitializer(pos: GridPosition) -> CellState {
        for position in gridConfig {
            if pos.row == position.row && pos.col == position.col {
                return .alive
            }
        }
        return .empty
    }
}*/

public extension Grid {
    public static func makeCellInitializer(intPairs: [[Int]]) -> (GridPosition) -> CellState {
        if intPairs.count == 0 {
            return {_,_ in .empty}
        }
        //var gc = Grid.IntPairsToGridConfig(intPairs: intPairs)
        var gc = intPairs.map { GridPosition($0[0], $0[1]) }
        func newCellInitializer(pos: GridPosition) -> CellState {
            for position in gc {
                if pos.row == position.row && pos.col == position.col {
                    return .alive
                }
            }
            return .empty
        }
        return newCellInitializer
    }
}

// end added for Final Project

public protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

public protocol EditorDelegate {
    func editorDidUpdate(withGrid: GridProtocol)
}
// modified for Final Project

public protocol EditorProtocol {
    var delegate: EditorDelegate? { get set }
    var grid: GridProtocol { get }
    var rows: Int { get set }
    var cols: Int { get set }
    var cellInitializer: (GridPosition) -> CellState { get set }
    //var gridConfig: [GridPosition]? { get set }
    init(rows: Int, cols: Int, intPairs: [[Int]])
}

class StandardEditor: EditorProtocol {
    var grid: GridProtocol
    var delegate: EditorDelegate?
    var cellInitializer: (GridPosition) -> CellState
    var rows: Int
    var cols: Int
    
    private static var editor: StandardEditor = StandardEditor(rows: 20, cols: 20)
    
    required init(rows: Int, cols: Int, intPairs: [[Int]] = []) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        delegate?.editorDidUpdate(withGrid: self.grid)
    }
    
    func setGridSize(rows: Int, cols: Int) {
        self.grid = Grid(rows, cols, cellInitializer: { _,_ in .empty})
        self.rows = rows
        self.cols = cols
        delegate?.editorDidUpdate(withGrid: self.grid)
    }
    
    static func getEditor() -> StandardEditor {
        return StandardEditor.editor
    }
}

public protocol EngineProtocol {
    var delegate: EngineDelegate? { get set }
    var grid: GridProtocol { get }
    var prevRefreshRate: Double { get set }
    var refreshRate: Double { get set } //how can you default this to zero?
    var refreshTimer: Timer? { get set }
    var rows: Int { get set }
    var cols: Int { get set }
    var cellInitializer: (GridPosition) -> CellState { get set }
    //var gridConfig: [GridPosition]? { get set }
    init(rows: Int, cols: Int, intPairs: [[Int]])
    func step() -> GridProtocol
}

class StandardEngine: EngineProtocol {
    var grid: GridProtocol
    var delegate: EngineDelegate?
    var cellInitializer: (GridPosition) -> CellState
    //var gridConfig: [GridPosition]?
    var rows: Int {
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
            delegate?.engineDidUpdate(withGrid: self.grid)
        }
    }
    var cols: Int {
        didSet {
            self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
            delegate?.engineDidUpdate(withGrid: self.grid)
        }
    }
    
    private static var engine: StandardEngine = StandardEngine(rows: 10, cols: 10)
    
    required init(rows: Int, cols: Int, intPairs: [[Int]] = []) {
        self.cellInitializer = Grid.makeCellInitializer(intPairs: intPairs)
        self.grid = Grid(rows, cols, cellInitializer: self.cellInitializer)
        self.rows = rows
        self.cols = cols
        delegate?.engineDidUpdate(withGrid: self.grid)
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
        delegate?.engineDidUpdate(withGrid: self.grid)
        return grid
    }
    
    func setGridSize(rows: Int, cols: Int) {
        self.grid = Grid(rows, cols, cellInitializer: { _,_ in .empty})
        self.rows = rows
        self.cols = cols
        delegate?.engineDidUpdate(withGrid: self.grid)
    }
    
    static func getEngine() -> StandardEngine {
        return StandardEngine.engine
    }
}
