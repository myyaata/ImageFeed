//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photosCount: Int = 0
    var viewDidLoadCalled = false
    var willDisplayRowCalled = false
    var didTapLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    }
    
    func dateString(for photo: Photo) -> String {
        ""
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        willDisplayRowCalled = true
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
}
