import UIKit

final class AddContactViewController: UIViewController {
    private let repository: ContactsRepository

    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let emailField = UITextField()
    private let saveButton = UIButton(type: .system)

    init(repository: ContactsRepository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuevo contacto"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

        setupForm()
    }

    private func setupForm() {
        nameField.placeholder = "Nombre"
        phoneField.placeholder = "Teléfono"
        emailField.placeholder = "Email"
        [nameField, phoneField, emailField].forEach { tf in
            tf.borderStyle = .roundedRect
            tf.translatesAutoresizingMaskIntoConstraints = false
        }

        saveButton.setTitle("Guardar", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [nameField, phoneField, emailField, saveButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "El nombre es obligatorio", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        repository.add(name: name, phone: phone?.isEmpty == true ? nil : phone, email: email?.isEmpty == true ? nil : email, source: .local)
        dismiss(animated: true)
    }
}
