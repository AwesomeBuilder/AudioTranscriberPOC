import Foundation
import Speech

/// A helper for converting recorded audio into text using Apple's Speech
/// framework.
///
/// The `SpeechTranscriber` requests permission from the user when first
/// created and exposes a method to perform transcription on a file.  By
/// setting `requiresOnDeviceRecognition` on the request and toggling
/// `supportsOnDeviceRecognition` on the recognizer the framework can
/// perform transcription completely on‑device without network access as
/// documented in the Speech framework guidelines.
final class SpeechTranscriber {
    /// The recognizer used to perform speech‑to‑text.  We store the
    /// locale so the user can customise the recognition language if
    /// needed.
    private let recognizer: SFSpeechRecognizer?

    init(locale: Locale = Locale(identifier: "en-US")) {
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    /// Prompts the user for permission to perform speech recognition.  The
    /// completion handler is called with the resulting status.
    func requestAuthorization(completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            completion(status)
        }
    }

    /// Transcribes the audio file at the given URL.  This method runs
    /// asynchronously; once a result or error is available the
    /// `completion` handler is invoked on an arbitrary queue.  If
    /// `onDevice` is true the recognizer will be configured for
    /// offline use.
    func transcribe(url: URL, onDevice: Bool = true, completion: @escaping (String?, Error?) -> Void) {
        guard let recognizer = recognizer else {
            completion(nil, NSError(domain: "SpeechTranscriber", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer unavailable on this device"]))
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)

        if onDevice {
            // Configure for offline recognition.  According to the
            // documentation, both the recognizer and the request must
            // indicate on‑device support.
            recognizer.supportsOnDeviceRecognition = true
            request.requiresOnDeviceRecognition = true
        }

        recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let res = result, res.isFinal {
                completion(res.bestTranscription.formattedString, nil)
            }
        }
    }
}
