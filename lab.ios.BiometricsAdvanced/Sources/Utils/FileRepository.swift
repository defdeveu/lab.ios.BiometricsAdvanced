import Foundation
import CryptoKit

protocol FileRepositoryProtocol {
    func save(message: String, to destination: String) -> Bool
    func read(from source: String) -> String?
}

final class FileRepository: FileRepositoryProtocol {
    private let keyManager: KeyManagerProtocol

    init(keyManager: KeyManagerProtocol = AppRepository.shared.keyManager) {
        self.keyManager = keyManager
    }

    func save(message: String, to destination: String) -> Bool {
        guard let url = documentDirectoryPath() else { return false }
        let fileURL = url.appendingPathComponent(destination)

        guard let messageData = message.data(using: .utf8),
              let key = symmetricKey(),
              let cryptedBox = try? ChaChaPoly.seal(messageData, using: key),
              let sealedBox = try? ChaChaPoly.SealedBox(combined: cryptedBox.combined)
        else {
            return false
        }

        do {
            try sealedBox.combined.write(to: fileURL)
        } catch {
            return false
        }

        return true
    }

    func read(from source: String) -> String? {
        guard let url = documentDirectoryPath() else { return nil }
        let fileURL = url.appendingPathComponent(source)

        guard let combinedData = try? Data(contentsOf: fileURL),
              let sealedBoxToOpen = try? ChaChaPoly.SealedBox(combined: combinedData),
              let key = symmetricKey(),
              let decryptedData = try? ChaChaPoly.open(sealedBoxToOpen, using: key),
              let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                  return nil
              }

        return decryptedString
    }
}

private extension FileRepository {
    func documentDirectoryPath() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func symmetricKey() -> SymmetricKey? {
        guard let keyData = keyManager.retrieveKeyData() else {
            return nil
        }

        return SymmetricKey(data: keyData)
    }
}
