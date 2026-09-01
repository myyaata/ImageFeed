//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by арина сильченко on 25.08.26.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    @MainActor
    func testViewControllerCallsViewDidLoad() {
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileVC.presenter = presenter
        presenter.view = profileVC
        
        _ = profileVC.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testViewDidLoadWithEmptyProfileCallsUpdateProfileDetailsWithDefaults() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        profileServiceMock.profile = Profile(result: ProfileResult(
            username: "",
            firstName: nil,
            lastName: nil,
            bio: nil
        ))
        let profileImageServiceMock = ProfileImageServiceMock()
        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock
        )
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
        XCTAssertEqual(viewController.receivedName, "Имя не указано")
        XCTAssertEqual(viewController.receivedLoginName, "@неизвестный_пользователь")
        XCTAssertEqual(viewController.receivedDescription, "Профиль не заполнен")
    }
    
    @MainActor
    func testViewDidLoadWithFilledProfileCallsUpdateProfileDetailsWithRealValues() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        profileServiceMock.profile = Profile(result: ProfileResult(
            username: "arina",
            firstName: "Arina",
            lastName: "Silchenko",
            bio: "iOS developer"
        ))
        let profileImageServiceMock = ProfileImageServiceMock()
        
        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock
        )
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(viewController.receivedName, "Arina Silchenko")
        XCTAssertEqual(viewController.receivedLoginName, "@arina")
        XCTAssertEqual(viewController.receivedDescription, "iOS developer")
    }
    
    @MainActor
    func testViewDidLoadWithNoProfileDoesNotCallUpdateProfileDetails() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        let profileImageServiceMock = ProfileImageServiceMock()
        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock
        )
        presenter.view = viewController
        
        presenter.viewDidLoad()

        XCTAssertFalse(viewController.updateProfileDetailsCalled)
    }
    
    @MainActor
    func testUpdateAvatarCallsViewWithCorrectURL() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        let profileImageServiceMock = ProfileImageServiceMock()
        profileImageServiceMock.avatarURL = "https://example.com/avatar.jpg"

        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock)
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.updateAvatarCalled)
        XCTAssertEqual(viewController.receivedAvatarURL, URL(string: "https://example.com/avatar.jpg"))
    }
       
    @MainActor
    func testUpdateAvatarNotCalledWhenAvatarURLIsNil() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceMock = ProfileServiceMock()
        let profileImageServiceMock = ProfileImageServiceMock()
        
        let presenter = ProfilePresenter(
            profileService: profileServiceMock,
            profileImageService: profileImageServiceMock)
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertFalse(viewController.updateAvatarCalled)
    }
}
