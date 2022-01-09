import Foundation

class ContentViewModel: ObservableObject {
    private static let fileName = "message.txt"
    @Published var message: String = "Demo message"
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let fileRepository: FileRepositoryProtocol

    init(fileRepository: FileRepositoryProtocol = AppRepository.shared.fileRepository) {
        self.fileRepository = fileRepository
    }

    func saveMessage() {
        if !fileRepository.save(message: message, to: Self.fileName) {
            alertMessage = "Cannot save the message"
            showAlert = true
            return
        }
    }

    func showMessage() {
        let message = fileRepository.read(from: Self.fileName)

        alertMessage = "Message read:\n\(message ?? "")"
        showAlert = true
    }
}
