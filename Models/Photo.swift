//
//  Photo.swift
//  ImageFeed
//
//  Created by арина сильченко on 9.08.26.
//
import Foundation
import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.isLiked
        let isoFormatter = ISO8601DateFormatter()
        self.createdAt = isoFormatter.date(from: result.createdAt)
    }
}
