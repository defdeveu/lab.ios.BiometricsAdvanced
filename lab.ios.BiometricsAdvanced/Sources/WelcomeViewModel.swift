import Foundation

class WelcomeViewModel: ObservableObject {
    @Published var navigateToContent: Bool = false
    @Published var showError: Bool = false
    @Published var error: String? = nil
    @Published var isAppReady: Bool = false

    private let biometryPermissionRequester: BiometryPermissionRequesterProtocol

    init(biometryPermissionRequester: BiometryPermissionRequesterProtocol = AppRepository.shared.biometryPermissionRequester,
         keyManager: KeyManagerProtocol = AppRepository.shared.keyManager) {
        self.biometryPermissionRequester = biometryPermissionRequester

        do {
            try keyManager.setupKey()
            isAppReady = true
        } catch {
            isAppReady = false
            switch error as? KeyManagerError {
            case .generateKey(let status):
                self.error = "Cannot generate key: \(String(describing: status))"
            case .corruptedKey(let status):
                self.error = "Cannot retrieve key: \(status)"
            case nil:
                self.error = "Undefined error while setuping key"
            }
            showError = true
        }
    }

    func enterContent() {
        error = nil

        biometryPermissionRequester.request { [weak self] result in
            switch result {
            case .success:
                self?.navigateToContent = true
            case .failure(let error):
                self?.error = error.description
                self?.showError = true
            }
        }
    }
}
