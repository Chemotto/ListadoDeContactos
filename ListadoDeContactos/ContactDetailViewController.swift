import UIKit

final class ContactDetailViewController: UIViewController {
    // Conecta estos Outlets en el storyboard
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!

    // Este será el parámetro recibido desde la lista
    var contact: Contact!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalle"
        configureUI()
    }

    private func configureUI() {
        guard let contact else { return }
        nameLabel.text = contact.name
        emailLabel.text = "Email: \(contact.email)"
        phoneLabel.text = "Teléfono: \(contact.phone)"
        websiteLabel.text = "Web: \(contact.website)"
    }
}
