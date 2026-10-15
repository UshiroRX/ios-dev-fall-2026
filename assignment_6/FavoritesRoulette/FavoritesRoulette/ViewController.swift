import UIKit

final class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    private let favorites = Favorite.all
    private var currentIndex: Int?

    @IBAction func spinTapped(_ sender: UIButton) {
        // Exclude the current card so the same favorite never shows twice in a row
        let candidates = favorites.indices.filter { $0 != currentIndex }
        guard let index = candidates.randomElement() else { return }
        currentIndex = index

        let favorite = favorites[index]
        imageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
    }
}
