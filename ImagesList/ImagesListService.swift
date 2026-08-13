//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by арина сильченко on 9.08.26.
//

import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private(set) var photos: [Photo] = []
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("[ImagesListService.makePhotosRequest]: URLError - не удалось создать URLComponents")
            return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else {
            print("[ImagesListService.makePhotosRequest]: URLError - не удалось получить URL из URLComponents")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[ImagesListService.makeLikeRequest]: URLError - не удалось создать URLComponents")
            return nil }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[ImagesListService.fetchPhotosNextPage]: ImagesListServiceError.invalidRequest - запрос уже выполняется")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = OAuth2TokenStorage().token else {
            print("[ImagesListService.fetchPhotosNextPage]: ImagesListServiceError.invalidRequest - токен отсутствует")
            return
        }
        
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            print("[ImagesListService.fetchPhotosNextPage]: ImagesListServiceError.invalidRequest - не удалось создать URLRequest")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResult):
                let newPhotos = photoResult.map { Photo(result: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                self.task = nil
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                object: self)
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error) - page: \(nextPage)")
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let token = OAuth2TokenStorage().token else {
            print("[ImagesListService.changeLike]: ImagesListServiceError.invalidRequest - токен отсутствует")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            print("[ImagesListService.changeLike]: ImagesListServiceError.invalidRequest - не удалось создать URLRequest, photoId: \(photoId)")
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                print("[ImagesListService.changeLike]: \(error) - photoId: \(photoId)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func reset() {
        task?.cancel()
        task = nil
        lastLoadedPage = nil
        photos = []
    }
}
