//
//  ProfileView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 03/10/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        Text("Profile")
        
        VStack(){
            Circle()
                .frame(width: 60)
              
            Text("Current Energy")
                .padding()
            HStack{
                Image(systemName: "bolt")
                
                Text("5")
                    .font(.subheadline)
                
            }
           
        }
        
        }
}

#Preview {
    ProfileView()
}
