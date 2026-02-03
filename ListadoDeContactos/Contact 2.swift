import Foundation

public enum ContactSource: String, Codable {
    case local
    case external // e.g., system/remote contacts
}

public struct AppContact: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var phone: String?
    public var email: String?
    public var source: ContactSource

    public init(id: UUID = UUID(), name: String, phone: String? = nil, email: String? = nil, source: ContactSource = .local) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.source = source
    }
}
