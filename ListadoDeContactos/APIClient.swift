import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func fetchContacts() async throws -> [Contact] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            throw APIError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.requestFailed
        }
        do {
            return try JSONDecoder().decode([Contact].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
