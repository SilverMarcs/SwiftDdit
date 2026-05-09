import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = Bundle.main.bundleIdentifier ?? "com.SilverMarcs.Lurker"

    private init() {}

    func save(key: String, data: String) {
        guard let valueData = data.data(using: .utf8) else { return }

        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecValueData as String: valueData
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataRef: AnyObject?
        let status = unsafe SecItemCopyMatching(query as CFDictionary, &dataRef)
        guard status == errSecSuccess, let data = dataRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
        ]
        SecItemDelete(query as CFDictionary)
    }
}
