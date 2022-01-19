import Foundation
import CryptoKit

enum KeyManagerError: Error {
    case generateKey(OSStatus?)
    case corruptedKey(OSStatus)
}

protocol KeyManagerProtocol {
    func setupKey() throws
    func retrieveKeyData() -> Data?
}

final class KeyManager {
    private static let service = "defdev"

    init() {}
}

// MARK: - KeyManagerProtocol

extension KeyManager: KeyManagerProtocol {
    func setupKey() throws {
        guard !(try isKeyPresent()) else { return }

        try createKey()
    }

    func retrieveKeyData() -> Data? {
        do {
            return try retrieveKey()
        } catch {
            return nil
        }
    }
}

// MARK: - Private

private extension KeyManager {
    func createKey() throws {
        deleteKey()

        // Generates a symetric ramdom key
        let randomKey = SymmetricKey(size: .bits256)
        let randomKeyData = randomKey.withUnsafeBytes { Data(Array($0)) }

        var query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                  kSecValueData: randomKeyData,
                                kSecAttrService: Self.service]

#if targetEnvironment(simulator)
        // NOTE: As on some simulators (https://developer.apple.com/forums/thread/685773) kSecAttrAccessControl returns an error,
        // there is a simplified setup to make it work.
        query[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

#else

        guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                  kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                                                  .userPresence,
                                                                  nil)
        else {
            throw KeyManagerError.generateKey(nil)
        }

        query[kSecAttrAccessControl] = accessControl

#endif

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeyManagerError.generateKey(status)
        }
    }

    func isKeyPresent() throws -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: Self.service,
                                 kSecMatchLimit: kSecMatchLimitOne]

        let result = SecItemCopyMatching(query as CFDictionary, nil)

        switch result {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeyManagerError.corruptedKey(result)
        }
    }

    func retrieveKey() throws -> Data? {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: Self.service,
                                 kSecReturnData: kCFBooleanTrue ?? true,
                                 kSecMatchLimit: kSecMatchLimitOne]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard status == errSecSuccess else {
            throw KeyManagerError.corruptedKey(status)
        }

        return itemCopy as? Data
    }

    func deleteKey() {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: Self.service]

        _ = SecItemDelete(query as CFDictionary)
    }
}
