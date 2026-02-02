import UIKit

final class LoginViewController: UIViewController {
    @IBOutlet weak var enterButton: UIButton?

    @IBOutlet weak var usernameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observeTextField()
        styleEnterButton()
    }

    private func configureUI() {
        // Background gradient
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemBackground.withAlphaComponent(0.0).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        // Ensure the gradient resizes with rotations/size changes
        if let oldGradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldGradient.removeFromSuperlayer()
        }
        view.layer.insertSublayer(gradient, at: 0)

        // TextField styling
        usernameTextField.layer.cornerRadius = 12
        usernameTextField.layer.masksToBounds = true
        usernameTextField.backgroundColor = .secondarySystemBackground
        usernameTextField.layer.shadowColor = UIColor.black.cgColor
        usernameTextField.layer.shadowOpacity = 0.08
        usernameTextField.layer.shadowRadius = 8
        usernameTextField.layer.shadowOffset = CGSize(width: 0, height: 4)
        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: usernameTextField.placeholder ?? "Usuario",
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
    }

    private func observeTextField() {
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        updateEnterButtonState()
    }

    @objc private func textDidChange() {
        updateEnterButtonState()
    }

    private func updateEnterButtonState() {
        let text = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if let button = enterButton {
            button.isEnabled = !text.isEmpty
            if button.isEnabled {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
                button.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .disabled)
            }
            UIView.animate(withDuration: 0.15) {
                button.alpha = text.isEmpty ? 0.6 : 1.0
            }
        }
    }

    private func styleEnterButton() {
        guard let button = enterButton else { return }
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.9), for: .disabled)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.setTitleColor(.white, for: .highlighted)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if SessionManager.isLoggedIn {
            navigateToContacts()
        }
    }

   
    @IBAction func enterButtonTapped(_ sender: UIButton) {
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updateEnterButtonState()
        if username.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Ingresa un nombre de usuario.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        SessionManager.login(username: username)
        navigateToContacts()
    }

    private func navigateToContacts() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nav = storyboard.instantiateViewController(withIdentifier: "ContactsNavigationController")
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient layer matches current bounds after layout changes
        if let gradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradient.frame = view.bounds
        }
    }
}
