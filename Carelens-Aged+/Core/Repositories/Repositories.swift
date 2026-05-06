import Foundation

protocol ClientRepository {
    func fetchAll() async throws -> [ClientProfile]
    func fetch(id: String) async throws -> ClientProfile?
    func save(_ client: ClientProfile) async throws
    func delete(id: String) async throws
}

protocol AssessmentRepository {
    func assessments(for clientID: String) async throws -> [AssessmentSession]
    func save(_ assessment: AssessmentSession) async throws
    func delete(id: String) async throws
}

protocol CarePlanRepository {
    func carePlans(for clientID: String) async throws -> [CarePlan]
    func save(_ carePlan: CarePlan) async throws
    func delete(id: String) async throws
}

protocol MonitoringRepository {
    func events(for clientID: String) async throws -> [MonitoringEvent]
    func save(_ event: MonitoringEvent) async throws
    func delete(id: String) async throws
}

protocol ReportRepository {
    func generateReport(type: ReportType, clientID: String) async throws -> Data?
    func savedReports(for clientID: String) async throws -> [SavedReport]
}

protocol SyncCoordinator {
    func performInitialSync() async throws
    func syncPendingChanges() async throws
    func rebuildFromBackupIfNeeded() async throws
}

struct SavedReport: Identifiable {
    let id: String
    let clientID: String
    let type: ReportType
    let generatedAt: Date
    let pdfData: Data?
}
