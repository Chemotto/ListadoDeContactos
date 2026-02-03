import Foundation

final class LocalContactsStore {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "LocalContactsStore.queue", qos: .utility)

    init(fileName: String = "contacts.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(fileName)
    }

    func load() -> [AppContact] {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let contacts = try JSONDecoder().decode([AppContact].self, from: data)
            return contacts
        } catch {
            print("[LocalContactsStore] Error loading contacts: \(error)")
            return []
        }
    }

    func save(_ contacts: [AppContact]) {
        queue.async { [fileURL] in
            do {
                let data = try JSONEncoder().encode(contacts)
                try data.write(to: fileURL, options: .atomic)
            } catch {
                print("[LocalContactsStore] Error saving contacts: \(error)")
            }
        }
    }
}
