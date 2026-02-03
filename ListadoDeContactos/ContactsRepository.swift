import Foundation

final class ContactsRepository {
    private let store: LocalContactsStore
    private(set) var contacts: [AppContact]

    init(store: LocalContactsStore = LocalContactsStore()) {
        self.store = store
        self.contacts = store.load()
    }

    @discardableResult
    func add(name: String, phone: String? = nil, email: String? = nil, source: ContactSource = .local) -> AppContact {
        let contact = AppContact(name: name, phone: phone, email: email, source: source)
        contacts.append(contact)
        persist()
        return contact
    }

    func delete(id: UUID) {
        contacts.removeAll { $0.id == id }
        persist()
    }

    func update(_ updated: AppContact) {
        if let index = contacts.firstIndex(where: { $0.id == updated.id }) {
            contacts[index] = updated
            persist()
        }
    }

    func reload() {
        contacts = store.load()
    }

    private func persist() {
        store.save(contacts)
    }
    
    // Import system contacts and merge as external
    func importSystemContacts(completion: @escaping (Bool) -> Void) {
        let provider = SystemContactsProvider()
        provider.requestAccess { granted in
            guard granted else { completion(false); return }
            let external = provider.fetchContacts()
            self.mergeExternal(external)
            completion(true)
        }
    }
}

private struct ContactKey: Hashable {
    let name: String
    let phone: String
}

extension ContactsRepository {
    /// Merge a list of contacts (e.g., external/system) into the repository, marking them as `.external`.
    /// Uses name+phone as a simple deduplication key. Adjust as needed.
    func mergeExternal(_ external: [AppContact]) {
        var existing = Set(contacts.map { ContactKey(name: $0.name.lowercased(), phone: $0.phone ?? "") })
        var changed = false
        for var c in external {
            c.source = .external
            let key = ContactKey(name: c.name.lowercased(), phone: c.phone ?? "")
            if !existing.contains(key) {
                contacts.append(c)
                existing.insert(key)
                changed = true
            }
        }
        if changed { persist() }
    }
}

