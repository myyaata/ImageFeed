import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
}


final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private(set) var avatarURL: String?
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService.makeProfileImageRequest]: URLError - не удалось создать URL, username: \(username)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUsername != username else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest - повторный запрос с тем же username: \(username)")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard let token = OAuth2TokenStorage().token else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest - токен отсутствует, username: \(username)")
            lastUsername = nil
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.invalidRequest - не удалось создать URLRequest, username: \(username)")
            lastUsername = nil
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.large
                self?.avatarURL = avatarURL
                completion(.success(avatarURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error) - username: \(username)")
                completion(.failure(error))
            }
            if self?.lastUsername == username {
                self?.task = nil
                self?.lastUsername = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func reset() {
        task?.cancel()
        task = nil
        lastUsername = nil
        avatarURL = nil
    }
}

