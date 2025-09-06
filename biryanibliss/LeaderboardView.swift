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
            ScrollView {
                VStack(spacing: 24) {
                    // Header - Similar to GameResultsView
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("Game Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Final Results")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Winner Section - Similar to GameResultsView
                    if let winner = sortedPlayers.first {
                        VStack(spacing: 8) {
                            Text("🏆 Biggest Winner")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)

                            Text(winner.name)
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("\(Int(winner.totalCredits)) credits")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                                .fontWeight(.semibold)
                        }
                        .padding(12)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Final Standings - Similar to GameResultsView
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Final Credit Standings")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(spacing: 8) {
                            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                                LeaderboardPlayerCard(
                                    player: player,
                                    position: index + 1,
                                    gameManager: gameManager
                                )
                            }
                        }
                    }

                    // Game Statistics - Similar to GameResultsView
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Statistics")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(spacing: 12) {
                            StatRow(label: "Players", value: "\(gameManager.players.count)")
                            StatRow(label: "Buy-in Amount", value: "\(Int(gameManager.creditsPerBuyIn)) credits")
                            StatRow(label: "Total Credits", value: "\(Int(gameManager.getTotalPotInCredits())) credits")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
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
            .navigationBarHidden(true)
        }
    }
}

struct LeaderboardPlayerCard: View {
    let player: Player
    let position: Int
    let gameManager: GameManager

    private var positionColor: Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }

    private var positionIcon: String {
        switch position {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        case 3: return "3.circle.fill"
        default: return "\(position).circle"
        }
    }

    private var profitLoss: Double {
        let invested = Double(player.buyIns) * gameManager.creditsPerBuyIn
        return player.totalCredits - invested
    }

    private var profitLossColor: Color {
        profitLoss >= 0 ? .green : .red
    }

    private var profitLossText: String {
        if profitLoss >= 0 {
            return "+\(Int(profitLoss))"
        } else {
            return "-\(Int(abs(profitLoss)))"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Position
            Image(systemName: positionIcon)
                .font(.title2)
                .foregroundColor(positionColor)
                .frame(width: 30)

            // Player Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )

            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("\(player.buyIns) buy-in\(player.buyIns == 1 ? "" : "s") • Invested: \(Int(Double(player.buyIns) * gameManager.creditsPerBuyIn)) credits")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Final: \(Int(player.totalCredits)) credits")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Spacer()

            // Credits and Profit/Loss
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(player.totalCredits))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(profitLossText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(profitLossColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
