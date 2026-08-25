//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by арина сильченко on 25.08.26.
//

import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
