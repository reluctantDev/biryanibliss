//
//  BouncingImageView.swift
//  chiptally
//
//  Created by Rahul Yarlagadda on 8/22/25.
//

import SwiftUI

struct BouncingImageView: View {
    let imageName: String
    let imageSize: CGFloat

    @State private var xPosition: CGFloat = 100
    @State private var yPosition: CGFloat = 100
    @State private var xVelocity: CGFloat = 2
    @State private var yVelocity: CGFloat = 3
    @State private var screenWidth: CGFloat = 400
    @State private var screenHeight: CGFloat = 600

    init(imageName: String = "creditcard.fill", imageSize: CGFloat = 30) {
        self.imageName = imageName
        self.imageSize = imageSize
    }

    var body: some View {
        GeometryReader { geometry in
            let imageView = Image(systemName: imageName)
                .font(.system(size: imageSize))
                .foregroundColor(.blue)

            imageView
                .position(x: xPosition, y: yPosition)
                .onAppear {
                    setupScreen(geometry: geometry)
                    startAnimation()
                }
                .onChange(of: geometry.size) { newSize in
                    updateScreenSize(newSize)
                }
        }
    }

    private func setupScreen(geometry: GeometryProxy) {
        screenWidth = geometry.size.width
        screenHeight = geometry.size.height
    }

    private func updateScreenSize(_ newSize: CGSize) {
        screenWidth = newSize.width
        screenHeight = newSize.height
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updatePosition()
        }
    }

    private func updatePosition() {
        // Update positions
        xPosition += xVelocity
        yPosition += yVelocity

        // Check boundaries and bounce
        let halfSize = imageSize / 2

        if xPosition <= halfSize || xPosition >= screenWidth - halfSize {
            xVelocity *= -1
        }

        if yPosition <= halfSize || yPosition >= screenHeight - halfSize {
            yVelocity *= -1
        }

        // Constrain to bounds
        xPosition = max(halfSize, min(screenWidth - halfSize, xPosition))
        yPosition = max(halfSize, min(screenHeight - halfSize, yPosition))
    }
}

struct SimpleBouncingView: View {
    let imageName: String
    let imageSize: CGFloat
    
    @State private var bounceOffset: CGFloat = 0
    
    init(imageName: String = "creditcard.fill", imageSize: CGFloat = 25) {
        self.imageName = imageName
        self.imageSize = imageSize
    }
    
    var body: some View {
        Image(systemName: imageName)
            .font(.system(size: imageSize))
            .foregroundColor(.orange)
            .offset(y: bounceOffset)
            .onAppear {
                startSimpleBounce()
            }
    }
    
    private func startSimpleBounce() {
        withAnimation(
            Animation.easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
        ) {
            bounceOffset = -15
        }
    }
}

struct FloatingBouncingView: View {
    let imageName: String
    let imageSize: CGFloat
    
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    init(imageName: String = "star.fill", imageSize: CGFloat = 20) {
        self.imageName = imageName
        self.imageSize = imageSize
    }
    
    var body: some View {
        Image(systemName: imageName)
            .font(.system(size: imageSize))
            .foregroundColor(.yellow)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                startFloatingAnimation()
            }
    }
    
    private func startFloatingAnimation() {
        // X movement
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            xOffset = 30
        }
        
        // Y movement with different timing
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            yOffset = -20
        }
        
        // Rotation
        withAnimation(
            Animation.linear(duration: 3.0)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }
}

// Multiple bouncing images
struct MultipleBouncingView: View {
    let imageNames: [String]
    let imageSize: CGFloat

    init(imageNames: [String] = ["creditcard.fill", "star.fill", "heart.fill"],
         imageSize: CGFloat = 20) {
        self.imageNames = imageNames
        self.imageSize = imageSize
    }

    var body: some View {
        ZStack {
            ForEach(0..<imageNames.count, id: \.self) { index in
                let imageName = imageNames[index]
                let bouncingView = BouncingImageView(
                    imageName: imageName,
                    imageSize: imageSize
                )

                bouncingView
                    .opacity(0.7)
            }
        }
    }
}

// Full screen bouncing overlay
struct FullScreenBouncingOverlay: View {
    let imageName: String
    let imageSize: CGFloat

    init(imageName: String = "creditcard.fill", imageSize: CGFloat = 25) {
        self.imageName = imageName
        self.imageSize = imageSize
    }

    var body: some View {
        let bouncingView = BouncingImageView(
            imageName: imageName,
            imageSize: imageSize
        )

        bouncingView
            .allowsHitTesting(false)
            .opacity(0.3)
    }
}

struct BouncingImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            Text("Simple Bounce")
                .font(.headline)

            SimpleBouncingView()

            Text("Floating Animation")
                .font(.headline)

            FloatingBouncingView()

            Text("Screen Bouncing")
                .font(.headline)

            BouncingImageView()
                .frame(height: 200)
                .border(Color.gray)
        }
        .padding()
    }
}
