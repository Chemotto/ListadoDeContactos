//
//  LoginViewController.swift
//  ContactApp
//
//  Created by Developer on 2026-02-03.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkSession()
    }

    private func setupUI() {
        enterButton.layer.cornerRadius = 8
    }

    private func checkSession() {
        if SessionManager.shared.isLoggedIn {
            presentContacts()
        }
    }

    @IBAction func enterButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !username.isEmpty else {
            showError(message: "El nombre de usuario no puede estar vacío.")
            return
        }
        SessionManager.shared.login(username: username)
        presentContacts()
    }

    private func presentContacts() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "ContactsNavigationController") as? UINavigationController {
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cerrar", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SessionManager

final class SessionManager {
    static let shared = SessionManager()

    private let defaults = UserDefaults.standard
    private let userKey = "loggedInUser"

    var isLoggedIn: Bool {
        return defaults.string(forKey: userKey) != nil
    }

    func login(username: String) {
        defaults.set(username, forKey: userKey)
    }

    func logout() {
        defaults.removeObject(forKey: userKey)
    }

    var currentUser: String? {
        return defaults.string(forKey: userKey)
    }

}
