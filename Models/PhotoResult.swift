//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by арина сильченко on 9.08.26.
//

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let height: Int
    let width: Int
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    struct UrlsResult: Codable {
        let full: String
        let regular: String
        let thumb: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case description
        case urls
        case isLiked = "liked_by_user"
    }
}
