import UIKit

final class ContactsListViewController: UITableViewController {
    private let repository = ContactsRepository()

    private var data: [AppContact] { repository.contacts }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contactos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.leftBarButtonItem = editButtonItem
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

    // MARK: - Table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let contact = data[indexPath.row]
        var content = UIListContentConfiguration.subtitleCell()
        content.text = contact.name
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
