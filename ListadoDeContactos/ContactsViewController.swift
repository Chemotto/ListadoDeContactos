import UIKit

struct LocalContact: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var phone: String?
    var email: String?
    var website: String?

    init(id: UUID = UUID(), name: String, phone: String?, email: String?, website: String?) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.website = website
    }
}

private enum LocalStoreKeys {
    static let contacts = "local_contacts"
}

final class ContactsViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!

    private var contacts: [Contact] = []
    private var lastContentOffsetY: CGFloat = 0

    private var localContacts: [LocalContact] = []
    private var combined: [Contact] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private var filtered: [Contact] = []
    private var isSearching: Bool { !(searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && searchController.isActive }
    private var displayed: [Contact] { isSearching ? filtered : combined }

    private lazy var addContactButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.addTarget(self, action: #selector(addContactTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contactos"

        tableView.dataSource = self
        tableView.delegate = self

        setupMenuButton()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar contactos"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        loadLocalContacts()
        Task { await loadContacts() }

        view.addSubview(addContactButton)
        NSLayoutConstraint.activate([
            addContactButton.widthAnchor.constraint(equalToConstant: 56),
            addContactButton.heightAnchor.constraint(equalToConstant: 56),
            addContactButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addContactButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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

    private func loadLocalContacts() {
        if let data = UserDefaults.standard.data(forKey: LocalStoreKeys.contacts) {
            do {
                localContacts = try JSONDecoder().decode([LocalContact].self, from: data)
            } catch {
                localContacts = []
            }
        } else {
            localContacts = []
        }
    }

    private func saveLocalContacts() {
        do {
            let data = try JSONEncoder().encode(localContacts)
            UserDefaults.standard.set(data, forKey: LocalStoreKeys.contacts)
        } catch {
            // Handle encoding error silently for now
        }
    }

    private func loadContacts() async {
        do {
            let remote = try await APIClient.shared.fetchContacts()
            // Combine local first, then remote
            let localsMapped: [Contact] = localContacts.map { lc in
                Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
            }
            self.contacts = remote
            self.combined = localsMapped + remote
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

    @objc private func addContactTapped() {
        let alert = UIAlertController(title: "Nuevo contacto", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Nombre" }
        alert.addTextField { tf in
            tf.placeholder = "Teléfono"
            tf.keyboardType = .phonePad
        }
        alert.addTextField { tf in
            tf.placeholder = "Email"
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
        }
        alert.addTextField { tf in
            tf.placeholder = "Web"
            tf.keyboardType = .URL
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let phone = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = alert.textFields?[2].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let website = alert.textFields?[3].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return }

            let local = LocalContact(name: name,
                                     phone: (phone?.isEmpty == true ? nil : phone),
                                     email: (email?.isEmpty == true ? nil : email),
                                     website: (website?.isEmpty == true ? nil : website))
            self.localContacts.insert(local, at: 0)
            self.saveLocalContacts()

            // Rebuild combined list placing locals first
            let localsMapped: [Contact] = self.localContacts.map { lc in
                Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
            }
            self.combined = localsMapped + self.contacts
            self.tableView.reloadData()
        }))
        present(alert, animated: true)
    }

    private func showFAB() {
        guard addContactButton.alpha < 1 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.addContactButton.alpha = 1.0
            self.addContactButton.transform = .identity
        })
    }

    private func hideFAB() {
        guard addContactButton.alpha > 0 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.addContactButton.alpha = 0.0
            self.addContactButton.transform = CGAffineTransform(translationX: 0, y: 20)
        })
    }

    private func presentEditLocalContact(for contact: Contact) {
        // Find matching local by UUID-derived id
        guard let idx = localContacts.firstIndex(where: { -abs($0.id.hashValue) == contact.id }) else { return }
        let current = localContacts[idx]
        let alert = UIAlertController(title: "Editar contacto", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Nombre"
            tf.text = current.name
        }
        alert.addTextField { tf in
            tf.placeholder = "Teléfono"
            tf.keyboardType = .phonePad
            tf.text = current.phone
        }
        alert.addTextField { tf in
            tf.placeholder = "Email"
            tf.keyboardType = .emailAddress
            tf.autocapitalizationType = .none
            tf.text = current.email
        }
        alert.addTextField { tf in
            tf.placeholder = "Web"
            tf.keyboardType = .URL
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
            tf.text = current.website
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Borrar", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.localContacts.remove(at: idx)
            self.saveLocalContacts()
            // rebuild combined
            let localsMapped: [Contact] = self.localContacts.map { lc in
                Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
            }
            self.combined = localsMapped + self.contacts
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let phone = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = alert.textFields?[2].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let website = alert.textFields?[3].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return }
            var updated = current
            updated.name = name
            updated.phone = (phone?.isEmpty == true ? nil : phone)
            updated.email = (email?.isEmpty == true ? nil : email)
            updated.website = (website?.isEmpty == true ? nil : website)
            self.localContacts[idx] = updated
            self.saveLocalContacts()
            // rebuild combined
            let localsMapped: [Contact] = self.localContacts.map { lc in
                Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
            }
            self.combined = localsMapped + self.contacts
            self.tableView.reloadData()
        }))
        present(alert, animated: true)
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayed.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = displayed[indexPath.row]
        var content = cell.defaultContentConfiguration()
        let isLocal = contact.id < 0
        let prefix = isLocal ? "📍 " : ""
        content.text = prefix + contact.name
        content.secondaryText = contact.email
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = displayed[indexPath.row]
        if contact.id < 0 {
            // Edit local contact
            presentEditLocalContact(for: contact)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController else { return }
            detailVC.contact = contact
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffsetY = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        if currentY > lastContentOffsetY + 2 { // scrolling down
            hideFAB()
        } else if currentY < lastContentOffsetY - 2 { // scrolling up
            showFAB()
        }
        lastContentOffsetY = currentY
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let contact = combined[indexPath.row]
        return contact.id < 0 // only local contacts are editable here
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let contact = combined[indexPath.row]
        if contact.id < 0 {
            if let idx = localContacts.firstIndex(where: { -abs($0.id.hashValue) == contact.id }) {
                localContacts.remove(at: idx)
                saveLocalContacts()
                let localsMapped: [Contact] = localContacts.map { lc in
                    Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
                }
                combined = localsMapped + contacts
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                let localsMapped: [Contact] = localContacts.map { lc in
                    Contact(id: -abs(lc.id.hashValue), name: lc.name, username: "", email: lc.email ?? "", phone: lc.phone ?? "", website: lc.website ?? "")
                }
                combined = localsMapped + contacts
                tableView.reloadData()
            }
        }
    }
}

extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            filtered = []
            tableView.reloadData()
            return
        }
        filtered = combined.filter { c in
            let inName = c.name.lowercased().contains(query)
            let inPhone = c.phone.lowercased().contains(query)
            let inEmail = c.email.lowercased().contains(query)
            let inWeb = c.website.lowercased().contains(query)
            return inName || inPhone || inEmail || inWeb
        }
        tableView.reloadData()
    }
}
