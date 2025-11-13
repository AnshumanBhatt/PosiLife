//
//  ProfileView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 03/10/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var profileImage: Image {
        Image(systemName: "person.crop.circle.fill")
    }
    
    var userName: String {
        print("🔍 DEBUG: Getting username...")
        print("🔍 DEBUG: authManager.user?.displayName = \(authManager.user?.displayName ?? "nil")")
        print("🔍 DEBUG: authManager.userProfile?.username = \(authManager.userProfile?.username ?? "nil")")
        print("🔍 DEBUG: authManager.user?.email = \(authManager.user?.email ?? "nil")")
        
        // First try to get username from userProfile, then fallback to displayName, then "User"
        if let username = authManager.userProfile?.username, !username.isEmpty {
            print("🔍 DEBUG: Using userProfile.username: \(username)")
            return username
        } else if let displayName = authManager.user?.displayName, !displayName.isEmpty {
            print("🔍 DEBUG: Using user.displayName: \(displayName)")
            return displayName
        } else {
            print("🔍 DEBUG: Using fallback: User")
            return "User"
        }
    }
    
    var userEmail: String {
        authManager.user?.email ?? "No email"
    }
    
    // MARK: - Options
    let options = [
        "Edit Profile",
        "Notifications",
        "Privacy Settings",
        "Payment Methods",
        "Help & Support",
        "Sign Out",
        "Delete Account"
    ]
//    var body: some View {
//        
//        Text("Profile")
//        
//        NavigationView {
//            VStack(spacing: 20){
//                Image(systemName: "person.crop.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 120 , height: 120)
//                    .clipShape(Circle())
//                    .shadow(radius: 5)
//                    .padding(.top, 10)
//                
//                Text("Current Energy")
//                    .padding()
//                HStack{
//                    Image(systemName: "bolt")
//                    
//                    Text("5")
//                        .font(.subheadline)
//                    
//                }
//                
//            }
//        }
//        
//        }
    
    var body: some View {
            NavigationView {
                VStack(spacing: 20) {
                    
                    // MARK: - Profile Image
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.top, 10)
                    
                    // MARK: - User Info
                    VStack(spacing: 4) {
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
//                    Divider()
//                        .padding(.horizontal)
                    
                    // MARK: - Options List
                    List {
    ForEach(options, id: \.self) { option in
        if option == "Sign Out" || option == "Delete Account" {
            HStack {
                Text(option)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleOptionTap(option)
            }
        } else {
            NavigationLink(destination: destinationView(for: option)) {
                HStack {
                    Text(option)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
                    .listStyle(InsetGroupedListStyle())
                    
                    Spacer()
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Sign Out", isPresented: $showSignOutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        signOut()
                    }
                } message: {
                    Text("Are you sure you want to sign out?")
                }
                .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        deleteAccount()
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                    }
                }
            }
        }
    
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for option: String) -> some View {
        switch option {
        case "Edit Profile":
            EditProfileView()
        case "Notifications":
            NotificationsView()
        case "Privacy Settings":
            PrivacySettingsView()
        case "Payment Methods":
            PaymentMethodsView()
        case "Help & Support":
            HelpSupportView()
        default:
            EmptyView()
        }
    }

    // MARK: - Helper Functions
    private func handleOptionTap(_ option: String) {
        switch option {
        case "Sign Out":
            showSignOutAlert = true
        case "Delete Account":
            showDeleteAccountAlert = true
        default:
            print("\(option) tapped")
        }
    }
    
    private func signOut() {
        do {
            try authManager.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func deleteAccount() {
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
}
