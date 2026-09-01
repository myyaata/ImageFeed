//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by арина сильченко on 25.08.26.
//

import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
//        let newProgressValue = Float(newValue)
//        view?.setProgressValue(newProgressValue)
//        
//        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
//        view?.setProgressHidden(shouldHideProgress)
    }
    
//    func shouldHideProgress(for value: Float) -> Bool {
//        abs(value - 1.0) <= 0.0001
//    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
