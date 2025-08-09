import Foundation
import CloudKit

final class CloudKitManager {
    private let container: CKContainer
    private let database: CKDatabase

    init(container: CKContainer = CKContainer.default()) {
        self.container = container
        // Use database(with: .private) to use the user's private database for saving records
        self.database = container.database(with: .private)
    }

    /// Saves a transcription string to CloudKit. Creates a new 'Transcription' record with a 'text' field and saves it.
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
