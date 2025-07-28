import Foundation
import SwiftUI

enum GameStatus {
    case playing
    case won
    case lost
}

struct Cell {
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}

class MinesweeperGame: ObservableObject {
    @Published var cells: [Cell] = []
    @Published var gameStatus: GameStatus = .playing
    @Published var minesLeft: Int = 0
    @Published var timeElapsed: Int = 0
    
    let gridSize: Int = 10
    let totalMines: Int = 20
    
    private var timer: Timer?
    private var gameStarted: Bool = false
    
    init() {
        newGame()
    }
    
    func newGame() {
        gameStatus = .playing
        gameStarted = false
        timeElapsed = 0
        minesLeft = totalMines
        timer?.invalidate()
        
        // Initialize empty grid
        cells = Array(repeating: Cell(), count: gridSize * gridSize)
        
        // Place mines randomly
        placeMines()
        
        // Calculate adjacent mine counts
        calculateAdjacentMines()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.gameStatus == .playing && self.gameStarted {
                self.timeElapsed += 1
            }
        }
    }
    
    private func placeMines() {
        var minesPlaced = 0
        let totalCells = gridSize * gridSize
        
        while minesPlaced < totalMines {
            let randomIndex = Int.random(in: 0..<totalCells)
            
            if !cells[randomIndex].isMine {
                cells[randomIndex].isMine = true
                minesPlaced += 1
            }
        }
    }
    
    private func calculateAdjacentMines() {
        for i in 0..<cells.count {
            if !cells[i].isMine {
                cells[i].adjacentMines = countAdjacentMines(at: i)
            }
        }
    }
    
    private func countAdjacentMines(at index: Int) -> Int {
        let neighbors = getNeighborIndices(for: index)
        return neighbors.reduce(0) { count, neighborIndex in
            count + (cells[neighborIndex].isMine ? 1 : 0)
        }
    }
    
    private func getNeighborIndices(for index: Int) -> [Int] {
        let row = index / gridSize
        let col = index % gridSize
        var neighbors: [Int] = []
        
        for deltaRow in -1...1 {
            for deltaCol in -1...1 {
                if deltaRow == 0 && deltaCol == 0 { continue }
                
                let newRow = row + deltaRow
                let newCol = col + deltaCol
                
                if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                    neighbors.append(newRow * gridSize + newCol)
                }
            }
        }
        
        return neighbors
    }
    
    func revealCell(at index: Int) {
        guard gameStatus == .playing && !cells[index].isRevealed && !cells[index].isFlagged else {
            return
        }
        
        if !gameStarted {
            gameStarted = true
        }
        
        cells[index].isRevealed = true
        
        if cells[index].isMine {
            // Game over - reveal all mines
            revealAllMines()
            gameStatus = .lost
            timer?.invalidate()
        } else {
            // If cell has no adjacent mines, reveal all adjacent cells
            if cells[index].adjacentMines == 0 {
                revealAdjacentCells(at: index)
            }
            
            // Check if player won
            checkWinCondition()
        }
    }
    
    func toggleFlag(at index: Int) {
        guard gameStatus == .playing && !cells[index].isRevealed else {
            return
        }
        
        cells[index].isFlagged.toggle()
        minesLeft += cells[index].isFlagged ? -1 : 1
    }
    
    private func revealAdjacentCells(at index: Int) {
        let neighbors = getNeighborIndices(for: index)
        
        for neighborIndex in neighbors {
            if !cells[neighborIndex].isRevealed && !cells[neighborIndex].isFlagged {
                revealCell(at: neighborIndex)
            }
        }
    }
    
    private func revealAllMines() {
        for i in 0..<cells.count {
            if cells[i].isMine {
                cells[i].isRevealed = true
            }
        }
    }
    
    private func checkWinCondition() {
        let revealedNonMines = cells.filter { !$0.isMine && $0.isRevealed }.count
        let totalNonMines = gridSize * gridSize - totalMines
        
        if revealedNonMines == totalNonMines {
            gameStatus = .won
            timer?.invalidate()
            
            // Flag all remaining mines
            for i in 0..<cells.count {
                if cells[i].isMine && !cells[i].isFlagged {
                    cells[i].isFlagged = true
                }
            }
            minesLeft = 0
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}