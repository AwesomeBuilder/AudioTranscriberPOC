import SwiftUI

/// The entry point to the proof-of-concept audio transcription app.
///
/// This struct conforms to the `App` protocol and hosts a single
/// `ContentView` in a `WindowGroup`. When the app launches the view
/// hierarchy defined in `ContentView` is displayed.
@main
struct AudioTranscriberPOCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
