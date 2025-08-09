import Foundation
import Speech

final class SpeechTranscriber: NSObject, ObservableObject {
    private let recognizer = SFSpeechRecognizer()

    override init() {
        super.init()
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    func transcribe(fileURL: URL, onDevice: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            completion(.failure(NSError(domain: "SpeechTranscriber", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recognizer unavailable"])))
            return
        }
        let request = SFSpeechURLRecognitionRequest(fileURL: fileURL)
        // Prefer on-device recognition when explicitly requested and supported. Otherwise fall back to network.
        if #available(iOS 13.0, *) {
            if onDevice && recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            } else {
                request.requiresOnDeviceRecognition = false
        
        }
        
                else {
        // Fallback for earlier iOS versions
        request.requiresOnDeviceRecognition = false
    }recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let result = result, result.isFinal {
                completion(.success(result.bestTranscription.formattedString))
            }
        }
    }
}
