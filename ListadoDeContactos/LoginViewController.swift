import UIKit

final class LoginViewController: UIViewController {
 
    @IBOutlet weak var usernameTextField: UITextField!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        if SessionManager.isLoggedIn {
            navigateToContacts()
        }
    }

   
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
        
        let nav = storyboard.instantiateViewController(withIdentifier: "ContactsNavigationController")
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
