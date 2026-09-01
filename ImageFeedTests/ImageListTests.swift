//
//  ImageListTests.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

import XCTest
@testable import ImageFeed

final class ImageListTests: XCTestCase {
    
    @MainActor
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testViewDidLoadCallsFetchPhotosNextPage() {
        let vc = ImagesListViewControllerSpy()
        let serviceMock = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: serviceMock)
        vc.presenter = presenter
        presenter.view = vc
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled)
    }
    
    @MainActor
    func testWillDisplayLastRowTriggersNextPage() {
        let view = ImagesListViewControllerSpy()
        let serviceMock = ImagesListServiceMock()
        let presenter = ImagesListPresenter(imagesListService: serviceMock)
        presenter.view = view
        
        presenter.willDisplayRow(at: IndexPath(row: -1, section: 0))
        
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled)
    }
    
    @MainActor
    func testDidTapLikeSuccessUpdatesView() {
        let view = ImagesListViewControllerSpy()
        let serviceMock = ImagesListServiceMock()
        let testPhoto = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        serviceMock.photos = [testPhoto]
        
        let presenter = ImagesListPresenter(imagesListService: serviceMock)
        presenter.view = view
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        serviceMock.changeLikeResult = .success(())
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        XCTAssertTrue(view.setLikeLoadingCalled)
        XCTAssertTrue(view.setLikeButtonCalled)
        XCTAssertEqual(view.receivedIsLiked, true)
    }
    
    @MainActor
    func testDidTapLikeFailureShowsError() {
        let view = ImagesListViewControllerSpy()
        let serviceMock = ImagesListServiceMock()
        let testPhoto = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        serviceMock.photos = [testPhoto]
        
        let presenter = ImagesListPresenter(imagesListService: serviceMock)
        presenter.view = view
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        serviceMock.changeLikeResult = .failure(NSError(domain: "test", code: 0))
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        XCTAssertTrue(view.showLikeErrorCalled)
        XCTAssertFalse(view.setLikeButtonCalled)
    }
}
