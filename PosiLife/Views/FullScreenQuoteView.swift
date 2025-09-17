//
//  FullScreenQuoteView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 05/09/25.
//

import SwiftUI

struct FullScreenQuoteView: View {
    let quote: Quote
    @Binding var isPresented: Bool
    let theme: AppTheme
    
    @State private var showQuote = false
    @State private var showAuthor = false
    @State private var showCloseButton = false
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground(theme: theme)
                .ignoresSafeArea()
            
            // Floating particles
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(getThemeColor(theme.primaryColor).opacity(0.3))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(
                        Animation.linear(duration: particle.duration)
                            .repeatForever(autoreverses: false),
                        value: particle.position
                    )
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Quote category icon
                VStack(spacing: 16) {
                    Image(systemName: quote.category.icon)
                        .font(.system(size: 60))
                        .foregroundColor(getThemeColor(quote.category.color))
                        .scaleEffect(showQuote ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showQuote)
                    
                    Text(quote.category.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(getThemeColor(quote.category.color))
                        .opacity(showQuote ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: showQuote)
                }
                
                // Main quote
                VStack(spacing: 24) {
                    Text(quote.text)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showQuote ? 1 : 0)
                        .scaleEffect(showQuote ? 1 : 0.8)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: showQuote)
                    
                    // Author
                    Text("— \(quote.author)")
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                        .italic()
                        .opacity(showAuthor ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(1.2), value: showAuthor)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 32) {
                    Button(action: shareQuote) {
                        VStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            Text("Share")
                                .font(.caption)
                        }
                        .foregroundColor(getThemeColor(theme.primaryColor))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(getThemeColor(theme.primaryColor).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(getThemeColor(theme.primaryColor).opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: dismissView) {
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                            Text("Thanks")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            getThemeColor(theme.primaryColor),
                                            getThemeColor(theme.secondaryColor)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                .opacity(showCloseButton ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.8), value: showCloseButton)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startAnimationSequence()
            createParticles()
        }
        .preferredColorScheme(.light)
    }
    
    private func startAnimationSequence() {
        withAnimation {
            showQuote = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showAuthor = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation {
                showCloseButton = true
            }
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 4...12),
                duration: Double.random(in: 8...15)
            )
        }
        
        // Animate particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for i in particles.indices {
                particles[i].position = CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
            }
        }
    }
    
    private func shareQuote() {
        let activityVC = UIActivityViewController(
            activityItems: ["\"\(quote.text)\" - \(quote.author)"],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showQuote = false
            showAuthor = false
            showCloseButton = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, theme: theme)
    }
}

struct AnimatedBackground: View {
    let theme: AppTheme
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: getThemeColor(theme.primaryColor).opacity(0.8), location: animateGradient ? 0.0 : 0.2),
                .init(color: getThemeColor(theme.secondaryColor).opacity(0.6), location: animateGradient ? 0.5 : 0.7),
                .init(color: Color.black.opacity(0.1), location: animateGradient ? 1.0 : 0.8)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
    
    private func getThemeColor(_ colorName: String) -> Color {
        return Color.getThemeColor(for: colorName, theme: theme)
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    let duration: Double
}

#Preview {
    FullScreenQuoteView(
        quote: Quote(
            text: "The only way to do great work is to love what you do.",
            author: "Steve Jobs",
            category: .motivation
        ),
        isPresented: .constant(true),
        theme: .serenePink
    )
}
