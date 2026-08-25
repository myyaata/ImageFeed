//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by арина сильченко on 25.08.26.
//

import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at indexPath: IndexPath) -> Photo
    func dateString(for photo: Photo) -> String
    func willDisplayRow(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var photosCount: Int { photos.count }
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
        imagesListService.fetchPhotosNextPage()

    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func dateString(for photo: Photo) -> String {
        guard let createdAt = photo.createdAt else { return "" }
        return dateFormatter.string(from: createdAt)
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        view?.setLikeLoading(true)
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            self.view?.setLikeLoading(false)
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.setLikeButton(at: indexPath, isLiked: self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("[ImagesListPresenter.didTapLike]: \(error)")
                self.view?.showLikeError()
            }
        }
    }
    
    private func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.insertRows(at: indexPaths)
        }
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
