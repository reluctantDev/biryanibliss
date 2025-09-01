import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    var onNewGame: (() -> Void)?
    
    var sortedPlayers: [Player] {
        gameManager.players.sorted { $0.totalCredits > $1.totalCredits }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Celebratory bouncing animations
                FloatingBouncingView(imageName: "star.fill", imageSize: 18)
                    .position(x: 60, y: 120)
                    .opacity(0.6)

                FloatingBouncingView(imageName: "trophy.fill", imageSize: 16)
                    .position(x: 320, y: 100)
                    .opacity(0.5)

                SimpleBouncingView(imageName: "crown.fill", imageSize: 14)
                    .position(x: 350, y: 200)
                    .opacity(0.4)

                ScrollView {
                    VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("Game Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Final Leaderboard")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Game Summary
                    VStack(spacing: 12) {
                        Text("Game Summary")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Total Credits")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(gameManager.getTotalPotInCredits()))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Players")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(gameManager.players.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Buy-in Amount")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(gameManager.creditsPerBuyIn))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Leaderboard
                    VStack(spacing: 16) {
                        Text("Final Standings")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                                LeaderboardCard(
                                    player: player,
                                    rank: index + 1,
                                    isWinner: index == 0,
                                    gameManager: gameManager
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Action Buttons
                    VStack(spacing: 20) {
                        Text("🎮 Game Options")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        VStack(spacing: 16) {
                            Button(action: {
                                // Create new game session and go back to main screen
                                if let newSession = gameManager.createGameSession() {
                                    dismiss()
                                    isPresented = false
                                    // Call the callback to dismiss all views and return to main
                                    onNewGame?()
                                }
                                // If session creation fails (limit reached), stay on current screen
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)

                                    Text("Play Again")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(25)
                                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            }

                            Button(action: {
                                // Go back to main screen without creating new game
                                dismiss()
                                isPresented = false
                                // Call the callback to dismiss all views and return to main
                                onNewGame?()
                            }) {
                                HStack {
                                    Image(systemName: "house.fill")
                                        .font(.title2)

                                    Text("Back to Main Screen")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }

                            // Additional info text
                            VStack(spacing: 4) {
                                Text("• Play Again: Creates new game session with same players")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)

                                Text("• Back to Main Screen: Return to home without new game")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding()
                .padding(.bottom, 20) // Extra bottom padding to ensure buttons are visible
                }
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
        }
    }
}

struct LeaderboardCard: View {
    let player: Player
    let rank: Int
    let isWinner: Bool
    let gameManager: GameManager
    
    private var creditsChange: Double {
        return player.totalCredits - gameManager.creditsPerBuyIn * Double(player.buyIns)
    }
    
    private var isProfit: Bool {
        return creditsChange > 0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(isWinner ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Player Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if isWinner {
                    Text("🏆 Winner")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                
                Text("\(player.buyIns) buy-in\(player.buyIns > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Credits and Change
            VStack(alignment: .trailing, spacing: 4) {
                Text("Final Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(player.totalCredits))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isWinner ? .green : .primary)
                
                HStack(spacing: 2) {
                    Image(systemName: isProfit ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(isProfit ? .green : .red)
                    
                    Text("\(isProfit ? "+" : "")\(Int(creditsChange))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isProfit ? .green : .red)
                }
            }
        }
        .padding()
        .background(isWinner ? Color.yellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isWinner ? Color.yellow : Color.clear, lineWidth: 2)
        )
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(
            gameManager: GameManager(),
            isPresented: .constant(true)
        )
    }
}
