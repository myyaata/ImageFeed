//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by арина сильченко on 9.08.26.
//

import Foundation

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
}
