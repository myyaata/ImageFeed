import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}


final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private(set) var avatarURL: String?
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("❌ Ошибка создания URL для аватарки")
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
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard let token = OAuth2TokenStorage().token else {
            lastUsername = nil
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            lastUsername = nil
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let avatarURL = userResult.profileImage.small
                    self?.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                } catch {
                    print("❌ Ошибка декодирования аватарки: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Ошибка сети при получении аватарки: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastUsername = nil
        }
        
        self.task = task
        task.resume()
    }
}
