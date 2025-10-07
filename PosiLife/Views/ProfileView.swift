//
//  ProfileView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 03/10/25.
//

import SwiftUI

struct ProfileView: View {
    
    let profileImage = Image(systemName: "person.crop.circle.fill")
    let userName = "Anshuman Bhatt"
    let userNumber = "+91 98765 43210"
    
    // MARK: - Options
    let options = [
        "Edit Profile",
        "Notifications",
        "Privacy Settings",
        "Payment Methods",
        "Help & Support",
        "Logout"
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
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.top, 40)
                    
                    // MARK: - User Info
                    VStack(spacing: 4) {
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(userNumber)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Options List
                    List {
                        ForEach(options, id: \.self) { option in
                            HStack {
                                Text(option)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // handle action here
                                print("\(option) tapped")
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Spacer()
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
}

#Preview {
    ProfileView()
}
