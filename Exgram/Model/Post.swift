//
//  Post.swift
//  Exgram
//
//  Created by Artem Listopadov on 13.05.23.
//

import SwiftUI
import FirebaseFirestoreSwift

// MARK: Post Model
struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    // MARK: Basic User Info
    var userName: String
    var userUID: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case text // Post Content
        case imageURL // Post Image URL
        case imageReferenceID // Image Reference ID
        case publishedDate
        case likedIDs // People's user IDs who liked
        case dislikedIDs // People's user IDs who disliked
        case userName // Post Author's basic info (for Post View)
        case userUID
        case userProfileURL
    }
}
