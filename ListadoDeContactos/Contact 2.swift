import Foundation

public struct Contact: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var phone: String?
    public var email: String?

    public init(id: UUID = UUID(), name: String, phone: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }
}
