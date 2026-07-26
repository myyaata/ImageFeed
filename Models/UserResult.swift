struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage {
        let small: String
    }
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
