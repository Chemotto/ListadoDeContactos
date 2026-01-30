import UIKit

final class LoginViewController: UIViewController {
    // Conecta este Outlet al UITextField del storyboard
    @IBOutlet weak var usernameTextField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Si ya está logueado, pasamos a la lista
        if SessionManager.isLoggedIn {
            navigateToContacts()
        }
    }

    // Conecta esta Action al botón "Entrar" (Touch Up Inside)
    @IBAction func enterButtonTapped(_ sender: UIButton) {
        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
        // Asegúrate de que el Navigation Controller del listado tenga Storyboard ID: "ContactsNavigationController"
        let nav = storyboard.instantiateViewController(withIdentifier: "ContactsNavigationController")
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
