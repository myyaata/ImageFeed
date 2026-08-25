//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var insertRowsCalled = false
    var receivedIndexPaths: [IndexPath] = []
    var setLikeButtonCalled = false
    var receivedIsLiked: Bool?
    var showLikeErrorCalled = false
    var setLikeLoadingCalled = false
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        receivedIndexPaths = indexPaths
    }
    
    func setLikeButton(at indexPath: IndexPath, isLiked: Bool) {
        setLikeButtonCalled = true
        receivedIsLiked = isLiked
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
    
    func setLikeLoading(_ isLoading: Bool) {
        setLikeLoadingCalled = true
    }
    
}
