import Foundation
import Contacts

struct SystemContactsProvider {
    func requestAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func fetchContacts() -> [AppContact] {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                       CNContactFamilyNameKey as CNKeyDescriptor,
                                       CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var results: [AppContact] = []
        do {
            try store.enumerateContacts(with: request) { cn, _ in
                let name = (cn.givenName + " " + cn.familyName).trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                guard let phone = cn.phoneNumbers.first?.value.stringValue else { return }
                let contact = AppContact(name: name, phone: phone, email: nil, source: .external)
                results.append(contact)
            }
        } catch {
            print("[SystemContactsProvider] Error fetching contacts: \(error)")
        }
        return results
    }
}
