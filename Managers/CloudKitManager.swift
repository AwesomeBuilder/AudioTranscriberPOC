import Foundation
import CloudKit

/// A simple wrapper around CloudKit for persisting transcribed text.
///
/// Before using `CloudKitManager` you must enable CloudKit on your
/// project by adding the iCloud capability and selecting the "CloudKit"
/// service.  The project needs a record type named `Transcription` in
/// the CloudKit dashboard with a `String` field called `text`.  The
/// Swift with Majid guide explains how to enable CloudKit in Xcode and
/// define record schemas.
final class CloudKitManager {
    /// The CloudKit container used to save records.  Defaults to the
    /// app's default container which corresponds to the iCloud
    /// capability selected in Xcode.
    private let container: CKContainer
    private let database: CKDatabase

    init(container: CKContainer = CKContainer.default()) {
        self.container = container
        // Persist transcriptions in the private database so that only
        // the current user can access their recordings.
        self.database = container.database(with: .private)

    /// Saves a transcription string to CloudKit.  A new `CKRecord` of
    /// type `Transcription` is created with a single `text` field.  The
    /// completion handler is called on an arbitrary queue with either
    /// the saved record or an error.
    func saveTranscription(text: String, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let record = CKRecord(recordType: "Transcription")
        record["text"] = text as CKRecordValue
        database.save(record) { savedRecord, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let savedRecord = savedRecord {
                completion(.success(savedRecord))
            }
        }
    }
}
