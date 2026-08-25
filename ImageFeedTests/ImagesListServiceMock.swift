//
//  ImagesListServiceMock.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

@testable import ImageFeed


final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        if case .success = changeLikeResult, let index = photos.firstIndex(where: { $0.id == photoId }) {
            let old = photos[index]
            photos[index] = Photo(
                id: old.id,
                size: old.size,
                createdAt: old.createdAt,
                welcomeDescription: old.welcomeDescription,
                thumbImageURL: old.thumbImageURL,
                largeImageURL: old.largeImageURL,
                isLiked: isLike
            )
        }
        completion(changeLikeResult)
    }
}
