import UIKit

struct Profile {
    let name: String
    let subtitle: String
    let posts: String
    let followers: String
    let following: String
    let about: String
}

final class ViewController: UIViewController {
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    private let profile = Profile(
        name: "Aigerim Bekova",
        subtitle: "iOS Developer · Almaty",
        posts: "128",
        followers: "4.2K",
        following: "312",
        about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarLabel.text = profile.name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined()
        nameLabel.text = profile.name
        subtitleLabel.text = profile.subtitle
        postsLabel.text = profile.posts
        followersLabel.text = profile.followers
        followingLabel.text = profile.following
        aboutLabel.text = profile.about
    }
}
