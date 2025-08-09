import Foundation
import AVFoundation

final class RecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording: Bool = false
    private var recorder: AVAudioRecorder?
    private(set) var audioFilename: URL?

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let newRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        newRecorder.delegate = self
        newRecorder.isMeteringEnabled = true
        newRecorder.prepareToRecord()
        newRecorder.record()

        self.recorder = newRecorder
        self.audioFilename = fileURL
        self.isRecording = true
    }

    func stopRecording() throws -> URL {
        guard let recorder = recorder, let url = audioFilename else {
            throw NSError(domain: "RecordingManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active recording."])
        }
        recorder.stop()
        self.recorder = nil
        self.isRecording = false
        return url
    }
}
