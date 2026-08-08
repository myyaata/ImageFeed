import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                assertionFailure("Error")
                return
            }
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else {
            return
        }
        cell.imageOfCell.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "unactive_like"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "active_like"), for: .normal)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else { return 200 }
        guard image.size.width != 0 else { return 200 }
        //коэффициент масштабирования = (ширина экрана БЕЗ отступов по 16pt слева и справа) / ширину картинки
        let scale = (tableView.bounds.width - 32) / image.size.width
        let imageHeight = image.size.height * scale
        //высота картинки с учетом отступов снизу и сверху по 4pt
        return imageHeight + 8
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
