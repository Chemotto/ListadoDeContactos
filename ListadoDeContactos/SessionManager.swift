import Foundation

struct SessionManager {
    private static let loggedInKey = "loggedInUsername"

    static var currentUsername: String? {
        get { UserDefaults.standard.string(forKey: loggedInKey) }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: loggedInKey)
            } else {
                UserDefaults.standard.removeObject(forKey: loggedInKey)
            }
        }
    }

    static var isLoggedIn: Bool {
        return currentUsername != nil
    }

    static func login(username: String) {
        currentUsername = username
    }

    static func logout() {
        currentUsername = nil
    }
}
