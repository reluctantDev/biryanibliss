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
                        
                        LazyVStack(spacing: 6) {
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
                    
                    // Action Buttons - Slick Design
                    VStack(spacing: 12) {
                        Text("🎮 Game Options")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)

                        HStack(spacing: 12) {
                            // Play Again Button - Compact
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
                                VStack(spacing: 6) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)

                                    Text("Play Again")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(16)
                                .shadow(color: .green.opacity(0.3), radius: 6, x: 0, y: 3)
                            }

                            // Back to Main Button - Compact
                            Button(action: {
                                // Go back to main screen without creating new game
                                dismiss()
                                isPresented = false
                                // Call the callback to dismiss all views and return to main
                                onNewGame?()
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)

                                    Text("Main Screen")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                        }

                        // Compact info text
                        VStack(spacing: 2) {
                            Text("Play Again: New session with same players")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)

                            Text("Main Screen: Return to home")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
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
        HStack(spacing: 12) {
            // Compact Rank Badge
            ZStack {
                Circle()
                    .fill(isWinner ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)

                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Player Info - Expanded Layout (No Avatar)
            HStack(spacing: 12) {
                // Player Name and Status
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(player.name)
                            .font(.system(size: 15, weight: .semibold))
                            .lineLimit(1)

                        if isWinner {
                            Text("🏆")
                                .font(.system(size: 12))
                        }
                    }

                    Text("\(player.buyIns) buy-in\(player.buyIns > 1 ? "s" : "")")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Credits - More Space
                VStack(alignment: .center, spacing: 2) {
                    Text("Credits")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text("\(Int(player.totalCredits))")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(isWinner ? .green : .primary)
                }

                // Profit/Loss Amount - More Space
                VStack(alignment: .center, spacing: 2) {
                    Text("P/L Amount")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    HStack(spacing: 2) {
                        Image(systemName: isProfit ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10))
                            .foregroundColor(isProfit ? .green : .red)

                        Text("\(isProfit ? "+" : "")\(Int(creditsChange))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isProfit ? .green : .red)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isWinner ? Color.yellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isWinner ? Color.yellow : Color.clear, lineWidth: 1.5)
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
