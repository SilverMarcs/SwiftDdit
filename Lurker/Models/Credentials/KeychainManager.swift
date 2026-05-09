import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = Bundle.main.bundleIdentifier ?? "com.SilverMarcs.Lurker"

    private init() {}

    func save(key: String, data: String, synchronizable: Bool = false) {
        guard let valueData = data.data(using: .utf8) else { return }

        delete(key: key, synchronizable: synchronizable)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue! : kCFBooleanFalse!,
            kSecValueData as String: valueData
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func load(key: String, synchronizable: Bool = false) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue! : kCFBooleanFalse!,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataRef: AnyObject?
        let status = unsafe SecItemCopyMatching(query as CFDictionary, &dataRef)
        guard status == errSecSuccess, let data = dataRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Pass `synchronizable: nil` to delete from both local and iCloud-synced
    /// buckets (e.g. on logout). Pass an explicit value to scope the delete.
    func delete(key: String, synchronizable: Bool? = nil) {
        let syncValue: Any = synchronizable.map { $0 ? kCFBooleanTrue! : kCFBooleanFalse! } ?? kSecAttrSynchronizableAny
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: syncValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
