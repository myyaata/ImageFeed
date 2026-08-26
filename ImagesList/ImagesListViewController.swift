import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func insertRows(at indexPaths: [IndexPath])
    func setLikeButton(at indexPath: IndexPath, isLiked: Bool)
    func showLikeError()
    func setLikeLoading(_ isLoading: Bool)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    
    @IBOutlet private var tableView: UITableView!
            
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if presenter == nil {
            presenter = ImagesListPresenter()
        }
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func setLikeButton(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось изменить лайк",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                assertionFailure("Error")
                return
            }
            let photo = presenter?.photo(at: indexPath)
            viewController.imageURL = photo?.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let presenter, let photo = presenter.photo(at: indexPath) as Photo? else { return }

        cell.imageOfCell.kf.indicatorType = .activity
        cell.imageOfCell.kf.setImage(with: URL(string: photo.thumbImageURL), placeholder: UIImage(named: "placeholder")) { [weak self] _ in
            guard let self else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.dateLabel.text = presenter.dateString(for: photo)
        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath), photo.size.width != 0 else { return 200 }
        //коэффициент масштабирования = (ширина экрана БЕЗ отступов по 16pt слева и справа) / ширину картинки
        let scale = (tableView.bounds.width - 32) / photo.size.width
        let imageHeight = photo.size.height * scale
        //высота картинки с учетом отступов снизу и сверху по 4pt
        return imageHeight + 8
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
    
    func setLikeLoading(_ isLoading: Bool) {
        isLoading ? UIBlockingProgressHUD.show() : UIBlockingProgressHUD.dismiss()
    }
}
