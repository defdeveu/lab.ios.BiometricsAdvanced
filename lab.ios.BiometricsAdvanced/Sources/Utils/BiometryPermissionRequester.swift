import Foundation
import LocalAuthentication

enum PermissionRequesterError: Error {
    case unknown
    case evaluation(String)
    case denied
    case noBiometry

    var description: String {
        switch self {
        case .unknown:
            return "Unknown LA error"
        case .evaluation(let error):
            return "LA error: \(error)"
        case .denied:
            return "Biometry permission denied"
        case .noBiometry:
            return "Device doesn't have a biometry"
        }
    }
}

protocol BiometryPermissionRequesterProtocol {
    func request(completion: @escaping (Result<Void, PermissionRequesterError>) -> Void)
}

final class BiometryPermissionRequester: BiometryPermissionRequesterProtocol {
    func request(completion: @escaping (Result<Void, PermissionRequesterError>) -> Void) {
        let context = LAContext()

        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID, .faceID:
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: "We use biometry for saving data",
                                       reply: { (authenticated, _) in
                    DispatchQueue.main.async {
                        if authenticated {
                            completion(.success(()))
                        } else {
                            completion(.failure(.denied))
                        }
                    }
                })

            case .none:
                completion(.failure(.noBiometry))

            @unknown default:
                completion(.failure(.unknown))

            }
        } else {
            if let errorDescription = error?.localizedDescription {
                return completion(.failure(.evaluation(errorDescription)))
            } else {
                return completion(.failure(.unknown))
            }
        }
    }
}
