import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private init() { }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private(set) var profile: Profile?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.makeProfileRequest]: URLError - не удалось создать URL для профиля")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            print("[ProfileService.fetchProfile]: ProfileServiceError.invalidRequest - повторный запрос с тем же token")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: ProfileServiceError.invalidRequest - не удалось создать URLRequest")
            lastToken = nil
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error)")
                completion(.failure(error))
            }
            if self?.lastToken == token {
                self?.task = nil
                self?.lastToken = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func reset() {
        task?.cancel()
        task = nil
        lastToken = nil
        profile = nil
    }
}
