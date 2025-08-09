import Foundation
import AVFoundation

final class RecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    private var recorder: AVAudioRecorder?
    private(set) var audioFilename: URL?

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        let tempDir = FileManager.default.temporaryDirectory
        let file = tempDir.appendingPathComponent("\(UUID().uuidString).m4a")
        audioFilename = file

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let newRecorder = try AVAudioRecorder(url: file, settings: settings)
        newRecorder.delegate = self
        newRecorder.prepareToRecord()
        newRecorder.record()
        recorder = newRecorder
        isRecording = true
    }

    func stopRecording() {
        if isRecording {
            if let rec = recorder {
                rec.stop()
            }
            isRecording = false
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            audioFilename = nil
        }
    }
}
