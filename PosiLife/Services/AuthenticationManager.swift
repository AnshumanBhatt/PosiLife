//
//  AuthenticationManager.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 09/10/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    static let shared = AuthenticationManager()
    
    private let db = Firestore.firestore()
    
    private init() {
        // Check if user is already signed in
        self.user = Auth.auth().currentUser
        self.isAuthenticated = user != nil
        
        // Load user profile if authenticated
        if let user = user {
            Task {
                await loadUserProfile(userId: user.uid)
            }
        }
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
            
            if let user = user {
                Task {
                    await self?.loadUserProfile(userId: user.uid)
                }
            } else {
                self?.userProfile = nil
            }
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
    
    // MARK: - Email/Password Authentication
    func signUp(username: String, email: String, password: String) async throws {
        print("🔍 DEBUG: Starting sign up process...")
        print("🔍 DEBUG: Username: \(username), Email: \(email)")
        
        // Validate inputs
        guard !username.isEmpty else {
            print("🔍 DEBUG: Username validation failed - empty")
            throw AuthError.invalidUsername
        }
        
        guard !email.isEmpty else {
            print("🔍 DEBUG: Email validation failed - empty")
            throw AuthError.invalidEmail
        }
        
        guard password.count >= 6 else {
            print("🔍 DEBUG: Password validation failed - too short")
            throw AuthError.weakPassword
        }
        
        // Create user in Firebase Auth
        print("🔍 DEBUG: Creating user in Firebase Auth...")
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        print("🔍 DEBUG: Firebase Auth user created with UID: \(authResult.user.uid)")
        
        // Create user profile in Firestore
        let profile = UserProfile(id: authResult.user.uid, username: username, email: email)
        print("🔍 DEBUG: Created UserProfile: \(profile)")
        
        try await saveUserProfile(profile)
        print("🔍 DEBUG: UserProfile saved to Firestore")
        
        self.userProfile = profile
        print("🔍 DEBUG: UserProfile set in AuthenticationManager: \(self.userProfile?.username ?? "nil")")
    }
    
    func signIn(email: String, password: String) async throws {
        // Validate inputs
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        guard !password.isEmpty else {
            throw AuthError.invalidPassword
        }
        
        // Sign in with Firebase Auth
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        // Load user profile
        await loadUserProfile(userId: authResult.user.uid)
    }
    
    // MARK: - User Profile Management
    private func saveUserProfile(_ profile: UserProfile) async throws {
        guard let userId = profile.id else {
            print("🔍 DEBUG: saveUserProfile failed - no userId")
            throw AuthError.noUser
        }
        
        print("🔍 DEBUG: Saving profile to Firestore for userId: \(userId)")
        print("🔍 DEBUG: Profile data: username=\(profile.username), email=\(profile.email)")
        
        try db.collection("users").document(userId).setData(from: profile)
        print("🔍 DEBUG: Profile successfully saved to Firestore")
    }
    
    private func loadUserProfile(userId: String) async {
        print("🔍 DEBUG: Loading user profile for userId: \(userId)")
        do {
            let snapshot = try await db.collection("users").document(userId).getDocument()
            print("🔍 DEBUG: Firestore document exists: \(snapshot.exists)")
            
            if snapshot.exists {
                self.userProfile = try snapshot.data(as: UserProfile.self)
                print("🔍 DEBUG: Successfully loaded userProfile: \(self.userProfile?.username ?? "nil")")
            } else {
                print("🔍 DEBUG: No user profile document found in Firestore")
                self.userProfile = nil
            }
        } catch {
            print("🔍 DEBUG: Error loading user profile: \(error.localizedDescription)")
            print("🔍 DEBUG: Full error: \(error)")
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Sign out from Firebase
        try Auth.auth().signOut()
        
        self.user = nil
        self.userProfile = nil
        self.isAuthenticated = false
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        
        // Sign out from Google
        GIDSignIn.sharedInstance.signOut()
        
        // Delete user profile from Firestore
        if let userId = user.uid as String? {
            try await db.collection("users").document(userId).delete()
        }
        
        // Delete user from Firebase
        try await user.delete()
        
        self.user = nil
        self.userProfile = nil
        self.isAuthenticated = false
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case tokenError
    case noUser
    case invalidUsername
    case invalidEmail
    case invalidPassword
    case weakPassword
    
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
        case .invalidUsername:
            return "Please enter a valid username"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Please enter your password"
        case .weakPassword:
            return "Password must be at least 6 characters"
        }
    }
}
