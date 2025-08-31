import SwiftUI

struct GamePlayView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingGameEnd = false
    @State private var showingRestartAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Subtle bouncing animation in background
                SimpleBouncingView(imageName: "dollarsign.circle.fill", imageSize: 20)
                    .position(x: 350, y: 80)
                    .opacity(0.2)

                ScrollView {
                    VStack(spacing: 12) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("Credit Manager")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

                        Spacer()

                        Button(action: {
                            // Show game options
                        }) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Game Summary
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("Total Credits")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.getTotalPotInCredits()))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }

                        VStack(spacing: 2) {
                            Text("Players")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(gameManager.players.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        VStack(spacing: 2) {
                            Text("Total Credits")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.getTotalPotInCredits()))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(12)
                .background(Color(.systemBackground))

                // Players List
                LazyVStack(spacing: 12) {
                    ForEach(Array(gameManager.players.enumerated()), id: \.element.id) { index, player in
                        PlayerGameCard(
                            player: player,
                            onNameChange: { newName in
                                gameManager.updatePlayerName(playerId: player.id, newName: newName)
                            },
                            onBuyInsChange: { newBuyIns in
                                gameManager.updatePlayerBuyIns(playerId: player.id, newBuyIns: newBuyIns)
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                
                // Action Buttons
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button(action: {
                            showingGameEnd = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "flag.checkered.circle.fill")
                                    .font(.subheadline)

                                Text("End Game")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(16)
                        }

                        Button(action: {
                            showingRestartAlert = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.subheadline)

                                Text("Restart")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(16)
                        }
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Setup")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .padding(12)
                .background(Color(.systemBackground))
                }
                .padding(.bottom, 12)
                }
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingGameEnd) {
            GameEndView(gameManager: gameManager, isPresented: $showingGameEnd)
        }
        .alert("Restart Game", isPresented: $showingRestartAlert) {
            Button("Restart", role: .destructive) {
                gameManager.resetGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset the entire game and return to setup. Are you sure?")
        }
    }
}

struct PlayerGameCard: View {
    let player: Player
    let onNameChange: (String) -> Void
    let onBuyInsChange: (Int) -> Void

    @State private var showingNameInput = false
    @State private var tempName = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Player Header with Editable Name
            HStack {
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

                // Player Name (Editable)
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .onTapGesture {
                            tempName = player.name
                            showingNameInput = true
                        }

                    Text("Tap to edit")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Edit Name Button
                Button(action: {
                    tempName = player.name
                    showingNameInput = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            // Buy-ins and Credits in single row
            HStack {
                // Buy-ins
                HStack(spacing: 4) {
                    Text("Buy-ins:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        if player.buyIns > 1 {
                            onBuyInsChange(player.buyIns - 1)
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Text("\(player.buyIns)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(minWidth: 20)

                    Button(action: {
                        onBuyInsChange(player.buyIns + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Initial Credits (Non-editable)
                HStack(spacing: 4) {
                    Text("Initial Credits:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(player.totalCredits))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .frame(minWidth: 30)
                }
            }

        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Edit Player Name", isPresented: $showingNameInput) {
            TextField("Player name", text: $tempName)
                .textInputAutocapitalization(.words)
            
            Button("Update") {
                let trimmedName = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedName.isEmpty && trimmedName.count >= 2 {
                    onNameChange(trimmedName)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter new name for this player")
        }
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(gameManager: GameManager())
    }
}
