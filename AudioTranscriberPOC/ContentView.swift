import SwiftUI

struct ContentView: View {
    @StateObject private var recorder = RecordingManager()
    @StateObject private var transcriber = SpeechTranscriber()
    private let cloud = CloudKitManager()

    @State private var transcript: String = ""
    @State private var status: String = "Idle"

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Transcriber POC")
                .font(.title2).bold()

            Text(status).foregroundStyle(.secondary)

            Button(action: toggleRecording) {
                Text(recorder.isRecording ? "Stop" : "Record")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(recorder.isRecording ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                    .clipShape(Capsule())
            }

            ScrollView {
                Text(transcript.isEmpty ? "Transcript will appear here..." : transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(maxHeight: 300)

            Spacer(minLength: 0)
        }
        .padding()
    }

    private func toggleRecording() {
        if recorder.isRecording {
            do {
                let url = try recorder.stopRecording()
                status = "Transcribing..."
                transcriber.transcribe(fileURL: url, onDevice: true) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let text):
                            transcript = text
                            status = "Saving to Cloud..."
                            cloud.saveTranscription(text: text) { _ in
                                DispatchQueue.main.async {
                                    status = "Saved to iCloud (Private DB)"
                                }
                            }
                        case .failure(let error):
                            status = "Transcription failed: \(error.localizedDescription)"
                        }
                    }
                }
            } catch {
                status = "Stop failed: \(error.localizedDescription)"
            }
        } else {
            do {
                try recorder.startRecording()
                status = "Recording..."
            } catch {
                status = "Record failed: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ContentView()
}
