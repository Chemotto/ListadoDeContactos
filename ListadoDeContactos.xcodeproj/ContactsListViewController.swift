import UIKit

final class ContactsListViewController: UITableViewController {
    private let repository = ContactsRepository()

    private var data: [AppContact] { repository.contacts }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contactos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Importar", style: .plain, target: self, action: #selector(importarContactos)),
            editButtonItem
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        repository.reload()
        tableView.reloadData()
    }

    @objc private func addTapped() {
        let addVC = AddContactViewController(repository: repository)
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    @objc private func importarContactos() {
        repository.importSystemContacts { [weak self] ok in
            guard let self = self else { return }
            if ok {
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Permiso denegado", message: "Autoriza el acceso a Contactos en Ajustes para importar.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = data[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        let prefix = (contact.source == .external) ? "🌐 " : ""
        content.text = prefix + contact.name
        let subtitle: String
        switch contact.source {
        case .local:
            subtitle = (contact.phone ?? "") + "  •  Local"
        case .external:
            subtitle = (contact.phone ?? "") + "  •  Externo"
        }
        content.secondaryText = subtitle
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = data[indexPath.row].id
            repository.delete(id: id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
