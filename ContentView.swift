import SwiftUI
import AVFoundation

/// The main view for the proof‑of‑concept app.
///
/// It displays a single button that toggles between recording and stopping
/// recording. When the recording stops the captured audio is transcribed
/// using Apple's on‑device speech recognition and the resulting text is
/// persisted to the user's private iCloud database. Feedback is surfaced
/// to the user via a simple `Alert`.
struct ContentView: View {
    /// Manages microphone recording.  Using `@StateObject` ensures the
    /// instance persists for the lifetime of the view and publishes
    /// changes to the `isRecording` flag.
    @StateObject private var recordingManager = RecordingManager()

    /// Holds the most recently transcribed text.  This property updates
    /// once a transcription completes and the view automatically updates
    /// its display.
    @State private var transcription: String = ""

    /// Flags whether an alert should be presented and stores the
    /// associated message.  Alerts are shown to communicate errors or
    /// successful CloudKit writes.
    @State private var showAlert = false
    @State private var alertMessage = ""

    /// Speech recognition and CloudKit helpers.  These are created once
    /// during the view's lifetime and reused across recordings.
    private let transcriber = SpeechTranscriber()
    private let cloudKitManager = CloudKitManager()

    var body: some View {
        VStack {
            Spacer()

            // Display the transcript if available, otherwise prompt the user
            if !transcription.isEmpty {
                Text(transcription)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                Text("Tap the button below to record and transcribe")
                    .foregroundColor(.secondary)
                    .padding()
            }

            // Record/stop button.  The label and colour of the button
            // reflect the current state of the recorder.
            Button(action: handleButtonTap) {
                Text(recordingManager.isRecording ? "Stop Recording" : "Start Recording")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(recordingManager.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        // Request permissions and configure audio on launch.  This work
        // happens in `onAppear` so that it runs once when the view
        // appears.  If the user denies permission an alert is presented.
        .onAppear {
            transcriber.requestAuthorization { status in
                if status != .authorized {
                    alertMessage = "Speech recognition not authorized. Please enable access in Settings."
                    showAlert = true
                }
            }
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    alertMessage = "Microphone access was denied. Please enable microphone permissions in Settings."
                    showAlert = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    /// Handles taps on the record/stop button.  When recording starts
    /// the microphone session is activated.  When recording stops the
    /// audio file is passed to the speech recognizer and the resulting
    /// transcript is stored in CloudKit.
    private func handleButtonTap() {
        if recordingManager.isRecording {
            // Stop recording and begin transcription.
            recordingManager.stopRecording()
            guard let url = recordingManager.audioFilename else {
                alertMessage = "Recording failed to produce an audio file."
                showAlert = true
                return
            }
            transcriber.transcribe(url: url) { text, error in
                if let error = error {
                    alertMessage = "Transcription error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                guard let text = text else {
                    alertMessage = "No transcription returned."
                    showAlert = true
                    return
                }
                DispatchQueue.main.async {
                    self.transcription = text
                    // Save the transcript to CloudKit.  Use the
                    // completion handler to update the user with the
                    // outcome of the save.
                    cloudKitManager.saveTranscription(text: text) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                alertMessage = "Transcript saved to CloudKit successfully!"
                            case .failure(let error):
                                alertMessage = "Failed to save transcript: \(error.localizedDescription)"
                            }
                            showAlert = true
                        }
                    }
                }
            }
        } else {
            // Attempt to start recording.  If an error occurs it is
            // surfaced via the alert mechanism.
            do {
                try recordingManager.startRecording()
            } catch {
                alertMessage = "Unable to start recording: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

// Preview provider for SwiftUI previews in Xcode.  This is not required
// by the app but provides a live preview inside the canvas.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
