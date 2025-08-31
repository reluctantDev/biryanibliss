import SwiftUI

struct ScoreBoardView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "list.number")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Score Board")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Manage player scores")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Game Summary
                VStack(spacing: 16) {
                    Text("Game Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Total Credits")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.totalPotCredits))")
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
                            Text("Credits per Player")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(gameManager.creditsPerPlayer))")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Players Score List
                VStack(spacing: 16) {
                    HStack {
                        Text("Player Scores")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button(action: {
                            // Reset all scores
                            for i in gameManager.players.indices {
                                gameManager.players[i].score = 0
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                                Text("Reset All")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red)
                            .cornerRadius(15)
                        }
                    }
                    
                    if gameManager.players.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No players added")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Add players to start scoring")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(gameManager.players.enumerated()), id: \.element.id) { index, player in
                                    PlayerScoreCard(
                                        player: player,
                                        onScoreChange: { newScore in
                                            gameManager.updatePlayerScore(playerId: player.id, newScore: newScore)
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                // Done Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
}

struct PlayerScoreCard: View {
    let player: Player
    let onScoreChange: (Int) -> Void
    
    @State private var showingScoreInput = false
    @State private var tempScore = ""
    
    var body: some View {
        HStack(spacing: 16) {
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
                
                Text("Credits: \(Int(player.totalCredits))")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            // Score Display and Edit
            VStack(spacing: 8) {
                Text("Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Button(action: {
                        onScoreChange(player.score - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    
                    Text("\(player.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .frame(minWidth: 40)
                        .onTapGesture {
                            tempScore = "\(player.score)"
                            showingScoreInput = true
                        }
                    
                    Button(action: {
                        onScoreChange(player.score + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .alert("Update Score", isPresented: $showingScoreInput) {
            TextField("Score", text: $tempScore)
                .keyboardType(.numberPad)
            
            Button("Update") {
                if let newScore = Int(tempScore) {
                    onScoreChange(newScore)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter new score for \(player.name)")
        }
    }
}

struct ScoreBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreBoardView(gameManager: GameManager())
    }
}
