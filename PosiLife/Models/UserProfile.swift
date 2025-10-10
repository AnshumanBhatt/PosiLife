//
//  UserProfile.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 10/10/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var username: String
    var email: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case createdAt
        case updatedAt
    }
    
    init(id: String? = nil, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
