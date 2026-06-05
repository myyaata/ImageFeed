import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageOfCell: UIImageView!

    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let gradientLayer = CAGradientLayer()
        
    override func awakeFromNib() {
        super.awakeFromNib()

        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.5393).cgColor
        ]

        imageOfCell.layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = CGRect(
            x: 0,
            y: imageOfCell.bounds.height - 30,
            width: imageOfCell.bounds.width,
            height: 30
        )
    }
}

