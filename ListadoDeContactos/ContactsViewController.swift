import UIKit

final class ContactsViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!

    private var contacts: [Contact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contactos"

        tableView.dataSource = self
        tableView.delegate = self

        setupMenuButton()
        Task { await loadContacts() }
    }

    private func setupMenuButton() {
       
        let menuButton = UIBarButtonItem(systemItem: .action)
        menuButton.target = self
        menuButton.action = #selector(menuTapped)
        navigationItem.rightBarButtonItem = menuButton
    }

    @objc private func menuTapped() {
        let alert = UIAlertController(title: "Menú", message: "Elige una opción", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Acerca de", style: .default, handler: { _ in
            let info = UIAlertController(title: "Acerca de", message: "App de contactos de ejemplo.", preferredStyle: .alert)
            info.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(info, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive, handler: { _ in
            SessionManager.logout()
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    private func loadContacts() async {
        do {
            let result = try await APIClient.shared.fetchContacts()
            self.contacts = result
            await MainActor.run {
                self.tableView.reloadData()
            }
        } catch {
            await MainActor.run {
                let alert = UIAlertController(title: "Error", message: "No se pudieron cargar los contactos.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = contacts[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = contact.name
        content.secondaryText = contact.email
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = contacts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController else { return }
        detailVC.contact = contact
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
