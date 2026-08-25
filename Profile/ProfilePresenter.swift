//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by арина сильченко on 25.08.26.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateAvatar()
            }
        updateAvatar()
    }
    
    func updateProfileDetails(profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let loginName = profile.loginName == "@" ? "@неизвестный_пользователь" : profile.loginName
        let description = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : (profile.bio ?? "")
        view?.updateProfileDetails(name: name, loginName: loginName, description: description)
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(url: url)
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
