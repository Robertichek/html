import SwiftUI

struct ContentView: View {
    @StateObject private var game = MinesweeperGame()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with title and stats
            VStack(spacing: 10) {
                Text("🔍 Сапер")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("💣")
                        Text("\(game.minesLeft)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text("⏰")
                        Text("\(game.timeElapsed)")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            
            // Game status
            if game.gameStatus != .playing {
                Text(game.gameStatus == .won ? "🎉 Победа!" : "💥 Поражение!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(game.gameStatus == .won ? .green : .red)
            }
            
            // Game grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: game.gridSize), spacing: 2) {
                ForEach(0..<game.cells.count, id: \.self) { index in
                    CellView(cell: game.cells[index]) {
                        game.revealCell(at: index)
                    } onFlag: {
                        game.toggleFlag(at: index)
                    }
                }
            }
            .padding()
            
            // New game button
            Button(action: {
                game.newGame()
            }) {
                Text("Новая игра")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            game.startTimer()
        }
    }
}

struct CellView: View {
    let cell: Cell
    let onTap: () -> Void
    let onFlag: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Rectangle()
                    .fill(cellBackgroundColor)
                    .border(Color.gray, width: 1)
                
                Text(cellText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
            }
        }
        .frame(width: 30, height: 30)
        .onLongPressGesture {
            onFlag()
        }
    }
    
    private var cellBackgroundColor: Color {
        if cell.isRevealed {
            return cell.isMine ? .red : .white
        } else {
            return .gray
        }
    }
    
    private var cellText: String {
        if cell.isFlagged && !cell.isRevealed {
            return "🚩"
        } else if cell.isRevealed {
            if cell.isMine {
                return "💣"
            } else if cell.adjacentMines > 0 {
                return "\(cell.adjacentMines)"
            }
        }
        return ""
    }
    
    private var textColor: Color {
        switch cell.adjacentMines {
        case 1: return .blue
        case 2: return .green
        case 3: return .red
        case 4: return .purple
        case 5: return .brown
        case 6: return .pink
        case 7: return .black
        case 8: return .gray
        default: return .black
        }
    }
}

#Preview {
    ContentView()
}