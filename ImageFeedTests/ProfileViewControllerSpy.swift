//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    weak var presenter: ProfilePresenterProtocol?
    
    var updateProfileDetailsCalled = false
    var receivedName: String?
    var receivedLoginName: String?
    var receivedDescription: String?
    
    var updateAvatarCalled = false
    var receivedAvatarURL: URL?
    
    func updateProfileDetails(name: String, loginName: String, description: String) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedLoginName = loginName
        receivedDescription = description
    }
    
    func updateAvatar(url: URL) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }
}
