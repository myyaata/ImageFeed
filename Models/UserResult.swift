struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let large: String
    }
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
