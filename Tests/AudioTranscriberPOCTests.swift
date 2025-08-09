import XCTest
@testable import AudioTranscriberPOC

/// Basic unit tests for the proof‑of‑concept project.
///
/// These tests verify that the helper classes can be instantiated and
/// that their public state behaves as expected.  They intentionally
/// avoid hitting the microphone, speech recogniser or CloudKit APIs
/// because those services require entitlements and user interaction
/// unavailable in the test environment.
final class AudioTranscriberPOCTests: XCTestCase {

    /// Test that `RecordingManager` defaults to a non‑recording state.
    func testRecordingManagerInitialization() {
        let manager = RecordingManager()
        XCTAssertFalse(manager.isRecording, "RecordingManager should not be recording immediately after initialisation")
    }

    /// Test that `SpeechTranscriber` can be created successfully.
    func testSpeechTranscriberInitialization() {
        let transcriber = SpeechTranscriber()
        // Because the transcriber wraps an optional recogniser we ensure
        // that accessing it does not crash.  Simply being able to
        // construct the object suffices for this test.
        XCTAssertNotNil(transcriber, "SpeechTranscriber should be creatable")
    }

    /// Test that the CloudKit manager can be instantiated.  The
    /// container is injected to allow for dependency injection in more
    /// comprehensive tests.
    func testCloudKitManagerInitialization() {
        let manager = CloudKitManager()
        XCTAssertNotNil(manager, "CloudKitManager should be creatable")
    }
}
