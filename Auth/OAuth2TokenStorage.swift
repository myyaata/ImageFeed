import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            if !isSuccess {
                print("[OAuth2TokenStorage.token.set]: KeychainError - не удалось сохранить токен в Keychain")
            }
        }
    }
}
