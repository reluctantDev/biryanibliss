import SwiftUI

struct GameEndView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var finalCredits: [UUID: String] = [:]
    @State private var showingLeaderboard = false

    private var totalFinalCredits: Double {
        finalCredits.values.compactMap { Double($0) }.reduce(0, +)
    }

    private var isFinishEnabled: Bool {
        // Check if all players have entered credits and total matches total pot credits
        let allEntered = gameManager.players.allSatisfy { player in
            if let creditString = finalCredits[player.id], !creditString.isEmpty {
                return Double(creditString) != nil
            }
            return false
        }
        return allEntered && abs(totalFinalCredits - gameManager.totalPotCredits) < 0.01
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "flag.checkered.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)

                        Text("Enter Final Credits")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text("Enter each player's final credit amount. Total must equal \(Int(gameManager.totalPotCredits)) credits.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                
                // Summary
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("Required Total")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.totalPotCredits))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 2) {
                            Text("Current Total")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(totalFinalCredits))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isFinishEnabled ? .green : .red)
                        }

                        VStack(spacing: 2) {
                            Text("Status")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(isFinishEnabled ? "✓ Match" : "✗ \(Int(abs(totalFinalCredits - gameManager.totalPotCredits))) off")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isFinishEnabled ? .green : .red)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Player Final Credits Input
                LazyVStack(spacing: 12) {
                    ForEach(gameManager.players) { player in
                        FinalCreditsCard(
                            player: player,
                            gameManager: gameManager,
                            finalCredits: Binding(
                                get: { finalCredits[player.id] ?? "" },
                                set: { finalCredits[player.id] = $0 }
                            )
                        )
                    }
                }
                .padding(.horizontal, 12)
                
                // Action Buttons
                VStack(spacing: 8) {
                    Button(action: {
                        // Update final credits and show leaderboard
                        for player in gameManager.players {
                            if let creditString = finalCredits[player.id],
                               let finalCredit = Double(creditString) {
                                gameManager.updatePlayerCredits(playerId: player.id, newCredits: finalCredit)
                            }
                        }
                        // Show leaderboard
                        showingLeaderboard = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline)

                            Text("Finish Game")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .background(isFinishEnabled ? Color.green : Color.gray)
                        .cornerRadius(16)
                    }
                    .disabled(!isFinishEnabled)

                    Button(action: {
                        dismiss()
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .padding(12)
                }
                .padding(.bottom, 12)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
        .onAppear {
            // Initialize final credits with initial buy-in values (not current credits)
            for player in gameManager.players {
                let initialCredits = gameManager.creditsPerBuyIn * Double(player.buyIns)
                finalCredits[player.id] = String(Int(initialCredits))
            }
        }
        .fullScreenCover(isPresented: $showingLeaderboard) {
            LeaderboardView(gameManager: gameManager, isPresented: $isPresented)
        }
    }
}

struct FinalCreditsCard: View {
    let player: Player
    let gameManager: GameManager
    @Binding var finalCredits: String

    private var initialCredits: Int {
        return Int(gameManager.creditsPerBuyIn * Double(player.buyIns))
    }

    var body: some View {
        HStack(spacing: 12) {
            // Player Avatar
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )

            // Player Info
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Initial: \(initialCredits)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Final Credits Input
            HStack(spacing: 4) {
                Text("Final:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("0", text: $finalCredits)
                    .font(.caption)
                    .fontWeight(.medium)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground))
                    .cornerRadius(6)

                Text("Credits")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct GameEndView_Previews: PreviewProvider {
    static var previews: some View {
        GameEndView(
            gameManager: GameManager(),
            isPresented: .constant(true)
        )
    }
}
