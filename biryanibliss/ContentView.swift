//
//  ContentView.swift
//  chiptally
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                VStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Credit Manager")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Manage buy-ins and credits")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Game Setup
                VStack(spacing: 16) {
                    Text("Game Configuration")
                        .font(.headline)
                        .fontWeight(.semibold)
                    

                    
                    // Buy-in Credits (Editable)
                    HStack {
                        Text("Buy-in Credits:")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Spacer()

                        TextField("200", value: $gameManager.creditsPerBuyIn, format: .number)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: gameManager.creditsPerBuyIn) { _ in
                                gameManager.updateTotalPotCredits()
                            }

                        Text("Credits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Number of Players
                    HStack {
                        Text("Number of Players:")
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            if gameManager.numberOfPlayers > 1 {
                                gameManager.numberOfPlayers -= 1
                                gameManager.updateTotalPotCredits()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }

                        Text("\(gameManager.numberOfPlayers)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(minWidth: 30)

                        Button(action: {
                            if gameManager.numberOfPlayers < 12 {
                                gameManager.numberOfPlayers += 1
                                gameManager.updateTotalPotCredits()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Total Pot Credits (Display Only)
                    HStack {
                        Text("Total Pot Credits:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(gameManager.totalPotCredits))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)

                        Text("Credits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                // Start Game Button
                Button(action: {
                    // Generate default players and start game
                    gameManager.generateDefaultPlayers()
                    showingGame = true
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        
                        Text("Start Game")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
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
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showingGame) {
            GamePlayView(gameManager: gameManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
