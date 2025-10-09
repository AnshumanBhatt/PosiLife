//
//  AuthenticationManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 09/10/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    static let shared = AuthenticationManager()
    
    private init() {
        // Check if user is already signed in
        self.user = Auth.auth().currentUser
        self.isAuthenticated = user != nil
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws {
        // Get the client ID from Firebase configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }
        
        // Configure Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        // Start the sign in flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.tokenError
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in to Firebase
        try await Auth.auth().signIn(with: credential)
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Sign out from Firebase
        try Auth.auth().signOut()
        
        self.user = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Delete user from Firebase
        try await user.delete()
        
        self.user = nil
        self.isAuthenticated = false
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case tokenError
    case noUser
    
    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Google Client ID"
        case .noRootViewController:
            return "Could not find root view controller"
        case .tokenError:
            return "Failed to get authentication token"
        case .noUser:
            return "No user is currently signed in"
        }
    }
}
