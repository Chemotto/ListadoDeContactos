import Foundation

final class ContactsRepository {
    private let store: LocalContactsStore
    private(set) var contacts: [Contact]

    init(store: LocalContactsStore = LocalContactsStore()) {
        self.store = store
        self.contacts = store.load()
    }

    @discardableResult
    func add(name: String, phone: String? = nil, email: String? = nil) -> Contact {
        let contact = Contact(name: name, phone: phone, email: email)
        contacts.append(contact)
        persist()
        return contact
    }

    func delete(id: UUID) {
        contacts.removeAll { $0.id == id }
        persist()
    }

    func update(_ updated: Contact) {
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
}
