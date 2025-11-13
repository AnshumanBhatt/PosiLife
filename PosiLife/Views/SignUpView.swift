//
//  SignUpView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 09/10/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isLoading = false
    @State private var showError = false
    
    // Form fields
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.cozyLavender,
                    Color.softLavender,
                    Color.paleLavender
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 40)
                    
                    // App logo & title
                    VStack(spacing: 16) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 80))
                            .themedForeground("primaryText")
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("PosiLife")
                            .font(.system(size: 48, weight: .bold))
                            .themedForeground("primaryText")
                        
                        Text("Create your account")
                            .font(.title3)
                            .themedForeground("secondaryText")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    // Sign Up Form
                    VStack(spacing: 16) {
                        // Username field
                        HStack {
                            Image(systemName: "person.fill")
                                .themedForeground("secondaryText")
                                .frame(width: 20)
                            
                            TextField("Username", text: $username)
                                .textContentType(.username)
                                .autocapitalization(.none)
                                .themedForeground("primaryText")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal, 40)
                        
                        // Email field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .themedForeground("secondaryText")
                                .frame(width: 20)
                            
                            TextField("Email Address", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .themedForeground("primaryText")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal, 40)
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock.fill")
                                .themedForeground("secondaryText")
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .themedForeground("primaryText")
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(.newPassword)
                                    .autocapitalization(.none)
                                    .themedForeground("primaryText")
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .themedForeground("secondaryText")
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal, 40)
                        
                        // Sign Up Button
                        Button(action: {
                            handleSignUp()
                        }) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Create Account")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .themedForeground("primaryText")
                                    .shadow(color: Color.deepLavender.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 40)
                        
                        // Sign In link
                        Button(action: {
                            // Navigate to sign in - this would typically be handled by navigation
                        }) {
                            Text("Already have an account? Sign In")
                                .font(.subheadline)
                                .themedForeground("primaryText")
                                .underline()
                        }
                        .padding(.top, 8)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .themedForeground("divider")
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(.caption)
                            .themedForeground("secondaryText")
                            .padding(.horizontal, 8)
                        
                        Rectangle()
                            .themedForeground("divider")
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    
                    // Google Sign Up
                    VStack(spacing: 20) {
                        Button(action: {
                            signInWithGoogle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                    .themedForeground("secondaryText")
                                
                                Text("Sign up with Google")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .themedForeground("primaryText")
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .themedForeground("primaryText")
                                    .shadow(color: Color.deepLavender.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 40)
                        
                        Text("By creating an account, you agree to our Terms & Privacy Policy")
                            .font(.caption)
                            .themedForeground("secondaryText")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func handleSignUp() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signUp(username: username, email: email, password: password)
            } catch {
                authManager.errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                authManager.errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    SignUpView()
}
